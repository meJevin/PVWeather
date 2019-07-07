
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class CurrentDayInfo extends StatelessWidget {
  CurrentDayInfo({
    Key key,
    @required this.startTimeHour,
    @required this.TextOpacity,
    @required this.ButtonOpacity,
    @required this.humidity,
    @required this.windSpeed,
    @required this.percipitation,
    @required this.weatherInfos = const <DayWeatherInfo>[],
  }) : super(key: key);

  final int startTimeHour;
  final double TextOpacity;
  final double ButtonOpacity;

  final String humidity;
  final String windSpeed;
  final String percipitation;

  List<DayWeatherInfo> weatherInfos;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top:  45.0,
          left: 20.0,
          right: 20.0,
        ),
        child: Column(
          children: <Widget>[

            //Expanded(
            //  child: Container(
            //    child: Column(
            //      mainAxisAlignment: MainAxisAlignment.center,
            //      children: <Widget>[
            //        // Humidity
            //        Padding(
            //          padding: const EdgeInsets.symmetric(vertical: 10),
            //          child: Row(
            //            children: <Widget>[
            //              Container(
            //                width: 20,
            //                height: 20,
            //                decoration: BoxDecoration(
            //                  image: DecorationImage(
            //                      image: ExactAssetImage('assets/other/humidity.png'),
            //                      fit: BoxFit.fill
            //                  ),
            //                  shape: BoxShape.rectangle,
            //                ),
            //              ),
            //              Padding(
            //                padding: const EdgeInsets.only(
            //                  left: 15.0,
            //                ),
            //                child: RichText(
            //                  text: TextSpan(
            //                    text: humidity,
            //                    style: TextStyle(
            //                      color: Colors.white,
            //                      fontFamily: 'HelveticaNeueLight',
            //                      fontSize: 14.0,
            //                      fontWeight: FontWeight.w400,
            //                    ),
            //                  ),
            //                ),
            //              ),
            //            ],
            //          ),
            //        ),
            //        // Wind speed
            //        Padding(
            //          padding: const EdgeInsets.symmetric(vertical: 10),
            //          child: Row(
            //            children: <Widget>[
            //              Container(
            //                width: 20,
            //                height: 20,
            //                decoration: BoxDecoration(
            //                  image: DecorationImage(
            //                      image: ExactAssetImage('assets/other/wind.png'),
            //                      fit: BoxFit.fill
            //                  ),
            //                  shape: BoxShape.rectangle,
            //                ),
            //              ),
            //              Padding(
            //                padding: const EdgeInsets.only(
            //                  left: 15.0,
            //                ),
            //                child: RichText(
            //                  text: TextSpan(
            //                    text: windSpeed,
            //                    style: TextStyle(
            //                      color: Colors.white,
            //                      fontFamily: 'HelveticaNeueLight',
            //                      fontSize: 14.0,
            //                      fontWeight: FontWeight.w400,
            //                    ),
            //                  ),
            //                ),
            //              ),
            //            ],
            //          ),
            //        ),
            //      ],
            //    ),
            //  ),
            //),


            // Hourly weather predictions

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 40,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 125,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weatherInfos.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return new WeatherInfoSmall(
                          timeHour: weatherInfos[index].hourOfDay,
                          TextOpacity: TextOpacity,
                          temp: weatherInfos[index].temp,
                          iconName: GetIconNameByCode(weatherInfos[index].weatherCode,
                              weatherInfos[index].IsNightTimeAt(weatherInfos[index].hourOfDay)),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 25,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherInfoSmall extends StatelessWidget {
  const WeatherInfoSmall({
    Key key,
    @required this.timeHour,
    @required this.TextOpacity,
    @required this.temp,
    @required this.iconName,
  }) : super(key: key);

  final int timeHour;
  final int temp;
  final String iconName;
  final double TextOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      color: Colors.transparent,
      child: Center(
        child: Column(
          children: <Widget>[
            // Time
            RichText(
              text: TextSpan(
                text: (timeHour).toString() + ':00',
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
                      image: ExactAssetImage('assets/weather-icons/' + iconName + '.png'),
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
                  text: temp.toString() + '°',
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
  }
}