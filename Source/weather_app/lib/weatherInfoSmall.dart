
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                  fontFamily: 'HelveticaNeue',
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
                    fontFamily: 'HelveticaNeue',
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