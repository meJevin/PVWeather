
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';

import 'dart:math';

class WeekDayWeatherInfo {
  int tempMin;
  int tempMax;

  String averageIconName;

  DateTime date;

  WeekDayWeatherInfo.FromDayWeatherInfoList(List<DayWeatherInfo> list){

    if (list.length == 0){
      this.tempMin = 0;
      this.tempMax = 0;
      this.averageIconName = "windy";
      this.date = DateTime(1900);
      return;
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

class CurrentWeekInfo extends StatelessWidget {
  const CurrentWeekInfo({
    Key key,
    @required this.ButtonOpacity,
    this.weatherInfos = const[],
  }) : super(key: key);

  final double ButtonOpacity;

  final List<WeekDayWeatherInfo> weatherInfos;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator (
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              child: Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    
                    // Day of week
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: DateFormat('EEEE').format(weatherInfos[index].date),
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
                          children: <Widget>[

                            // Icon
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: ExactAssetImage('assets/weather-icons/' +
                                          weatherInfos[index].averageIconName  + '.png'),
                                      fit: BoxFit.fill
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            ),

                            // Temperature min
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: weatherInfos[index].tempMin.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'HelveticaNeueLight',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            // Temperature max
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: weatherInfos[index].tempMax.toString(),
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
                          mainAxisAlignment: MainAxisAlignment.end,
                        )
                    ),

                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
              ),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(ButtonOpacity),
              ),
            );
          },
          itemCount: weatherInfos.length,
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
        ),
        onRefresh: () { return Future.delayed(new Duration(seconds: 3)); },
        displacement: 0,
        color: Colors.white,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}