import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'currentDayInfo.dart';
import 'currentWeekInfo.dart';

import 'dart:async';
import 'dart:convert';

import 'package:location/location.dart';

import 'package:geocoder/geocoder.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

enum WeatherInfo { Today, Week }

void main() => runApp(MyApp());

String GetIconNameByCode(String weatherConditionID, bool isNightTime){
  if (weatherConditionID.startsWith('2')){
    // Thunder
    return "thunder";
  } else if (weatherConditionID.startsWith('5')){
    // Rain
    return "rain";
  } else if (weatherConditionID.startsWith('6')){
    // Snow
    return "snow";
  } else if (weatherConditionID == "800"){
    // Clear
    if (isNightTime){
      // Clear night
      return "clear-night";
    } else {
      // Clear day
      return "clear";
    }
  } else if (weatherConditionID == "801" || weatherConditionID == "802"){
    // Partly cloudy
    if (isNightTime){
      return "partly-cloudy-night";
    } else {
      return "partly-cloudy";
    }
  } else if (weatherConditionID == "803" || weatherConditionID == "804") {
    // Cloudy
    return "cloudy";
  }
}

class DayWeatherInfo {
  int tempMin;
  int tempMax;
  int temp;
  int humidity;
  double windSpeed;
  String weatherCode;
  DateTime sunset; // Actually the sunset of current day
  DateTime sunrise; // same as above
  DateTime date;

  int hourOfDay;

  bool IsNightTimeAt(int hour) {
    DateTime timeToCheck = DateTime(1900, 1, 1, hour);

    // made to simulate sunset / sunrise for dates further than current one, because we take sunset/sunrise from current day

    DateTime fakeSunset = DateTime(timeToCheck.year, timeToCheck.month, timeToCheck.day, sunset.hour,
        sunset.minute, sunset.second, sunset.millisecond, sunset.microsecond);
    DateTime fakeSunrise = DateTime(timeToCheck.year, timeToCheck.month, timeToCheck.day, sunrise.hour,
        sunrise.minute, sunrise.second, sunrise.millisecond, sunrise.microsecond);

    int diffFromSunset = timeToCheck.difference(fakeSunset).inMilliseconds;
    int diffFromSunrise = timeToCheck.difference(fakeSunrise).inMilliseconds;

    if (diffFromSunrise < 0 && diffFromSunset < 0) {
      return true;
    }
    else {
      return false;
    }
  }

  DayWeatherInfo(
      this.tempMin,
      this.tempMax,
      this.temp,
      this.humidity,
      this.windSpeed,
      this.weatherCode,
      this.sunrise,
      this.sunset,
      this.hourOfDay,
      this.date);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }

}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState(){
    return _MyHomePageState();
  }

}

class _MyHomePageState extends State<MyHomePage> {

  Location location = Location();
  Map<String, double> userLocation;

  String country = '';
  String adminArea = '';
  String locality = '';

  final double ButtonOpacity = 0.1;
  final double TextOpacity = 0.5;

  final int startTimeHour = DateTime.now().hour;
  final int startWeekDay = DateTime.now().weekday;

  final String weatherAPIKey = '4e2b4a7ea0807694fe91fae168ba5cd2';

  String currentTemp = '';
  String currentWeatherDescription = '';
  String currentHumidity = '';
  String currentWindSpeed = '';
  String currentPrecipitation = '';
  String currentWeatherIconName = 'windy';
  DateTime currentSunrise = DateTime.utc(1900);
  DateTime currentSunset = DateTime.utc(1900);
  List<DayWeatherInfo> currentWeatherInfos = [];
  int currentWeatherInfoCount = ((24 / 3) + 1).toInt();

  final PageController bottomPartPageController = PageController(
    initialPage: 0,
  );

  WeatherInfo currentInfo = WeatherInfo.Today;

  Curve automaticPageTransitionCurve = Curves.fastOutSlowIn;

  bool SwitchToToday(){
    if (bottomPartPageController.page == 0) {
      return false;
    }
    else {
      bottomPartPageController.animateToPage(0, curve: automaticPageTransitionCurve, duration: Duration(milliseconds: 400));
    }

    return true;
  }

  bool SwitchToWeek(){
    if (bottomPartPageController.page == 1) {
      return false;
    }
    else {
      bottomPartPageController.animateToPage(1, curve: automaticPageTransitionCurve, duration: Duration(milliseconds: 400));
    }

    return true;
  }

  Future<Map<String, double>> GetLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<http.Response> GetCurrentWeather(http.Client client) async {
    return client.get('http://api.openweathermap.org/data/2.5/weather?lat=' + userLocation["latitude"].toString() + '&lon=' + userLocation["longitude"].toString() + '&appid=' + weatherAPIKey + '&mode=json&units=metric');
  }

