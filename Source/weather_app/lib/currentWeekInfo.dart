
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/weatherInfoSmall.dart';

import 'main.dart';

import 'dart:math';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class WeekDayWeatherInfo {
  int tempMin;
  int tempMax;

  String averageIconName;

  DateTime date;

  List<DayWeatherInfo> weatherInfo;

  WeekDayWeatherInfo.FromDayWeatherInfoList(List<DayWeatherInfo> list){

    if (list.length == 0){
      this.tempMin = 0;
      this.tempMax = 0;
      this.averageIconName = "windy";
      this.date = DateTime(1900);
      return;
    }

    weatherInfo = [];
    for (int i = 0; i < list.length; ++i){
      weatherInfo.add(list[i]);
    }

    int tempMinCurr = list[0].temp;
    int tempMaxCurr = tempMinCurr;

    Map<String, int> weatherIconNamesEncountered = Map<String, int>();
    for (int i = 0; i < list.length; ++i){
      if (list[i].temp < tempMinCurr){
        tempMinCurr = list[i].temp;
      }
      if (list[i].temp > tempMaxCurr){
        tempMaxCurr = list[i].temp;
      }

      String iconName = GetIconNameByCode(list[i].weatherCode, false);

      if (weatherIconNamesEncountered.containsKey(iconName)) {
        ++weatherIconNamesEncountered[iconName];
      }
      else {
        weatherIconNamesEncountered[iconName] = 0;
      }
    }

    String maxIconEncounter = "windy";
    int maxIconEncounterNum = -1;
    weatherIconNamesEncountered.forEach((String iconName, int encountered){
      if (encountered > maxIconEncounterNum) {
        maxIconEncounterNum = encountered;
        maxIconEncounter = iconName;
      }
    });

    this.tempMin = tempMinCurr;
    this.tempMax = tempMaxCurr;
    this.averageIconName = maxIconEncounter;
    this.date = list[0].date;
  }
}

class CurrentWeekInfo extends StatefulWidget {
  const CurrentWeekInfo({
    Key key,
    @required this.ButtonOpacity,
    @required this.TextOpacity,
    this.weatherInfos = const[],
    this.onRefreshFunc
  }) : super(key: key);

  final double ButtonOpacity;
  final double TextOpacity;

  final List<WeekDayWeatherInfo> weatherInfos;
  final Function onRefreshFunc;

  @override
  _CurrentWeekInfoState createState() => _CurrentWeekInfoState();
}

class _CurrentWeekInfoState extends State<CurrentWeekInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator (
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          itemBuilder: (BuildContext context, int index) {
            return ExpansionTile(
              trailing: Container(
                width: 0,
                height: 0,
              ),
              title: Container(
                height: 80,
                child: Row(
                  children: <Widget>[

                    // Day of week
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text:
                              capitalize(
                              DateFormat('EEEE',
                                  Localizations.localeOf(context).toString()).format(widget.weatherInfos[index].date)),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'HelveticaNeueLight',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[

                            // Icon
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: ExactAssetImage('assets/weather-icons/' +
                                        widget.weatherInfos[index].averageIconName  + '.png'),
                                    fit: BoxFit.fill
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            ),

                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[

                                  // Temperature max
                                  RichText(
                                    text: TextSpan(
                                      text: widget.weatherInfos[index].tempMax.toString() + "°",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'HelveticaNeueLight',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),


                                  // Temperature min
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: RichText(
                                      text: TextSpan(
                                        text: widget.weatherInfos[index].tempMin.toString() + "°",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(widget.TextOpacity),
                                          fontFamily: 'HelveticaNeueLight',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),

                  ],
                ),
              ),
              children: <Widget>[
                Container(
                  height: 125,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.weatherInfos[index].weatherInfo.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int indexHourWeather) {
                      return WeatherInfoSmall(
                        timeHour: widget.weatherInfos[index].weatherInfo[indexHourWeather].hourOfDay,
                        TextOpacity: 0.5,
                        temp: widget.weatherInfos[index].weatherInfo[indexHourWeather].temp,
                        iconName: GetIconNameByCode(widget.weatherInfos[index].weatherInfo[indexHourWeather].weatherCode,
                            widget.weatherInfos[index].weatherInfo[indexHourWeather].IsNightTimeAt(widget.weatherInfos[index].weatherInfo[indexHourWeather].hourOfDay)),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 25,
                      );
                    },
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(widget.ButtonOpacity),
              ),
            );
          },
          itemCount: widget.weatherInfos.length,
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
        ),
        onRefresh: widget.onRefreshFunc,
        displacement: 0,
        color: Colors.white,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}