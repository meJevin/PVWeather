import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'currentDayInfo.dart';
import 'currentWeekInfo.dart';

import 'dart:async';
import 'dart:convert';

import 'package:location/location.dart';

import 'package:geocoder/geocoder.dart';

import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:http/http.dart' as http;

enum WeatherInfo { Today, Week }

class LocationInfo{
  LocationInfo(
      this.coordinates,
      this.name,
      this.selected,
      );

  Coordinates coordinates;
  String name;
  bool selected;
}

List<Coordinates> debugCoords = [
  Coordinates(55.837013, 37.936152), // Me
  Coordinates(49.835099, 24.013943), // Lviv
  Coordinates(30.301202, -97.7162647), // Austin
  Coordinates(37.178451, -93.274921), // Springfield
];

List<LocationInfo> debugLocationInfos = [
  LocationInfo(null, "Current", true),
  LocationInfo(debugCoords[1], "Lviv", false),
  LocationInfo(debugCoords[2], "Austin", false),
  LocationInfo(debugCoords[3], "Springfield", false),
];

void main() => runApp(MyApp());

String GetIconNameByCode(String weatherConditionID, bool isNightTime){
  int conditionNumerical = int.parse(weatherConditionID);

  // Look at https://openweathermap.org/weather-conditions

  if (conditionNumerical >= 200 && conditionNumerical <= 232){
    // Thunder
    if (conditionNumerical == 211
    || conditionNumerical == 212
    || conditionNumerical == 232) {
      return "thunder";
    }
    else {
      return "cloudy";
    }
  }
  else if (conditionNumerical >= 300 && conditionNumerical <= 321) {
    // Drizzle
    if (conditionNumerical == 302
        || conditionNumerical == 311
        || conditionNumerical == 312) {
      return "rain";
    }
    else {
      if (isNightTime){
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  }
  else if (weatherConditionID.startsWith('5')) {
    // Rain
    if (conditionNumerical == 502
        || conditionNumerical == 503
        || conditionNumerical == 504
        || conditionNumerical == 511
        || conditionNumerical == 522) {
      return "rain";
    }
    else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  }
  else if (weatherConditionID.startsWith('6')){
    // Snow
    if (conditionNumerical == 601
        || conditionNumerical == 602
        || conditionNumerical == 616
        || conditionNumerical == 622) {
      return "snow";
    }
    else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  }
  else if (weatherConditionID.startsWith('7')){
    if (conditionNumerical == 701
        || conditionNumerical == 741) {
      return "cloudy";
    }
    else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  }
  else if (weatherConditionID == "800"){
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
      theme: new ThemeData(
        dividerColor: Colors.transparent,
        canvasColor: Color.fromARGB(180, 85, 85, 85),
      ),
      home: MyHomePage(),
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ru'), // Russian
        // ... other locales the app supports
      ],
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

  String todayString;
  String weekString;

  Locale currentLocale;

  Location location = Location();
  Coordinates userCoords;
  Coordinates customCoords;

  String country = '';
  String adminArea = '';
  String locality = '';

  final double ButtonOpacity = 0.1;
  final double TextOpacity = 0.5;

  final int startTimeHour = DateTime.now().hour;
  final int startWeekDay = DateTime.now().weekday;

  final String weatherAPIKey = '4e2b4a7ea0807694fe91fae168ba5cd2';

  // For today

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

  // For week
  List<WeekDayWeatherInfo> weekWeatherInfos = [];

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

  Future<Coordinates> GetLocation() async {
    //await Future.delayed(Duration(seconds: 5));
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    //return debugCoords[1];
    return Coordinates(currentLocation["latitude"], currentLocation["longitude"]);
  }

  Future<http.Response> GetCurrentWeather(http.Client client) async {
    //await Future.delayed(Duration(seconds: 5));
    return client.get('http://api.openweathermap.org/data/2.5/weather?lat=' +
        userCoords.latitude.toString() + '&lon=' +
        userCoords.longitude.toString() + '&appid=' +
        weatherAPIKey + '&mode=json&units=metric&lang=' +
        currentLocale.toString());
  }

  Future<http.Response> Get5Day3HourPreditions(http.Client client) async {
    return client.get('http://api.openweathermap.org/data/2.5/forecast?lat=' +
        userCoords.latitude.toString() + '&lon=' +
        userCoords.longitude.toString() + '&appid=' +
        weatherAPIKey + '&mode=json&units=metric&lang=' +
        currentLocale.toString());
  }

  Future<Null> UpdateLocation() async {
    setState(() {
      print("Updating location");
      GetLocation().then((value) {
        setState(() {
          userCoords = value;

          if (customCoords != null) {
            userCoords = customCoords;
          }

          Coordinates coordinates = userCoords;
          print("Coordinates: " + coordinates.latitude.toString() + ", " + coordinates.longitude.toString());
          List<Address> addresses;

          Geocoder.local.findAddressesFromCoordinates(coordinates).then((value) {
            setState(() {
              addresses = value;

              Address address = addresses.first;

              country = address.countryName;
              locality = address.locality == null ? address.featureName : address.locality;
              adminArea = address.adminArea;

              UpdateCurrentWeather();
              print("Finished updating location");
            });
          });
        });
      });
    });
  }

  void UpdateCurrentWeather() async {
    setState(() {
      print("Updating current weather");
      GetCurrentWeather(http.Client()).then((value) {
        setState(() {
          String weatherAPIResponce = value.body;
          var weatherJSON = json.decode(weatherAPIResponce);

          dynamic rain = (weatherJSON["rain"]);

          currentTemp = (weatherJSON['main']['temp'].toInt()).toString();
          currentWeatherDescription = capitalize((weatherJSON["weather"][0]["description"] as String));
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

          UpdateCurrentWeatherPreditions();
        });
      });
    });
  }

  void UpdateCurrentWeatherPreditions() async {
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
              currentSunset,
              currentSunrise,
              time.hour,
              time,
            ));
          }

          currentWeatherInfos.clear();

          for (int i = 0; i < currentWeatherInfoCount; ++i){
            currentWeatherInfos.add(weatherInfos[i]);
          }

          weekWeatherInfos.clear();

          for (int i = 0; i < weatherInfos.length;){
            List<DayWeatherInfo> dayWeatherInfo = [];

            int currDay = weatherInfos[i].date.day;
            while (i < weatherInfos.length && currDay == weatherInfos[i].date.day){
              dayWeatherInfo.add(weatherInfos[i]);

              ++i;
            }

            if (dayWeatherInfo.length > 0){
              weekWeatherInfos.add(WeekDayWeatherInfo.FromDayWeatherInfoList(dayWeatherInfo));
            }
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

    currentLocale = Localizations.localeOf(context);

    if (currentLocale.toString().contains("ru")) {
      todayString = "Сегодня";
      weekString = "Неделя";
    }
    else {
      todayString = "Today";
      weekString = "Week";
    }

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
                    mainAxisAlignment: MediaQuery.of(context).orientation == Orientation.landscape ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: MediaQuery.of(context).orientation == Orientation.landscape ? 1 : 0,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).orientation == Orientation.landscape ? 10 : 25
                          ),
                          child: MediaQuery.of(context).orientation == Orientation.landscape ?
                          CurrentDayShortInfo(
                              locality: locality,
                              adminArea: adminArea,
                              country: country,
                              TextOpacity: TextOpacity,
                              currentWeatherIconName: currentWeatherIconName,
                              currentTemp: currentTemp,
                              currentWeatherDescription: currentWeatherDescription
                          )
                          :
                          Container(
                            width: 0,
                            height: 0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
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
                                text: todayString,
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
                                text: weekString,
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

                      MediaQuery.of(context).orientation == Orientation.landscape ?
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          top: 15.0,
                          right: 15.0,
                          bottom: 0.0,
                        ),
                        child: Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                              alignment: Alignment.center,
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              icon: Icon(
                                  Icons.menu,
                                  size: 30,
                                  color: Colors.white
                              ),
                            );
                          },
                        ),
                      )
                      :
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 5.0,
                              top: 15.0,
                              right: 15.0,
                              bottom: 0.0,
                            ),
                            child: Builder(
                              builder: (BuildContext context) {
                                return IconButton(
                                  alignment: Alignment.center,
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  icon: Icon(
                                      Icons.menu,
                                      size: 30,
                                      color: Colors.white
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: MediaQuery.of(context).orientation == Orientation.portrait ? 8 : 0,
                  child: MediaQuery.of(context).orientation == Orientation.portrait ?
                  CurrentDayShortInfo(
                      locality: locality,
                      adminArea: adminArea,
                      country: country,
                      TextOpacity: TextOpacity,
                      currentWeatherIconName: currentWeatherIconName,
                      currentTemp: currentTemp,
                      currentWeatherDescription: currentWeatherDescription
                  )
                  :
                  Container(
                    width: 0,
                    height: 0,
                    color: Colors.blue,
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
                        CurrentWeekInfo(ButtonOpacity: ButtonOpacity, TextOpacity: TextOpacity, weatherInfos: weekWeatherInfos, onRefreshFunc: UpdateLocation,),
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

      endDrawer: LocationDrawer(
        locationInfos: debugLocationInfos,
        updateLocationFunction: UpdateLocation,
        homePageState: this,
      ),
    );
  }
}

class CurrentDayShortInfo extends StatelessWidget {
  const CurrentDayShortInfo({
    Key key,
    @required this.locality,
    @required this.adminArea,
    @required this.country,
    @required this.TextOpacity,
    @required this.currentWeatherIconName,
    @required this.currentTemp,
    @required this.currentWeatherDescription,
  }) : super(key: key);

  final String locality;
  final String adminArea;
  final String country;
  final double TextOpacity;
  final String currentWeatherIconName;
  final String currentTemp;
  final String currentWeatherDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child:
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
                            text: (adminArea == null ? '' : (adminArea + ', ')) + country,
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
            ),
          ),

          // Weather Description with Icon & Temperature
          Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              left: 10.0,
            ),
            child: Align(
                alignment: Alignment.centerLeft,
                child:
                Column(
                  children: <Widget>[
                    // Icon, Temperature
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          // Icon
                          Container(
                            width: 75,
                            height: 75,
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
                                text: currentTemp + '°C',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'HelveticaNeueLight',
                                  fontSize: 75.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
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
                )
            ),
          ),
        ],
      ),
    );
  }
}

