import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../state/mqtt_vibration_notifier.dart';
import '../../services/mqtt/mqtt_service.dart';

class ServiceStation {
  final String id;
  final String name;
  final String city;
  final LatLng location;
  final List<String> services;

  ServiceStation({
    required this.id,
    required this.name,
    required this.city,
    required this.location,
    required this.services,
  });
}

final List<ServiceStation> realStations = [
  ServiceStation(
    id: 'SR-PER',
    name: 'Perambur Carriage Works',
    city: 'Chennai',
    location: const LatLng(13.1030, 80.2393),
    services: ['Carriage Repair', 'Periodic Overhaul'],
  ),
  ServiceStation(
    id: 'SR-TBM',
    name: 'Tambaram EMU Car Shed',
    city: 'Chennai',
    location: const LatLng(12.9229, 80.1118),
    services: ['EMU Maintenance', 'Routine Overhaul'],
  ),
  ServiceStation(
    id: 'SR-RPM',
    name: 'Royapuram Electric Loco Shed',
    city: 'Chennai',
    location: const LatLng(13.1113, 80.2942),
    services: ['Electric Loco Maintenance'],
  ),
  ServiceStation(
    id: 'SR-GOC',
    name: 'Golden Rock Railway Workshop',
    city: 'Tiruchirappalli',
    location: const LatLng(10.7963, 78.7180),
    services: ['Diesel Loco Overhaul', 'Wagon Repair'],
  ),
  ServiceStation(
    id: 'SWR-RWF',
    name: 'Rail Wheel Factory',
    city: 'Bengaluru',
    location: const LatLng(13.1018, 77.5878),
    services: ['Wheel Casting', 'Axle Forging'],
  ),
  ServiceStation(
    id: 'SWR-UBL',
    name: 'Hubballi Railway Workshop',
    city: 'Hubballi',
    location: const LatLng(15.3468, 75.1432),
    services: ['EMD Loco Maintenance', 'Carriage Overhaul'],
  ),
  ServiceStation(
    id: 'CR-PA',
    name: 'Pune Diesel Loco Shed',
    city: 'Pune',
    location: const LatLng(18.5309, 73.8732),
    services: ['Diesel Loco Maintenance', 'Refueling'],
  ),
  ServiceStation(
    id: 'CR-PR',
    name: 'Parel Locomotive Workshop',
    city: 'Mumbai',
    location: const LatLng(18.9953, 72.8402),
    services: ['Loco Overhaul', 'Heavy Maintenance'],
  ),
  ServiceStation(
    id: 'CR-KYN',
    name: 'Kalyan Electric Loco Shed',
    city: 'Kalyan',
    location: const LatLng(19.2359, 73.1368),
    services: ['Electric Loco Maintenance'],
  ),
  ServiceStation(
    id: 'WR-SBI',
    name: 'Sabarmati Diesel Loco Shed',
    city: 'Ahmedabad',
    location: const LatLng(23.0645, 72.5855),
    services: ['Diesel Loco Overhaul'],
  ),
  ServiceStation(
    id: 'NR-TKD',
    name: 'Tughlakabad Electric Loco Shed',
    city: 'New Delhi',
    location: const LatLng(28.5135, 77.2798),
    services: ['Electric Loco Shed'],
  ),
  ServiceStation(
    id: 'NR-RCF',
    name: 'Rail Coach Factory',
    city: 'Kapurthala',
    location: const LatLng(31.3323, 75.3155),
    services: ['LHB Coach Manufacturing'],
  ),
  ServiceStation(
    id: 'NCR-MCF',
    name: 'Modern Coach Factory',
    city: 'Raebareli',
    location: const LatLng(26.2307, 81.1895),
    services: ['Coach Manufacturing'],
  ),
  ServiceStation(
    id: 'NER-GKP',
    name: 'Gorakhpur Railway Workshop',
    city: 'Gorakhpur',
    location: const LatLng(26.7588, 83.3813),
    services: ['Carriage Maintenance'],
  ),
  ServiceStation(
    id: 'SER-KGP',
    name: 'Kharagpur Railway Workshop',
    city: 'Kharagpur',
    location: const LatLng(22.3385, 87.3242),
    services: ['Heavy Repair', 'Periodic Overhaul'],
  ),
  ServiceStation(
    id: 'ER-JMP',
    name: 'Jamalpur Locomotive Workshop',
    city: 'Munger',
    location: const LatLng(25.3134, 86.4868),
    services: ['Diesel Loco Overhaul'],
  ),
  ServiceStation(
    id: 'ER-CLW',
    name: 'Chittaranjan Locomotive Works',
    city: 'Chittaranjan',
    location: const LatLng(23.8649, 86.8778),
    services: ['Electric Loco Manufacturing'],
  ),
  ServiceStation(
    id: 'ECoR-VSKP',
    name: 'Visakhapatnam Electric Loco Shed',
    city: 'Visakhapatnam',
    location: const LatLng(17.7266, 83.2285),
    services: ['Electric Loco Maintenance'],
  ),
  ServiceStation(
    id: 'SCR-LGD',
    name: 'Lallaguda Carriage Workshop',
    city: 'Secunderabad',
    location: const LatLng(17.4339, 78.5283),
    services: ['Carriage Repair'],
  ),
  ServiceStation(
    id: 'CR-AQ',
    name: 'Ajni Electric Loco Shed',
    city: 'Nagpur',
    location: const LatLng(21.1219, 79.0622),
    services: ['Electric Loco Overhaul'],
  ),
  ServiceStation(
    id: 'SR-AVD',
    name: 'Avadi Car Shed',
    city: 'Chennai',
    location: const LatLng(13.1186, 80.1062),
    services: ['EMU Maintenance'],
  ),
  ServiceStation(
    id: 'SR-VLCY',
    name: 'Velachery Car Shed',
    city: 'Chennai',
    location: const LatLng(12.9781, 80.2227),
    services: ['EMU Maintenance'],
  ),
  ServiceStation(
    id: 'SR-PGT',
    name: 'Palakkad Car Shed',
    city: 'Palakkad',
    location: const LatLng(10.7675, 76.6578),
    services: ['MEMU Maintenance'],
  ),
  ServiceStation(
    id: 'SR-QLN',
    name: 'Quilon Car Shed',
    city: 'Kollam',
    location: const LatLng(8.8876, 76.5937),
    services: ['MEMU Maintenance'],
  ),
  ServiceStation(
    id: 'SR-BBQ',
    name: 'Basin Bridge Coach Depot',
    city: 'Chennai',
    location: const LatLng(13.0963, 80.2743),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-GSN',
    name: 'Gopalswami Nagar Depot',
    city: 'Chennai',
    location: const LatLng(13.1017, 80.2878),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-ED',
    name: 'Erode Depot',
    city: 'Erode',
    location: const LatLng(11.3323, 77.7275),
    services: ['Coach Maintenance', 'Wagon Maintenance'],
  ),
  ServiceStation(
    id: 'SR-CBE',
    name: 'Coimbatore Depot',
    city: 'Coimbatore',
    location: const LatLng(11.0003, 76.9667),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-MTP',
    name: 'Mettupalayam Depot',
    city: 'Mettupalayam',
    location: const LatLng(11.2987, 76.9458),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-SRR',
    name: 'Shoranur Depot',
    city: 'Shoranur',
    location: const LatLng(10.7634, 76.2731),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-MAQ',
    name: 'Mangalore Depot',
    city: 'Mangaluru',
    location: const LatLng(12.8687, 74.8459),
    services: ['Coach Maintenance', 'Wagon Maintenance'],
  ),
  ServiceStation(
    id: 'SR-TVC',
    name: 'Trivandrum Depot',
    city: 'Thiruvananthapuram',
    location: const LatLng(8.4891, 76.9472),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-KCVL',
    name: 'Kochuveli Depot',
    city: 'Thiruvananthapuram',
    location: const LatLng(8.5132, 76.8967),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-ERS',
    name: 'Ernakulam Depot',
    city: 'Kochi',
    location: const LatLng(9.9674, 76.2844),
    services: ['Coach Maintenance', 'Wagon Maintenance'],
  ),
  ServiceStation(
    id: 'SR-NCJ',
    name: 'Nagercoil Depot',
    city: 'Nagercoil',
    location: const LatLng(8.1923, 77.4396),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-ALLP',
    name: 'Alleppey Depot',
    city: 'Alappuzha',
    location: const LatLng(9.4899, 76.3262),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-MDU',
    name: 'Madurai Depot',
    city: 'Madurai',
    location: const LatLng(9.9255, 78.1130),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-TEN',
    name: 'Tirunelveli Depot',
    city: 'Tirunelveli',
    location: const LatLng(8.7276, 77.7011),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-TN',
    name: 'Tuticorin Depot',
    city: 'Thoothukudi',
    location: const LatLng(8.7997, 78.1251),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-RMM',
    name: 'Rameswaram Depot',
    city: 'Rameswaram',
    location: const LatLng(9.2876, 79.3129),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-VM',
    name: 'Villupuram Depot',
    city: 'Villupuram',
    location: const LatLng(11.9407, 79.4975),
    services: ['Coach Maintenance'],
  ),
  ServiceStation(
    id: 'SR-TNP',
    name: 'Tondiarpet Wagon Depot',
    city: 'Chennai',
    location: const LatLng(13.1293, 80.2882),
    services: ['Wagon Maintenance'],
  ),
  ServiceStation(
    id: 'SR-JTJ',
    name: 'Jolarpettai Wagon Depot',
    city: 'Jolarpettai',
    location: const LatLng(12.5593, 78.5630),
    services: ['Wagon Maintenance'],
  ),
  ServiceStation(
    id: 'SR-AJJ',
    name: 'Arakkonam Wagon Depot',
    city: 'Arakkonam',
    location: const LatLng(13.0805, 79.6640),
    services: ['Wagon Maintenance'],
  ),
];

