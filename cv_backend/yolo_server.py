import asyncio
import websockets
import cv2
import json
import base64
import numpy as np
import threading
import time
import torch

# Patch torch.load for PyTorch 2.6+
_original_load = torch.load
torch.load = lambda *args, **kwargs: _original_load(*args, **{**kwargs, 'weights_only': False})

from ultralytics import YOLO

# ==========================================
# CONFIGURATION
# ==========================================
ESP32_STREAM_URL = "http://10.143.186.239:81/"
WS_PORT = 8082

print("Loading YOLOv8 model...")
model = YOLO('yolov8n.pt')
print("Model loaded.")

# Shared state
latest_frame = None
latest_frame_lock = threading.Lock()
current_frame_data = {"image": "", "detections": []}


def stream_thread():
    """
    Downloads each raw JPEG frame by manually scanning for JPEG magic bytes.
    Uses requests.get(stream=True) so FFMPEG / OpenCV is NEVER involved.
    This completely avoids the 30-second FFMPEG timeout bug.
    """
    import requests
    global latest_frame

    BOUNDARY = b'--123456789000000000000987654321'

    while True:
        try:
            print(f"[STREAM] Connecting to {ESP32_STREAM_URL} ...")
            # Large read timeout - a small QVGA frame should arrive in <1s
            resp = requests.get(ESP32_STREAM_URL, stream=True, timeout=(10, 30))
            resp.raise_for_status()
            print("[STREAM] Connected! Reading frames...")

            buf = b""
            for chunk in resp.iter_content(chunk_size=4096):
                if not chunk:
                    continue
                buf += chunk

                # Keep buffer manageable (max 200 KB)
                if len(buf) > 200_000:
                    buf = buf[-100_000:]

                # Find a complete JPEG: starts with FFD8, ends with FFD9
                while True:
                    start = buf.find(b'\xff\xd8')
                    if start == -1:
                        buf = b""
                        break

                    end = buf.find(b'\xff\xd9', start + 2)
                    if end == -1:
                        # Incomplete frame — wait for more chunks
                        buf = buf[start:]
                        break

                    # We have a complete JPEG
                    jpg = buf[start:end + 2]
                    buf = buf[end + 2:]

                    frame = cv2.imdecode(
                        np.frombuffer(jpg, dtype=np.uint8),
                        cv2.IMREAD_COLOR
                    )
                    if frame is not None:
                        with latest_frame_lock:
                            latest_frame = frame

        except Exception as e:
            print(f"[STREAM] Error: {e}. Reconnecting in 2s...")
            time.sleep(2)


def yolo_thread():
    """
    Picks the latest frame and runs YOLO inference on it.
    Runs independently so inference speed never blocks the stream downloader.
    """
    global current_frame_data, latest_frame

    while True:
        frame_to_process = None
        with latest_frame_lock:
            if latest_frame is not None:
                frame_to_process = latest_frame.copy()
                latest_frame = None

        if frame_to_process is not None:
            results = model(frame_to_process, verbose=False)

            detections = []
            h, w = frame_to_process.shape[:2]
            for res in results:
                for box in res.boxes:
                    x1, y1, x2, y2 = box.xyxy[0].tolist()
                    c = int(box.cls.item())
                    conf = box.conf.item()
                    detections.append({
                        "defectType": model.names[c].upper(),
                        "componentId": f"OBJ_{c}",
                        "confidence": conf,
                        "x": x1 / w,
                        "y": y1 / h,
                        "width": (x2 - x1) / w,
                        "height": (y2 - y1) / h,
                    })

            _, buf = cv2.imencode('.jpg', frame_to_process,
                                  [cv2.IMWRITE_JPEG_QUALITY, 65])
            img_b64 = base64.b64encode(buf).decode('utf-8')

            current_frame_data = {"image": img_b64, "detections": detections}

        time.sleep(0.03)  # ~30 fps max inference


async def ws_handler(websocket):
    print("[WS] Client connected!")
    try:
        while True:
            if current_frame_data["image"]:
                await websocket.send(json.dumps(current_frame_data))
            await asyncio.sleep(1 / 30)
    except websockets.exceptions.ConnectionClosed:
        print("[WS] Client disconnected")
    except Exception as e:
        print(f"[WS] Error: {e}")


async def main():
    print(f"[SERVER] Starting WebSocket on ws://0.0.0.0:{WS_PORT}")

    threading.Thread(target=stream_thread, daemon=True).start()
    threading.Thread(target=yolo_thread, daemon=True).start()

    async with websockets.serve(ws_handler, "0.0.0.0", WS_PORT):
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())
