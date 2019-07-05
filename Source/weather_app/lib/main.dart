import 'package:flutter/material.dart';

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

  final double ButtonOpacity = 0.25;
  final double TextOpacity = 0.5;
  final int startTimeHour = 13;

  @override
  Widget build(BuildContext context) {

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
                              color: Colors.black,
                              fontFamily: 'HelveticaNeueLight',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        color: Colors.white,
                        highlightColor: Colors.white,
                        splashColor: Colors.grey,
                        onPressed: (){},
                      ),
                    ),
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
                              color: Colors.black.withOpacity(ButtonOpacity),
                              fontFamily: 'HelveticaNeueLight',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        color: Colors.white.withOpacity(ButtonOpacity),
                        highlightColor: Colors.white.withOpacity(ButtonOpacity),
                        splashColor: Colors.grey,
                        onPressed: (){},
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
                //child: ListView.separated(
                //  scrollDirection: Axis.horizontal,
                //  itemCount: 2,
                //  shrinkWrap: true,
                //  itemBuilder: (BuildContext context, int index) {
                //    if (index == 0) {
//
                //    } else if (index == 1) {
//
                //    }
                //  },
                //  separatorBuilder: (BuildContext context, int index) {
                //    return Container(
                //      height: 50,
                //      width: 50,
                //      child: Center(
                //        child: Container(
                //          height: 50,
                //          width: 1,
                //          color: Colors.white.withOpacity(ButtonOpacity),
                //        ),
                //      ),
                //    );
                //  },
                //),

                child: Container(
                  color: Colors.blue.withOpacity(0.35),
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
                ),
              ),


            ],
          )
        ]
      ),
    );
  }
}