  Future<http.Response> Get5Day3HourPreditions(http.Client client) async {
    return client.get('http://api.openweathermap.org/data/2.5/forecast?lat=' + userLocation["latitude"].toString() + '&lon=' + userLocation["longitude"].toString() + '&appid=' + weatherAPIKey + '&mode=json&units=metric');
  }

  bool isUpdatingLocation = true;
  bool isUpdatigCurrentWeather = true;

  void UpdateLocation(){
    setState(() {
      isUpdatingLocation = true;
      print("Updating location");
      GetLocation().then((value) {
        setState(() {
          userLocation = value;

          Coordinates coordinates = Coordinates(userLocation["latitude"], userLocation["longitude"]);
          List<Address> addresses;

          Geocoder.local.findAddressesFromCoordinates(coordinates).then((value) {
            setState(() {
              addresses = value;

              Address address = addresses.first;

              country = address.countryName;
              locality = address.locality;
              adminArea = address.adminArea;

              UpdateCurrentWeather();
              print("Finished updating location");
              isUpdatingLocation = false;
            });
          });
        });
      });
    });
  }

  void UpdateCurrentWeather(){
    setState(() {
      isUpdatigCurrentWeather = true;
      print("Updating current weather");
      GetCurrentWeather(http.Client()).then((value) {
        setState(() {
          String weatherAPIResponce = value.body;
          var weatherJSON = json.decode(weatherAPIResponce);

          dynamic rain = (weatherJSON["rain"]);

          currentTemp = (weatherJSON['main']['temp'].toInt()).toString();
          currentWeatherDescription = (weatherJSON["weather"][0]["main"] as String);
          currentHumidity = (weatherJSON['main']['humidity']).toString() + '%';
          currentWindSpeed = (weatherJSON['wind']['speed']).toString() + ' m/s';
          currentPrecipitation = (rain == null ? 'None' : rain["1h"] + ' mm');

          currentSunrise = DateTime.fromMillisecondsSinceEpoch(
              ((weatherJSON["sys"]["sunrise"] as int) + (weatherJSON["timezone"] as int)) * 1000);

          currentSunset = DateTime.fromMillisecondsSinceEpoch(
              ((weatherJSON["sys"]["sunset"] as int) + (weatherJSON["timezone"] as int)) * 1000);

          bool nightTime = DateTime.now().difference(currentSunset).inMilliseconds > 0;

          String weatherConditionID = (weatherJSON["weather"][0]["id"] as int).toString();

          currentWeatherIconName = GetIconNameByCode(weatherConditionID, nightTime);

          print("Finished current weather");
          isUpdatigCurrentWeather = false;

          UpdateCurrentWeatherPreditions();
        });
      });
    });
  }

  void UpdateCurrentWeatherPreditions() {
    setState(() {
      Get5Day3HourPreditions(http.Client()).then((value) {
        setState(() {
          String weatherAPIResponce = value.body;
          dynamic weatherJSON = json.decode(weatherAPIResponce);

          List<dynamic> weatherPreditions = weatherJSON["list"];

          List<DayWeatherInfo> weatherInfos = [];

          for (int i = 0; i < weatherPreditions.length; ++i){

            DateTime time = DateTime.parse(weatherPreditions[i]["dt_txt"] as String);

            weatherInfos.add(DayWeatherInfo(
              (weatherPreditions[i]["main"]["temp_min"]).toInt(),
              (weatherPreditions[i]["main"]["temp_max"]).toInt(),
              (weatherPreditions[i]["main"]["temp"]).toInt(),
              (weatherPreditions[i]["main"]["humidity"]).toInt(),
              (weatherPreditions[i]["wind"]["speed"]).toDouble(),
              (weatherPreditions[i]["weather"][0]["id"]).toString(),
              null,
              null,
              time.hour,
              time,
            ));
          }

          for (int i = 0; i < currentWeatherInfoCount; ++i){
            weatherInfos[i].sunset = currentSunset;
            weatherInfos[i].sunrise = currentSunrise;
            currentWeatherInfos.add(weatherInfos[i]);
          }

          setState(() {

          });
        });
      });
    });
  }

