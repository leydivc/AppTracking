import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingApp extends StatefulWidget {
  const TrackingApp({super.key});

  @override
  State<TrackingApp> createState() => _TrackingAppState();
}

class _TrackingAppState extends State<TrackingApp> {
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  _loadLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _locations = prefs.getStringList('locations') ?? [];
    });
  }

  _saveLocation(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String location = '${position.latitude}, ${position.longitude}';
    _locations.add(location);
    await prefs.setStringList('locations', _locations);
    setState(() {});
  }

  _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _saveLocation(position);
  }

  _clearLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('locations');
    setState(() {
      _locations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('LOCATION TRACKER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)),
        backgroundColor: const Color.fromARGB(255, 204, 35, 80),
        actions: [
          IconButton(
            onPressed: _clearLocations,
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      //backgroundColor: const Color.fromARGB(255, 241, 150, 175),
      body: Column(
        children: [
          const SizedBox(height: 30.0),
          const Text('Si desea saber su ubicación (latitud y longitud), presione el botón LOCATION NOW.', textAlign: TextAlign.center, style: TextStyle(color: Color.fromARGB(255, 218, 70, 109), fontSize: 15),),
          const SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: _getLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 218, 70, 109),
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('LOCATION NOW', style: TextStyle(color: Colors.white),),
          ),
          const SizedBox(height: 30.0),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_locations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
