import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_weather_app/app_route/app_route.dart';
import 'package:my_weather_app/screen/login.dart';
import 'package:my_weather_app/utils/shared_pref.dart';

import 'package:my_weather_app/widgets/custom_toaster.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription? internetconnection;
  bool loading = true;
  Map<String, dynamic> currentWeather = {};
  Map<String, dynamic> currentLocationWeather = {"dataseries": []};
  List<Map<String, dynamic>> multiRegionWeather = [];
  dynamic myLocationName = null;

  dynamic regions = ['Mumbai', 'Delhi', 'Kolkata', 'Gujrat'];

  @override
  void initState() {
    super.initState();
    fetchData();
    checkConnection();
  }

  checkConnection() async {
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        showCustomToast(context: context, message: 'Internet not available');
      }
    }); //
  }

  @override
  dispose() {
    super.dispose();
    internetconnection!.cancel();
    //cancel internent connection subscription after you are done
  }

  Future<void> requestPermissionsAndFetchWeather() async {
    if (await Permission.location.request().isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        fetchWeatherDataForCurrentLocation(
            position.latitude, position.longitude);

        // Get the placemarks associated with the current location
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        log(placemarks.toString());
        // Check if placemarks are available
        if (placemarks.isNotEmpty) {
          // Get the first placemark
          Placemark placemark = placemarks.first;

          // Get the name of the location (could be city, town, village, etc.)
          String locationName = placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea ??
              'Unknown Location';

          // Display the location name or use it as per your requirement
          print('Location Name: $locationName');
          setState(() {
            myLocationName = locationName;
          });
        }
      } catch (e) {
        showCustomToast(context: context, message: 'Error getting location');
      }
    } else {
      showCustomToast(
          context: context, message: 'Location permission is not granted');
    }
  }

  fetchData() async {
    // Fetch data for the current day
    await requestPermissionsAndFetchWeather();

    // Fetch 7-day forecast for current location
    await fetchWeatherDataForMultiRegion();
    // Set loading to false once data is fetched
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchWeatherDataForCurrentLocation(latitude, longitude) async {
    try {
      final url =
          'http://www.7timer.info/bin/api.pl?lon=$longitude&lat=$latitude&product=civil&output=json';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          log(data.toString());
          currentWeather = data['dataseries'][0];

          currentLocationWeather = data;
        });
      } else {
        print('Error fetching weather data for current location');
      }
    } catch (e) {
      print('Error fetching weather data for current location');
    }
  }

  Future<void> fetchWeatherDataForMultiRegion() async {
    // Define the coordinates for multiple regions
    List<Map<String, double>> regions = [
      {'latitude': 19.0760, 'longitude': 72.8777}, // mumbai
      {'latitude': 28.6139, 'longitude': 77.2090}, // delhi
      {'latitude': 22.5726, 'longitude': 88.3639}, // kolkata
      {'latitude': 23.2156, 'longitude': 72.6369}, // gujrat
      // Add more regions as needed
    ];
    for (var region in regions) {
      try {
        final url =
            'http://www.7timer.info/bin/api.pl?lon=${region['longitude']}&lat=${region['latitude']}&product=civil&output=json';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            multiRegionWeather.add(data);
          });
        } else {
          print('Error fetching weather data for region');
        }
      } catch (e) {
        print('Error fetching weather data for region');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
        backgroundColor: Colors.lightBlue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Handle logout logic here
              await SharedPrefUtils.removePrefStr("isLogin");
              removeAllBackStack(context, LoginScreen());
            },
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue[700]!, Colors.lightBlue[200]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[800],
                      ),
                      child: ListTile(
                        tileColor: Colors.lightBlue[700],
                        title: Text(
                          'Current Day Forecast',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'Temperature: ${currentWeather['temp2m']}°C',
                          style: TextStyle(color: Colors.white70),
                        ),
                        leading:
                            getWeatherIcon(currentWeather['weather'] ?? ''),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "${myLocationName ?? "Current Location"} 7 Day Forecast",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          currentLocationWeather['dataseries'].length == 0
                              ? 0
                              : 7,
                      itemBuilder: (context, index) {
                        final dayWeather =
                            currentLocationWeather['dataseries'][index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: getWeatherIcon(dayWeather['weather']),
                            title: Text('Day ${index + 1}'),
                            subtitle:
                                Text('Temperature: ${dayWeather['temp2m']}°C'),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Multiple Regions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ...List.generate(multiRegionWeather.length, (index) {
                      final regionWeather = multiRegionWeather[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          backgroundColor: Colors.lightBlue[100],
                          title: Text(
                            '${regions[index]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: regionWeather['dataseries']
                              .take(7)
                              .map<Widget>((dayWeather) {
                            return ListTile(
                              leading: getWeatherIcon(dayWeather['weather']),
                              title: Text(
                                  'Day ${regionWeather['dataseries'].indexOf(dayWeather) + 1}'),
                              subtitle: Text(
                                  'Temperature: ${dayWeather['temp2m']}°C ${dayWeather['weather']}'),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Icon getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case "clearday":
      case "clearnight":
        return Icon(Icons.wb_sunny, color: Colors.orange);

      case "cloudyday":
      case "cloudynight":
      case "mcloudyday":
      case "mcloudynight":
      case "pcloudyday":
      case "pcloudynight":
        return Icon(Icons.wb_cloudy, color: Colors.grey);

      case "lightrainday":
      case "lightrainnight":
      case "oshowerday":
      case "oshowernight":
      case "ishowerday":
      case "ishowernight":
        return Icon(CupertinoIcons.umbrella_fill, color: Colors.blueAccent);

      case "tsnight":
      case "tsday":
        return Icon(Icons.flash_on, color: Colors.yellow);

      // Add more cases for other weather conditions as needed
      default:
        return Icon(Icons.error); // Default icon for unknown conditions
    }
  }
}
