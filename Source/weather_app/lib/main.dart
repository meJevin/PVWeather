import 'package:flutter/material.dart';

import 'currentDayInfo.dart';
import 'currentWeekInfo.dart';

import 'package:location/location.dart';

import 'package:geocoder/geocoder.dart';


enum WeatherInfo { Today, Week }


void main() => runApp(MyApp());

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
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  var location = new Location();
  Map<String, double> userLocation;

  final double ButtonOpacity = 0.25;
  final double TextOpacity = 0.5;

  final int startTimeHour = DateTime.now().hour;
  final int startWeekDay = DateTime.now().weekday;

  final PageController bottomPartPageController = PageController(
    initialPage: 0,
  );

  WeatherInfo currentInfo = WeatherInfo.Today;

  bool SwitchToToday(){
    if (bottomPartPageController.page == 0) {
      return false;
    }
    else {
      bottomPartPageController.animateToPage(0, curve: Curves.easeInOut, duration: Duration(milliseconds: 400));
    }

    return true;
  }

  bool SwitchToWeek(){
    if (bottomPartPageController.page == 1) {
      return false;
    }
    else {
      bottomPartPageController.animateToPage(1, curve: Curves.easeInOut, duration: Duration(milliseconds: 400));
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

  @override
  Widget build(BuildContext context) {

    GetLocation().then((value) {
      setState(() {
        userLocation = value;

        Coordinates coordinates = Coordinates(userLocation["latitude"], userLocation["longitude"]);
        List<Address> addresses;

        Geocoder.local.findAddressesFromCoordinates(coordinates).then((value) {
          addresses = value;

          print(addresses.first.countryName + ", " + addresses.first.featureName);
        });
      });
    });


    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

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

          Column(
            children: <Widget>[

              // Top Buttons

              Padding(
                padding: const EdgeInsets.only(
                  top: 25.0,
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
                              color: currentInfo == WeatherInfo.Today ? Colors.black : Colors.black.withOpacity(ButtonOpacity),
                              fontFamily: 'HelveticaNeueLight',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        color: currentInfo == WeatherInfo.Today ? Colors.white : Colors.white.withOpacity(ButtonOpacity),
                        highlightColor: currentInfo == WeatherInfo.Today ? Colors.white : Colors.white.withOpacity(ButtonOpacity),
                        splashColor: Colors.grey,
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
                              color: currentInfo == WeatherInfo.Week ? Colors.black : Colors.black.withOpacity(ButtonOpacity),
                              fontFamily: 'HelveticaNeueLight',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        color: currentInfo == WeatherInfo.Week ? Colors.white : Colors.white.withOpacity(ButtonOpacity),
                        highlightColor: currentInfo == WeatherInfo.Week ? Colors.white : Colors.white.withOpacity(ButtonOpacity),
                        splashColor: Colors.grey,
                        onPressed: (){
                          if (SwitchToWeek()){
                            setState(() {

                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Location Text

              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  top: 85.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            text: 'Aspen',
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
                            text: 'Colorado, USA',
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
                                  image: ExactAssetImage('assets/weather-icons/windy.png'),
                                  fit: BoxFit.fill
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                left: 20.0,
                                right: 5.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '2',
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

                            Container(
                              width: 1,
                              height: 65.0,
                              color: Colors.white.withOpacity(TextOpacity),
                            ),

                            FlatButton(
                              padding: EdgeInsets.only(right: 15.0, left: 15.0),
                              child: RichText(
                                text: TextSpan(
                                  text: '°F',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(TextOpacity),
                                    fontFamily: 'HelveticaNeueLight',
                                    fontSize: 65.0,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                              onPressed: (){},
                            ),
                          ],
                        ),
                      ),

                      // Weather Description
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          bottom: 20.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              text: 'Windy',
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


              // Info for 'Today' tab
              Expanded(
                child: PageView(
                  controller: bottomPartPageController,
                  children: <Widget>[
                    CurrentDayInfo(startTimeHour: startTimeHour, TextOpacity: TextOpacity, ButtonOpacity: ButtonOpacity),
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
                )
              ),
            ],
          )
        ]
      ),
    );
  }
}
