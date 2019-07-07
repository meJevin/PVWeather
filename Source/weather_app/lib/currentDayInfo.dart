
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class CurrentDayInfo extends StatefulWidget {
  CurrentDayInfo({
    Key key,
    @required this.startTimeHour,
    @required this.TextOpacity,
    @required this.ButtonOpacity,
    @required this.humidity,
    @required this.windSpeed,
    @required this.percipitation,
    @required this.weatherInfos,
  }) : super(key: key);

  final int startTimeHour;
  final double TextOpacity;
  final double ButtonOpacity;

  final String humidity;
  final String windSpeed;
  final String percipitation;

  List<DayWeatherInfo> weatherInfos;

  @override
  _CurrentDayInfoState createState() => _CurrentDayInfoState();
}

class _CurrentDayInfoState extends State<CurrentDayInfo> {
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
                      itemCount: widget.weatherInfos.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return new WeatherInfoSmall(
                          timeHour: widget.weatherInfos[index].hourOfDay,
                          TextOpacity: widget.TextOpacity,
                          temp: widget.weatherInfos[index].temp,
                          iconName: GetIconNameByCode(widget.weatherInfos[index].weatherCode,
                              widget.weatherInfos[index].IsNightTimeAt(widget.weatherInfos[index].hourOfDay)),
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

class WeatherInfoSmall extends StatefulWidget {
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
  _WeatherInfoSmallState createState() => _WeatherInfoSmallState();
}

class _WeatherInfoSmallState extends State<WeatherInfoSmall> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      color: Colors.transparent,
      child: Center(
        child: Column(
          children: <Widget>[
            // Time
            RichText(
              text: TextSpan(
                text: (widget.timeHour).toString() + ':00',
                style: TextStyle(
                  color: Colors.white.withOpacity(widget.TextOpacity),
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
                      image: ExactAssetImage('assets/weather-icons/' + widget.iconName + '.png'),
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
                  text: widget.temp.toString() + '°',
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