class ServiceStationsPage extends StatefulWidget {
  const ServiceStationsPage({super.key});

  @override
  State<ServiceStationsPage> createState() => _ServiceStationsPageState();
}

class _ServiceStationsPageState extends State<ServiceStationsPage> {
  final MapController _mapController = MapController();
  static const LatLng _centerOfIndia = LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    final mqttNotifier = context.watch<MqttVibrationNotifier>();
    final theme = Theme.of(context);

    // Get Train Location
    // If ESP32 hasn't got a fix yet (0.0, 0.0), use a default location or center of India.
    final bool hasGpsFix = mqttNotifier.gpsLat != 0.0 && mqttNotifier.gpsLng != 0.0;
    final LatLng trainLocation = hasGpsFix 
        ? LatLng(mqttNotifier.gpsLat, mqttNotifier.gpsLng)
        : _centerOfIndia;

    // Calculate distances
    const distanceCalc = Distance();
    
    // Create a list of stations with distances
    final List<Map<String, dynamic>> stationsWithDistance = realStations.map((station) {
      final double distance = hasGpsFix
          ? distanceCalc.as(LengthUnit.Kilometer, trainLocation, station.location).toDouble()
          : 0.0;
      return {
        'station': station,
        'distance': distance,
      };
    }).toList();

