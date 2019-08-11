
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/weatherInfoSmall.dart';
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
    @required this.onRefreshFunc,
  }) : super(key: key);

  final int startTimeHour;
  final double TextOpacity;
  final double ButtonOpacity;

  final String humidity;
  final String windSpeed;
  final String percipitation;

  final Function onRefreshFunc;


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
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: widget.onRefreshFunc,
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

                // Hourly weather predictions

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30,
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
          ],
        )
      ),
    );
  }
}
