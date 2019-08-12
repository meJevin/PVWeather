import 'dart:math';

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
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'messageHandler.dart';

enum WeatherInfo { Today, Week }

enum ErrorType { Network, GeoLocation, NetworkAPI }

class LocationInfo {
  LocationInfo(
    this.coordinates,
    this.name,
    this.selected,
      this.ID
  );

  Coordinates coordinates;
  String name;
  bool selected;
  String ID;
}

List<Coordinates> debugCoords = [
  Coordinates(55.837013, 37.936152), // Me
  Coordinates(49.835099, 24.013943), // Lviv
  Coordinates(30.301202, -97.7162647), // Austin
  Coordinates(37.178451, -93.274921), // Springfield
];

void main() => runApp(MyApp());

String GetIconNameByCode(String weatherConditionID, bool isNightTime) {
  int conditionNumerical = int.parse(weatherConditionID);

  // Look at https://openweathermap.org/weather-conditions

  if (conditionNumerical >= 200 && conditionNumerical <= 232) {
    // Thunder
    if (conditionNumerical == 211 ||
        conditionNumerical == 212 ||
        conditionNumerical == 232) {
      return "thunder";
    } else {
      return "cloudy";
    }
  } else if (conditionNumerical >= 300 && conditionNumerical <= 321) {
    // Drizzle
    if (conditionNumerical == 302 ||
        conditionNumerical == 311 ||
        conditionNumerical == 312) {
      return "rain";
    } else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  } else if (weatherConditionID.startsWith('5')) {
    // Rain
    if (conditionNumerical == 502 ||
        conditionNumerical == 503 ||
        conditionNumerical == 504 ||
        conditionNumerical == 511 ||
        conditionNumerical == 522) {
      return "rain";
    } else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  } else if (weatherConditionID.startsWith('6')) {
    // Snow
    if (conditionNumerical == 601 ||
        conditionNumerical == 602 ||
        conditionNumerical == 616 ||
        conditionNumerical == 622) {
      return "snow";
    } else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  } else if (weatherConditionID.startsWith('7')) {
    if (conditionNumerical == 701 || conditionNumerical == 741) {
      return "cloudy";
    } else {
      if (isNightTime) {
        return "partly-cloudy-night";
      } else {
        return "partly-cloudy";
      }
    }
  } else if (weatherConditionID == "800") {
    // Clear
    if (isNightTime) {
      // Clear night
      return "clear-night";
    } else {
      // Clear day
      return "clear";
    }
  } else if (weatherConditionID == "801" || weatherConditionID == "802") {
    // Partly cloudy
    if (isNightTime) {
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

    DateTime fakeSunset = DateTime(
        timeToCheck.year,
        timeToCheck.month,
        timeToCheck.day,
        sunset.hour,
        sunset.minute,
        sunset.second,
        sunset.millisecond,
        sunset.microsecond);
    DateTime fakeSunrise = DateTime(
        timeToCheck.year,
        timeToCheck.month,
        timeToCheck.day,
        sunrise.hour,
        sunrise.minute,
        sunrise.second,
        sunrise.millisecond,
        sunrise.microsecond);

    int diffFromSunset = timeToCheck.difference(fakeSunset).inMilliseconds;
    int diffFromSunrise = timeToCheck.difference(fakeSunrise).inMilliseconds;

    if (diffFromSunrise < 0 && diffFromSunset < 0) {
      return true;
    } else {
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
        canvasColor: Color.fromARGB(55, 0, 0, 0),
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
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  List<LocationInfo> currentLocationInfos = [
    LocationInfo(null, "Your location", true, null),
    //LocationInfo(debugCoords[1], "Lviv", false),
    //LocationInfo(debugCoords[2], "Austin", false),
    //LocationInfo(debugCoords[3], "Springfield", false),
  ];

  String todayString;
  String weekString;
  String currentPlaceString;

  List<String> mainUnexpectedMessages = List<String>();
  List<String> mainUnexpectedMessagesGeolocation = List<String>();

  Locale currentLocale;

  Location location = Location();
  Coordinates userCoords;
  Coordinates customCoords;

  String country = '';
  String adminArea = '';
  String locality = '';

  final double ButtonOpacity = 0.05;
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

  bool isUpdatingInfo = false;

  bool infoUpdateFailed = false;

  ErrorType currentError = null;

  String prevState = "";

  FirebaseConnector connector;

  // For week
  List<WeekDayWeatherInfo> weekWeatherInfos = [];

  final PageController bottomPartPageController = PageController();
  WeatherInfo currentInfo = WeatherInfo.Today;

  Curve automaticPageTransitionCurve = Curves.fastOutSlowIn;

  bool SwitchToToday() {
    if (bottomPartPageController.page == 0) {
      return false;
    } else {
      bottomPartPageController.animateToPage(0,
          curve: automaticPageTransitionCurve,
          duration: Duration(milliseconds: 400));
    }

    return true;
  }

  bool SwitchToWeek() {
    if (bottomPartPageController.page == 1) {
      return false;
    } else {
      bottomPartPageController.animateToPage(1,
          curve: automaticPageTransitionCurve,
          duration: Duration(milliseconds: 400));
    }

    return true;
  }

  Future<Coordinates> GetLocation() async {
    //await Future.delayed(Duration(seconds: 5));
    var currentLocation = <String, double>{};

    currentLocation = await location.getLocation().catchError((e) {
      currentLocation = null;
      return;
    });

    if (currentLocation == null) {
      return null;
    }

    //return debugCoords[1];
    return Coordinates(
        currentLocation["latitude"], currentLocation["longitude"]);
  }

  Future<http.Response> GetCurrentWeather(http.Client client) async {
    //await Future.delayed(Duration(seconds: 5));
    return client.get('http://api.openweathermap.org/data/2.5/weather?lat=' +
        userCoords.latitude.toString() +
        '&lon=' +
        userCoords.longitude.toString() +
        '&appid=' +
        weatherAPIKey +
        '&mode=json&units=metric&lang=' +
        currentLocale.toString());
  }

  Future<http.Response> Get5Day3HourPreditions(http.Client client) async {
    return client.get('http://api.openweathermap.org/data/2.5/forecast?lat=' +
        userCoords.latitude.toString() +
        '&lon=' +
        userCoords.longitude.toString() +
        '&appid=' +
        weatherAPIKey +
        '&mode=json&units=metric&lang=' +
        currentLocale.toString());
  }

  Future<Null> UpdateLocation() async {
    isUpdatingInfo = true;
    infoUpdateFailed = false;

    print("Updating location");
    setState(() {
      GetLocation().then((value) {
        if (value != null) {
          setState(() {
            userCoords = value;

            if (customCoords != null) {
              userCoords = customCoords;
            }

            Coordinates coordinates = userCoords;
            print("Coordinates: " +
                coordinates.latitude.toString() +
                ", " +
                coordinates.longitude.toString());
            List<Address> addresses;

            Geocoder.local
                .findAddressesFromCoordinates(coordinates)
                .then((value) {
              setState(() {
                addresses = value;

                Address address = addresses.first;

                country = address.countryName;
                locality = address.locality == null
                    ? address.featureName
                    : address.locality;
                adminArea = address.adminArea;

                UpdateCurrentWeather();
                print("Finished updating location");
              });
            }).catchError((e) {
              print("Could not get address info from coordinates!");
              setState(() {
                isUpdatingInfo = false;
                infoUpdateFailed = true;
                currentError = ErrorType.Network;
              });
              return;
            });
          });
        } else {
          setState(() {
            infoUpdateFailed = true;
            isUpdatingInfo = false;
            currentError = ErrorType.GeoLocation;
          });
          return;
        }
      });
    });

    setState(() {
      currentInfo = WeatherInfo.Today;
    });
  }

  Future<Null> UpdateCurrentWeather() async {
    setState(() {
      print("Updating current weather");
      GetCurrentWeather(http.Client()).then((value) {
        setState(() {
          String weatherAPIResponce = value.body;
          var weatherJSON = json.decode(weatherAPIResponce);

          dynamic rain = (weatherJSON["rain"]);

          currentTemp = (weatherJSON['main']['temp'].toInt()).toString();
          currentWeatherDescription =
              capitalize((weatherJSON["weather"][0]["description"] as String));
          currentHumidity = (weatherJSON['main']['humidity']).toString() + '%';
          currentWindSpeed = (weatherJSON['wind']['speed']).toString() + ' m/s';
          currentPrecipitation = (rain == null ? 'None' : rain["1h"] + ' mm');

          currentSunrise = DateTime.fromMillisecondsSinceEpoch(
              ((weatherJSON["sys"]["sunrise"] as int) +
                      (weatherJSON["timezone"] as int)) *
                  1000);

          currentSunset = DateTime.fromMillisecondsSinceEpoch(
              ((weatherJSON["sys"]["sunset"] as int) +
                      (weatherJSON["timezone"] as int)) *
                  1000);

          bool nightTime =
              DateTime.now().difference(currentSunset).inMilliseconds > 0;

          String weatherConditionID =
              (weatherJSON["weather"][0]["id"] as int).toString();

          currentWeatherIconName =
              GetIconNameByCode(weatherConditionID, nightTime);

          print("Finished current weather");

          UpdateCurrentWeatherPreditions();
        });
      }).catchError((e) {
        print("Could not get info from API!");
        setState(() {
          isUpdatingInfo = false;
          infoUpdateFailed = true;
          currentError = ErrorType.NetworkAPI;
        });
        return;
      });
    });
  }

  Future<Null> UpdateCurrentWeatherPreditions() async {
    setState(() {
      Get5Day3HourPreditions(http.Client()).then((value) {
        setState(() {
          String weatherAPIResponce = value.body;
          dynamic weatherJSON = json.decode(weatherAPIResponce);

          List<dynamic> weatherPreditions = weatherJSON["list"];

          List<DayWeatherInfo> weatherInfos = [];

          for (int i = 0; i < weatherPreditions.length; ++i) {
            DateTime time =
                DateTime.parse(weatherPreditions[i]["dt_txt"] as String);

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

          for (int i = 0; i < currentWeatherInfoCount; ++i) {
            currentWeatherInfos.add(weatherInfos[i]);
          }

          weekWeatherInfos.clear();

          for (int i = 0; i < weatherInfos.length;) {
            List<DayWeatherInfo> dayWeatherInfo = [];

            int currDay = weatherInfos[i].date.day;
            while (i < weatherInfos.length &&
                currDay == weatherInfos[i].date.day) {
              dayWeatherInfo.add(weatherInfos[i]);

              ++i;
            }

            if (dayWeatherInfo.length > 0) {
              weekWeatherInfos.add(
                  WeekDayWeatherInfo.FromDayWeatherInfoList(dayWeatherInfo));
            }
          }

          setState(() {
            isUpdatingInfo = false;
          });
        });
      });
    });
  }

  void initState() {
    super.initState();

    mainUnexpectedMessages.add('Whoops!');
    mainUnexpectedMessages.add('Whoa!');
    mainUnexpectedMessages.add('Whoa, an error!');
    mainUnexpectedMessages.add("That's weird...");
    mainUnexpectedMessages.add("Umhh...");
    mainUnexpectedMessages.add("Aw, man!");

    mainUnexpectedMessagesGeolocation.add("Where are you?");
    mainUnexpectedMessagesGeolocation.add("Can't find you!");
    mainUnexpectedMessagesGeolocation.add("Playing hide and seek?");

    connector = FirebaseConnector(currentLocationInfos: currentLocationInfos);

    connector.Init().then((val) {
      connector.GetUserPlaces();

      UpdateLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    currentLocale = Localizations.localeOf(context);

    if (currentLocale.toString().contains("ru")) {
      todayString = "Сегодня";
      weekString = "Неделя";
      currentPlaceString = "Моя позиция";
    } else {
      todayString = "Today";
      weekString = "Week";
      currentPlaceString = "Current position";
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Stack(fit: StackFit.expand, children: [
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
          // Location info
          child: Builder(builder: (BuildContext context) {
            // If we're not updating info show current location info
            if (!isUpdatingInfo && !infoUpdateFailed) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      onRefresh: UpdateCurrentWeather,
                      displacement: 0.25,
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Container(
                          height: 9999, // XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD ЕБАТЬ Я ГЕНИЙ УБЕЙТЕ МЕНЯ
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        // Top Buttons
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 5.0,
                            left: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? 1
                                    : 0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? 10
                                          : 25),
                                  child: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? CurrentDayShortInfo(
                                          locality: locality,
                                          adminArea: adminArea,
                                          country: country,
                                          TextOpacity: TextOpacity,
                                          currentWeatherIconName:
                                              currentWeatherIconName,
                                          currentTemp: currentTemp,
                                          currentWeatherDescription:
                                              currentWeatherDescription)
                                      : Container(
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
                                            color: currentInfo ==
                                                    WeatherInfo.Today
                                                ? Colors.white
                                                : Colors.black
                                                    .withOpacity(ButtonOpacity),
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    color: currentInfo == WeatherInfo.Today
                                        ? Colors.white
                                            .withOpacity(ButtonOpacity)
                                        : Colors.black
                                            .withOpacity(ButtonOpacity),
                                    highlightColor:
                                        Colors.white.withOpacity(0.1),
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      if (SwitchToToday()) {
                                        setState(() {});
                                      }
                                    }),
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
                                            color: currentInfo ==
                                                    WeatherInfo.Week
                                                ? Colors.white
                                                : Colors.black
                                                    .withOpacity(ButtonOpacity),
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    color: currentInfo == WeatherInfo.Week
                                        ? Colors.white
                                            .withOpacity(ButtonOpacity)
                                        : Colors.black
                                            .withOpacity(ButtonOpacity),
                                    highlightColor:
                                        Colors.white.withOpacity(0.1),
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      if (SwitchToWeek()) {
                                        setState(() {});
                                      }
                                    }),
                              ),

                              MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? Padding(
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
                                              Scaffold.of(context)
                                                  .openEndDrawer();
                                            },
                                            icon: Icon(Icons.menu,
                                                size: 30, color: Colors.white),
                                          );
                                        },
                                      ),
                                    )
                                  : Expanded(
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
                                                  Scaffold.of(context)
                                                      .openEndDrawer();
                                                },
                                                icon: Icon(Icons.menu,
                                                    size: 30,
                                                    color: Colors.white),
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
                          flex: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 8
                              : 0,
                          child: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? CurrentDayShortInfo(
                                  locality: locality,
                                  adminArea: adminArea,
                                  country: country,
                                  TextOpacity: TextOpacity,
                                  currentWeatherIconName:
                                      currentWeatherIconName,
                                  currentTemp: currentTemp,
                                  currentWeatherDescription:
                                      currentWeatherDescription)
                              : Container(
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
                                  CurrentDayInfo(
                                    startTimeHour: startTimeHour,
                                    TextOpacity: TextOpacity,
                                    ButtonOpacity: ButtonOpacity,
                                    humidity: currentHumidity,
                                    windSpeed: currentWindSpeed,
                                    percipitation: currentPrecipitation,
                                    weatherInfos: currentWeatherInfos,
                                    onRefreshFunc: UpdateCurrentWeather,
                                  ),
                                  CurrentWeekInfo(
                                    ButtonOpacity: ButtonOpacity,
                                    TextOpacity: TextOpacity,
                                    weatherInfos: weekWeatherInfos,
                                    onRefreshFunc: UpdateCurrentWeather,
                                  ),
                                ],
                                physics: BouncingScrollPhysics(),
                                onPageChanged: (int index) {
                                  if (index == 0) {
                                    setState(() {
                                      currentInfo = WeatherInfo.Today;
                                    });
                                  } else if (index == 1) {
                                    setState(() {
                                      currentInfo = WeatherInfo.Week;
                                    });
                                  }
                                },
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              );
            } else if (isUpdatingInfo && !infoUpdateFailed) {
              // If we're loading
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                ],
              );
            } else if (!isUpdatingInfo && infoUpdateFailed) {
              String mainErrorMessage = "";
              String auxErrorMessage = "";

              if (currentError == ErrorType.GeoLocation) {
                mainErrorMessage = mainUnexpectedMessagesGeolocation[
                    Random().nextInt(mainUnexpectedMessagesGeolocation.length)];
                auxErrorMessage =
                    "Make sure you've enabled geolocation permission for this application";
              } else if (currentError == ErrorType.Network) {
                mainErrorMessage = mainUnexpectedMessages[
                    Random().nextInt(mainUnexpectedMessages.length)];
                auxErrorMessage =
                    "Couldn't retreive location data from your coordinates. Check your internet connection";
              } else if (currentError == ErrorType.NetworkAPI) {
                mainErrorMessage = mainUnexpectedMessages[
                    Random().nextInt(mainUnexpectedMessages.length)];
                auxErrorMessage =
                    "Weather forecast API endpoint is not responding. Check your internet connection";
              }

              return Container(
                //color: Colors.blue.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Main Error Message
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 15),
                      child: RichText(
                        text: TextSpan(
                          text: mainErrorMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HelveticaNeue',
                            fontSize: 46.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Separator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        height: 1,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15),
                      child: RichText(
                        text: TextSpan(
                          text: auxErrorMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HelveticaNeue',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Container(
                      width: 100,
                      child: FlatButton(
                        onPressed: () {
                          UpdateLocation();
                        },
                        color: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'HelveticaNeue',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        )
      ]),
      endDrawer: LocationDrawer(
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
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: locality,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HelveticaNeue',
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
                        text: (adminArea == null ? '' : (adminArea + ', ')) +
                            country,
                        style: TextStyle(
                          color: Colors.white.withOpacity(TextOpacity),
                          fontFamily: 'HelveticaNeue',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ])),
          ),

          // Weather Description with Icon & Temperature
          Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              left: 10.0,
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
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: ExactAssetImage(
                                      'assets/weather-icons/' +
                                          currentWeatherIconName +
                                          '.png'),
                                  fit: BoxFit.fill),
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
                                  fontFamily: 'HelveticaNeue',
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
                              fontFamily: 'HelveticaNeue',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class LocationDrawer extends StatefulWidget {
  final Function updateLocationFunction;

  final _MyHomePageState homePageState;

  LocationDrawer({
    Key key,
    @required this.updateLocationFunction,
    @required this.homePageState,
  }) : super(key: key);

  @override
  _LocationDrawerState createState() => _LocationDrawerState();
}