    // Sort and filter by distance if we have a fix
    if (hasGpsFix) {
      stationsWithDistance.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      stationsWithDistance.removeWhere((item) => (item['distance'] as double) > 500.0);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, size: 24),
              const SizedBox(width: 8),
              Text(
                'SERVICE STATIONS & LIVE TRACKING',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildGpsStatusBadge(hasGpsFix, mqttNotifier.gpsSats, theme),
              const SizedBox(width: 12),
              _buildConnectionBadge(mqttNotifier.connectionState, theme),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Map View
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: trainLocation,
                              initialZoom: hasGpsFix ? 12.0 : 4.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.smartrail.ai',
                              ),
                              MarkerLayer(
                                markers: [
                                  // Service Station Markers
                                  ...stationsWithDistance.map(
                                    (item) {
                                      final station = item['station'] as ServiceStation;
                                      return Marker(
                                        point: station.location,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.build_circle,
                                          color: Colors.blueAccent,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                  // Train Marker
                                  if (hasGpsFix)
                                    Marker(
                                      point: trainLocation,
                                      width: 50,
                                      height: 50,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                        ),
                                        child: const Icon(
                                          Icons.train,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (!hasGpsFix)
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Waiting for GPS Fix from ESP32...',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Service Stations List
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            hasGpsFix ? 'Nearest Service Stations' : 'All Service Stations',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            itemCount: stationsWithDistance.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = stationsWithDistance[index];
                              final ServiceStation station = item['station'];
                              final double distance = item['distance'];

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(Icons.engineering, color: theme.colorScheme.primary),
                                ),
                                title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('${station.city} • ${station.id}'),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: station.services.map((s) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(s, style: const TextStyle(fontSize: 10)),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                                trailing: hasGpsFix
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            distance.toStringAsFixed(1),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: distance < 100 ? Colors.green : null,
                                            ),
                                          ),
                                          const Text('km', style: TextStyle(fontSize: 10)),
                                        ],
                                      )
                                    : null,
                                onTap: () {
                                  _mapController.move(station.location, 14.0);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBadge(AppMqttConnectionState state, ThemeData theme) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case AppMqttConnectionState.connected:
        color = Colors.green;
        text = 'CONNECTED';
        icon = Icons.wifi;
        break;
      case AppMqttConnectionState.connecting:
        color = Colors.orange;
        text = 'CONNECTING';
        icon = Icons.sync;
        break;
      case AppMqttConnectionState.disconnected:
      case AppMqttConnectionState.error:
        color = Colors.red;
        text = 'DISCONNECTED';
        icon = Icons.wifi_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsStatusBadge(bool hasFix, int sats, ThemeData theme) {
    final color = hasFix ? Colors.blue : Colors.grey;
    final text = hasFix ? 'GPS: 3D FIX ($sats SATS)' : 'GPS: NO FIX';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasFix ? Icons.gps_fixed : Icons.gps_not_fixed, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