  void initState(){
    super.initState();
    UpdateLocation();

    SystemChannels.lifecycle.setMessageHandler((msg){
      if(msg == AppLifecycleState.resumed.toString()){
        UpdateLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // BG
          Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/backgrounds/mountains.jpg',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: [
                      0.65,
                      1.0,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              )
            ],
          ),

          SafeArea(
            child: Column(
              children: <Widget>[

                // Top Buttons

                Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                    left: 10.0,
                  ),
                  child: Row(
                    children: [
                      // Today button
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 15.0,
                          right: 15.0,
                          bottom: 0.0,
                        ),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Today',
                              style: TextStyle(
                                color: currentInfo == WeatherInfo.Today ? Colors.white : Colors.black.withOpacity(ButtonOpacity),
                                fontFamily: 'HelveticaNeueLight',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          color: currentInfo == WeatherInfo.Today ? Colors.white.withOpacity(ButtonOpacity) : Colors.black.withOpacity(ButtonOpacity),
                          highlightColor: Colors.white.withOpacity(0.1),
                          splashColor: Colors.transparent,
                          onPressed: (){
                            if (SwitchToToday()){
                              setState(() {

                              });
                            }
                          }
                        ),
                      ),
                      // Week button
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          top: 15.0,
                          right: 15.0,
                          bottom: 0.0,
                        ),
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Week',
                                style: TextStyle(
                                  color: currentInfo == WeatherInfo.Week ? Colors.white : Colors.black.withOpacity(ButtonOpacity),
                                  fontFamily: 'HelveticaNeueLight',
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            color: currentInfo == WeatherInfo.Week ? Colors.white.withOpacity(ButtonOpacity) : Colors.black.withOpacity(ButtonOpacity),
                            highlightColor: Colors.white.withOpacity(0.1),
                            splashColor: Colors.transparent,
                            onPressed: (){
                              if (SwitchToWeek()){
                                setState(() {

                                });
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 8,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Location Text
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                          ),
                          child:
                          Align(
                            alignment: Alignment.centerLeft,
                            child: !isUpdatingLocation ?
                            Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: locality,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'HelveticaNeueLight',
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: adminArea + ', ' + country,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(TextOpacity),
                                          fontFamily: 'HelveticaNeueLight',
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            )
                                :
                            CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),

                        // Weather Description with Icon & Temperature
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 15.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: <Widget>[
                                // Icon, Temperature
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: <Widget>[
                                      // Icon
                                      Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: ExactAssetImage('assets/weather-icons/' + currentWeatherIconName + '.png'),
                                              fit: BoxFit.fill
                                          ),
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),


                                      // Current Temperature
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 20.0,
                                          right: 5.0,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            text: currentTemp,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'HelveticaNeueLight',
                                              fontSize: 65.0,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),

                                      FlatButton(
                                        padding: EdgeInsets.only(right: 15.0),
                                        child: RichText(
                                          text: TextSpan(
                                            text: '°C',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'HelveticaNeueLight',
                                              fontSize: 65.0,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        onPressed: (){},
                                      ),

                                      //Container(
                                      //  width: 1,
                                      //  height: 65.0,
                                      //  color: Colors.white.withOpacity(TextOpacity),
                                      //),
//
                                      //FlatButton(
                                      //  padding: EdgeInsets.only(right: 15.0, left: 15.0),
                                      //  child: RichText(
                                      //    text: TextSpan(
                                      //      text: '°F',
                                      //      style: TextStyle(
                                      //        color: Colors.white.withOpacity(TextOpacity),
                                      //        fontFamily: 'HelveticaNeueLight',
                                      //        fontSize: 65.0,
                                      //        fontWeight: FontWeight.w300,
                                      //        letterSpacing: 0.0,
                                      //      ),
                                      //    ),
                                      //  ),
                                      //  onPressed: (){},
                                      //),
                                    ],
                                  ),
                                ),

                                // Weather Description
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        text: currentWeatherDescription,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'HelveticaNeueLight',
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info for Today & Week
                Expanded(
                  flex: 16,
                  child: Container(
                    child: PageView(
                      controller: bottomPartPageController,
                      children: <Widget>[
                        CurrentDayInfo(startTimeHour: startTimeHour, TextOpacity: TextOpacity, ButtonOpacity: ButtonOpacity,
                        humidity: currentHumidity, windSpeed: currentWindSpeed, percipitation: currentPrecipitation,
                        weatherInfos: currentWeatherInfos,),
                        CurrentWeekInfo(ButtonOpacity: ButtonOpacity),
                      ],
                      physics: BouncingScrollPhysics(),
                      onPageChanged: (int index) {
                        if (index == 0) {
                          currentInfo = WeatherInfo.Today;
                          setState(() {

                          });
                        } else if (index == 1) {
                          currentInfo = WeatherInfo.Week;
                          setState(() {

                          });
                        }
                      },
                    ),
                  )
                ),
              ],
            ),
          )
        ]
      ),
    );
  }
}
