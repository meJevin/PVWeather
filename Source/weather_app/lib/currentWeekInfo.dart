
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentWeekInfo extends StatelessWidget {
  const CurrentWeekInfo({
    Key key,
    @required this.ButtonOpacity,
  }) : super(key: key);

  final double ButtonOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            child: Row(
              children: <Widget>[
                // Day of week
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: DateFormat('EEEE').format(DateTime.now().add(Duration(days: index))),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'HelveticaNeueLight',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                Expanded(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: ExactAssetImage('assets/weather-icons/clear.png'),
                                  fit: BoxFit.fill
                              ),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "3°",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'HelveticaNeueLight',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "3°",
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
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
            ),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(ButtonOpacity),
            ),
          );
        },
        itemCount: 7,
        physics: BouncingScrollPhysics(),
      ),
    );
  }
}