class LocationDrawer extends StatefulWidget {

  final List<LocationInfo> locationInfos;

  final Function updateLocationFunction;

  final _MyHomePageState homePageState;

  LocationDrawer({
    Key key,
    @required this.locationInfos,
    @required this.updateLocationFunction,
    @required this.homePageState,
  }) : super(key: key);

  @override
  _LocationDrawerState createState() => _LocationDrawerState();
}

class _LocationDrawerState extends State<LocationDrawer> {

  void LoadLocationInfo(LocationInfo info) {
    setState(() {
      widget.homePageState.customCoords = info.coordinates;
      widget.updateLocationFunction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Color.fromARGB(155, 35, 35, 35),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 25,
                  bottom: 25,
                  right: 15,
                ),
                child: Text(
                  'Места',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'HelveticaNeueLight',
                    fontSize: 35.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.zero,
                itemCount: widget.locationInfos.length,
                itemBuilder: (BuildContext contextB, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: widget.locationInfos[index].selected ? Color.fromARGB(185, 165, 165, 165) : Color.fromARGB(185, 45, 45, 45),
                    ),
                    child: ListTile(
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.locationInfos[index].name,
                          style: TextStyle(
                            color: widget.locationInfos[index].selected ? Colors.white : Colors.white.withOpacity(0.65),
                            fontFamily: 'HelveticaNeueLight',
                            fontSize: 18.0,
                            fontWeight: widget.locationInfos[index].selected ? FontWeight.w400 : FontWeight.w300,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          for (int i = 0; i < widget.locationInfos.length; ++i) {
                            if (i == index) {
                              widget.locationInfos[i].selected = true;
                              LoadLocationInfo(widget.locationInfos[i]);
                            }
                            else {
                              widget.locationInfos[i].selected = false;
                            }
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}

