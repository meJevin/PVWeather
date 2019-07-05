
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentDayInfo extends StatelessWidget {
  const CurrentDayInfo({
    Key key,
    @required this.startTimeHour,
    @required this.TextOpacity,
    @required this.ButtonOpacity,
  }) : super(key: key);

  final int startTimeHour;
  final double TextOpacity;
  final double ButtonOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top:  45.0,
          left: 20.0,
        ),
        child: Column(
          children: <Widget>[

            // Humidity
            Padding(
              padding: const EdgeInsets.only(
                top: 0.0,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: ExactAssetImage('assets/other/humidity.png'),
                          fit: BoxFit.fill
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: '60%',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HelveticaNeueLight',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Wind speed
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: ExactAssetImage('assets/other/wind.png'),
                          fit: BoxFit.fill
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: '5.2 mph',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HelveticaNeueLight',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Precipitation
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: ExactAssetImage('assets/other/precipitation.png'),
                          fit: BoxFit.fill
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: '31 mm',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'HelveticaNeueLight',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hourly weather predictions
            Padding(
              padding: const EdgeInsets.only(
                top: 50,
                right: 20,
              ),
              child: Container(
                height: 125,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 25,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      color: Colors.transparent,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            // Time
                            RichText(
                              text: TextSpan(
                                text: ((startTimeHour+index) % 24).toString() + ':00',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(TextOpacity),
                                  fontFamily: 'HelveticaNeueLight',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            // Icon
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                              ),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: ExactAssetImage('assets/weather-icons/clear.png'),
                                      fit: BoxFit.fill
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            ),
                            // Temperature
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '13°',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'HelveticaNeueLight',
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Container(
                          height: 50,
                          width: 1,
                          color: Colors.white.withOpacity(ButtonOpacity),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}