class _LocationDrawerState extends State<LocationDrawer> {

  TextEditingController countrySearchTextEditingController = TextEditingController();

  String countrySearchString = "";
  List<LocationInfo> searchResultLocationInfos = List<LocationInfo>();

  ScrollController drawerListViewController;

  FocusNode myFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    searchResultLocationInfos.addAll(widget.homePageState.currentLocationInfos);
    myFocusNode = FocusNode();

    drawerListViewController = ScrollController();
    drawerListViewController.addListener((){
      FocusScope.of(context).requestFocus(new FocusNode());
      setState(() {

      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    countrySearchTextEditingController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  void LoadLocationInfo(LocationInfo info) {
    setState(() {
      widget.homePageState.customCoords = info.coordinates;
      widget.updateLocationFunction();
      widget.homePageState.currentInfo = WeatherInfo.Today;
    });
  }

  void QuerySearch() {
    searchResultLocationInfos.clear();

    if (countrySearchString == "") {
      searchResultLocationInfos.addAll(widget.homePageState.currentLocationInfos);
      return;
    }

    for (int i = 1; i < widget.homePageState.currentLocationInfos.length; ++i) {
      // Check if current location info has something suitable
      if (widget.homePageState.currentLocationInfos[i].name.toLowerCase().contains(countrySearchString.toLowerCase())) {
        searchResultLocationInfos.add(widget.homePageState.currentLocationInfos[i]);
      }
    }
  }

  void AddRandomLocationInfo() {
    List<LocationInfo> temp = [
      LocationInfo(debugCoords[1], "Lviv", false, null),
      LocationInfo(debugCoords[2], "Austin", false, null),
      LocationInfo(debugCoords[3], "Springfield", false, null),
    ];

    LocationInfo newLoc = temp[Random().nextInt(temp.length)];

    widget.homePageState.connector.AddUserPlace(newLoc);

    setState(() {
      searchResultLocationInfos.clear();
      searchResultLocationInfos.addAll(widget.homePageState.currentLocationInfos);
    });
  }

  void SelectLocation(LocationInfo location) {
    if (location.selected) {
      return;
    }

    setState(() {
      for (int i = 0; i < widget.homePageState.currentLocationInfos.length; ++i) {
        if (location == widget.homePageState.currentLocationInfos[i]) {
          widget.homePageState.currentLocationInfos[i].selected = true;
          LoadLocationInfo(widget.homePageState.currentLocationInfos[i]);
        } else {
          widget.homePageState.currentLocationInfos[i].selected = false;
        }
      }
    });

    //Navigator.pop(context);
  }

  void ClearSearch() {
    setState(() {
      countrySearchTextEditingController.clear();
      countrySearchString = "";
      QuerySearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 0,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Upper search bar
              Container(

                child: Row(
                  children: <Widget>[
                    // Search icon
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white.withOpacity(0.85)),
                      iconSize: 20,
                      splashColor: Colors.transparent,
                    ),

                    // Country input field
                    Expanded(
                      child: TextField(

                        controller: countrySearchTextEditingController,

                        focusNode: myFocusNode,
                        onTap: () {
                          FocusScope.of(context).requestFocus(myFocusNode);
                          setState(() {

                          });
                        },

                        onSubmitted: (String text) {
                          setState(() {
                            countrySearchString = text;
                            QuerySearch();
                          });
                        },

                        onChanged: (String text) {
                          setState(() {
                            countrySearchString = text;
                            QuerySearch();
                          });
                          print(text);
                        },

                        keyboardAppearance: Brightness.dark,

                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontFamily: 'HelveticaNeue',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontFamily: 'HelveticaNeue',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w300,
                        ),
                        cursorColor: Colors.white,
                      ),
                    ),

                    // Clear icon builder

                    Builder(
                      builder: (BuildContext context) {
                        if (countrySearchTextEditingController.text.length > 0) {
                          return IconButton(
                            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.85)),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            iconSize: 20,
                            onPressed: () {
                              ClearSearch();
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),

                    // Cancel button
                    Builder(
                      builder: (BuildContext context) {
                        if (myFocusNode.hasFocus) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                ClearSearch();
                              },
                              child: Container(
                                color: Colors.black.withOpacity(0.35),
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontFamily: 'HelveticaNeue',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                AddRandomLocationInfo();
                              },
                              child: Icon(Icons.add, color: Colors.white)
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              ),

              // Bottom list view with user places from firebase
              Expanded(
                flex: 4,
                child: Builder(
                  builder: (BuildContext context){
                    if (countrySearchString != "" && searchResultLocationInfos.length == 0) {

                      return Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text('No results!',
                                style:  TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            )
                          ],
                        ),
                      );

                    }
                    else {
                      // Search results from current location infos
                      return ListView.builder(

                        controller: drawerListViewController,

                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),

                        padding: EdgeInsets.zero,

                        itemCount: searchResultLocationInfos.length,
                        itemBuilder: (BuildContext contextB, int index) {

                          if (searchResultLocationInfos[index].coordinates == null) {
                            // Current location
                            return DrawerSelectableLocation(
                                isSelected: searchResultLocationInfos[index].selected,
                                name:  searchResultLocationInfos[index].name,
                                OnTap:  () {
                                  SelectLocation(searchResultLocationInfos[index]);
                                },
                              trailingIcon: Icon(Icons.location_on, color: Colors.white,),
                              itemID: searchResultLocationInfos[index].ID,
                              homePageState: widget.homePageState,
                            );
                          }
                          else {
                            return DrawerSelectableLocation(
                                isSelected: searchResultLocationInfos[index].selected,
                                name:  searchResultLocationInfos[index].name,
                                OnTap:  () {
                                  SelectLocation(searchResultLocationInfos[index]);
                                },
                              itemID: searchResultLocationInfos[index].ID,
                              homePageState: widget.homePageState,
                              dismissed: () {
                                setState(() {
                                  widget.homePageState.connector.RemoveUserPlace(searchResultLocationInfos[index].ID);
                                });
                                QuerySearch();
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                )
              ),
            ],
          ),
        ));
  }
}

class DrawerSelectableLocation extends StatefulWidget {

  final bool isSelected;
  final String name;
  final Function OnTap;
  final Icon trailingIcon;
  final String itemID;
  final _MyHomePageState homePageState;
  final Function dismissed;

  DrawerSelectableLocation({
    Key key,
    @required this.isSelected,
    @required this.name,
    @required this.OnTap,
    this.trailingIcon,
    this.itemID,
    this.homePageState,
    this.dismissed,
  }) : super(key: key);

  @override
  _DrawerSelectableLocationState createState() => _DrawerSelectableLocationState();
}

class _DrawerSelectableLocationState extends State<DrawerSelectableLocation> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Color.fromARGB(85, 0, 0, 0)
            : Color.fromARGB(0, 0, 0, 0),
      ),
      child: Dismissible(
        key: Key(widget.itemID),
        onDismissed: (direction) {
          widget.dismissed();
        },
        confirmDismiss: (direction) async {
          if (widget.dismissed == null) {
            return false;
          }
          else {
            return true;
          }
        },
        child: ListTile(
          trailing: widget.trailingIcon,
          title: Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.name,
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.65),
                fontFamily: 'HelveticaNeue',
                fontSize: 18.0,
                fontWeight: widget.isSelected
                    ? FontWeight.w500
                    : FontWeight.w300,
              ),
            ),
          ),
          onTap: () {
            widget.OnTap();
          },
        ),
      ),
    );
  }
}
