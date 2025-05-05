import 'package:flutter/material.dart';

void main() {
  runApp(FlutterApp());
}

class FlutterApp extends StatelessWidget {
  final ValueNotifier<bool> _dark = ValueNotifier<bool>(true);
  final ValueNotifier<double> _widthFactor = ValueNotifier<double>(1.0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ValueListenableBuilder<bool>(
            valueListenable: _dark,
            builder: (context, color, child) {
              return ValueListenableBuilder<double>(
                valueListenable: _widthFactor,
                builder: (context, factor, child) {
                  return Scaffold(
                      backgroundColor:
                          _dark.value ? Colors.black : Colors.white,
                      appBar: AppBar(
                        actions: [
                          Switch(
                            value: _dark.value,
                            onChanged: (value) {
                              _dark.value = value;
                            },
                          ),
                          DropdownButton<double>(
                            value: _widthFactor.value,
                            onChanged: (value) {
                              _widthFactor.value = value!;
                            },
                            items: [
                              DropdownMenuItem<double>(
                                value: 0.5,
                                child: Text('Size: 50%'),
                              ),
                              DropdownMenuItem<double>(
                                value: 0.75,
                                child: Text('Size: 75%'),
                              ),
                              DropdownMenuItem<double>(
                                value: 1.0,
                                child: Text('Size: 100%'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      body: Center(
                          child: Container(
                        width: MediaQuery.of(context).size.width *
                            _widthFactor.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MapAccomdationRoute(),
                          ],
                        ),
                      )));
                },
              );
            }));
  }
}

class MapAccomdationRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(44),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: 0,
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 121,
                top: 799,
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 24,
                    right: 18.67,
                    bottom: 11,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.only(top: 1),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 54,
                                height: 20,
                                child: Text(
                                  '9:41',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'SF Pro Text',
                                    height: 0.09,
                                    letterSpacing: -0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 211.67),
                      Container(
                        width: 66.66,
                        height: 11.34,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 42.33,
                              top: 0,
                              child: Container(
                                width: 24.33,
                                height: 11.33,
                                child: Stack(children: [
                                ,
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 749,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Text(
                          '🏠',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.07,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 14,
                        child: Text(
                          'AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            height: 0.14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 79,
                top: 749,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Color(0x00D9D9D9)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Text(
                          '🗺️',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.07,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 14,
                        child: Text(
                          'Map(Acc/Route)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            height: 0.14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 151,
                top: 749,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Text(
                          '🏠',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0x00D9D9D9),
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.07,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 14,
                        child: Text(
                          'Home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0x00D9D9D9),
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            height: 0.14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 223,
                top: 749,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Text(
                          '👥',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.07,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 14,
                        child: Text(
                          'Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            height: 0.14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 295,
                top: 749,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Text(
                          'ℹ️',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.07,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 14,
                        child: Text(
                          'More',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontFamily: 'Roboto',
                            height: 0.14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 57,
                top: 200,
                child: Container(
                  width: 264,
                  height: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4, left: 2, bottom: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFE8DEF8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 57,
                top: 200,
                child: Container(
                  width: 191,
                  height: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 4, left: 2, bottom: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: ShapeDecoration(
                                  color: Color(0xFF00C7BE),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 91,
                top: 50,
                child: Container(
                  height: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Welcome, Pilgrim!           Day 3',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            height: 0.09,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Plan your Santiago pilgrimage journey with ease',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            height: 0.11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 31,
                top: 46,
                child: Container(
                  width: 44,
                  height: 43,
                  padding: const EdgeInsets.all(1),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: Colors.black.withOpacity(0.75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 41,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage("https://picsum.photos/42/41"),
                            fit: BoxFit.fill,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                top: 141,
                child: Container(
                  width: 342,
                  padding: const EdgeInsets.only(bottom: 62),
                  decoration: BoxDecoration(color: Color(0x00523C3C)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 342,
                        height: 42,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 187,
                              top: 0,
                              child: SizedBox(
                                width: 155,
                                height: 40,
                                child: Text(
                                  'Roncesvalles',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    height: 0.05,
                                    letterSpacing: 0.36,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 1,
                              child: SizedBox(
                                width: 138,
                                height: 39,
                                child: Text(
                                  'Saint Jean',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    height: 0.05,
                                    letterSpacing: 0.36,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 138,
                              top: 1,
                              child: Container(
                                width: 49,
                                height: 41,
                                padding: const EdgeInsets.only(
                                  top: 10.25,
                                  left: 17.54,
                                  right: 16.33,
                                  bottom: 10.25,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  ,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 232,
                top: 233,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                  child: Container(
                    width: 30,
                    height: 28,
                    padding: const EdgeInsets.only(
                      top: 7,
                      left: 10.74,
                      right: 10,
                      bottom: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      ,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 31,
                top: 107,
                child: Text(
                  'Today’s Stage:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto Condensed',
                    height: 0.09,
                  ),
                ),
              ),
              Positioned(
                left: 22,
                top: 97,
                child: Container(
                  width: 338,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFF979797),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                top: 243,
                child: Container(
                  width: 338,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFF979797),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 352,
                child: Container(
                  width: 341,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFF979797),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 21,
                top: 196,
                child: Text(
                  '0km',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Mouse Memoirs',
                    height: 0.09,
                    letterSpacing: 0.36,
                  ),
                ),
              ),
              Positioned(
                left: 329,
                top: 198,
                child: Text(
                  '33.5km',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Mouse Memoirs',
                    height: 0.09,
                    letterSpacing: 0.36,
                  ),
                ),
              ),
              Positioned(
                left: 230,
                top: 223,
                child: Text(
                  '24.8km',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Mouse Memoirs',
                    height: 0.09,
                    letterSpacing: 0.36,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 623,
                child: Container(
                  width: 348,
                  height: 103,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 348,
                          height: 103,
                          decoration: ShapeDecoration(
                            color: Color(0x19080808),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 13,
                        top: 11,
                        child: Container(
                          width: 323,
                          height: 52,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 204,
                                top: 0,
                                child: Opacity(
                                  opacity: 0.85,
                                  child: Container(
                                    width: 119,
                                    height: 24,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.only(top: 3, left: 2, right: 2, bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              ,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 24,
                                          top: 0,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.only(top: 3, left: 2, right: 2, bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              ,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 95,
                                          top: 0,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.only(top: 3, left: 2, right: 2, bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              ,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 72,
                                          top: 0,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.only(top: 3, left: 2, right: 2, bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              ,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 48,
                                          top: 0,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.only(top: 3, left: 2, right: 2, bottom: 2),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                              ,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 4,
                                child: Text(
                                  'Difficulty:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto',
                                    height: 0.05,
                                    letterSpacing: 0.36,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 99,
                                top: 4,
                                child: Text(
                                  '(Moderate)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    height: 0.06,
                                    letterSpacing: 0.36,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 32,
                                child: Container(
                                  width: 241,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Text(
                                          'Duration:',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            height: 0.05,
                                            letterSpacing: 0.36,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 97,
                                        top: 0,
                                        child: Text(
                                          '7 Hours & 35 Min',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontFamily: 'Roboto',
                                            height: 0.06,
                                            letterSpacing: 0.36,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 13,
                        top: 71,
                        child: Text(
                          'Terrain:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            height: 0.05,
                            letterSpacing: 0.36,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 94,
                        top: 71,
                        child: Text(
                          'Rocky, Steep',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            height: 0.06,
                            letterSpacing: 0.36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 243,
                child: Opacity(
                  opacity: 0.88,
                  child: Container(
                    width: 336,
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    'Recommended Route',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                      height: 0.07,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 19,
                top: 283,
                child: Opacity(
                  opacity: 0.88,
                  child: Container(
                    width: 336,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.black.withOpacity(0.10000000149011612),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          'Route 1',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontFamily: 'Roboto',
                                            height: 0.11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 24,
                                        child: Text(
                                          'Distance: 20km, Terrain: Moderate, Est. Time: 5 days',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            height: 0.09,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.black.withOpacity(0.10000000149011612),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          'Route 2',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontFamily: 'Roboto',
                                            height: 0.11,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 24,
                                        child: Text(
                                          'Distance: 30km, Terrain: Difficult, Est. Time: 7 days',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            height: 0.09,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 21,
                top: 384,
                child: Container(
                  width: 338,
                  height: 37.96,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 39,
                          height: 37.96,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 39,
                                  height: 37.96,
                                  decoration: ShapeDecoration(
                                    shape: OvalBorder(
                                      side: BorderSide(width: 3, color: Color(0xFF007AFF)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 7.80,
                                top: 7.59,
                                child: Container(
                                  width: 23.40,
                                  height: 22.78,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF007AFF),
                                    shape: OvalBorder(
                                      side: BorderSide(width: 3, color: Color(0xFF007AFF)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 97,
                        top: 4,
                        child: Opacity(
                          opacity: 0.80,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              shape: OvalBorder(side: BorderSide(width: 3)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 193,
                        top: 4,
                        child: Opacity(
                          opacity: 0.80,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              shape: OvalBorder(side: BorderSide(width: 3)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 289,
                        top: 4,
                        child: Opacity(
                          opacity: 0.80,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: ShapeDecoration(
                              shape: OvalBorder(side: BorderSide(width: 3)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 11,
                        top: 10,
                        child: Container(
                          width: 17,
                          height: 17,
                          padding: const EdgeInsets.only(
                            top: 1.42,
                            left: 2.13,
                            right: 2.12,
                            bottom: 1.42,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            ,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                top: 360,
                child: Text(
                  'Town',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Righteous',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 207,
                top: 362,
                child: Text(
                  'Town',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Righteous',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 296,
                top: 364,
                child: Text(
                  'Statue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Righteous',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 104,
                top: 362,
                child: Text(
                  'Church',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Righteous',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 123,
                top: 393,
                child: Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 2.50, vertical: 0.83),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    ,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 315,
                top: 393,
                child: Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 2.50, vertical: 0.83),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    ,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 70,
                top: 388,
                child: Text(
                  '2.5km',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Rethink Sans',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 262,
                top: 388,
                child: Text(
                  '6.1km',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Rethink Sans',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 166,
                top: 388,
                child: Text(
                  '3.1km',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Rethink Sans',
                    height: 0,
                  ),
                ),
              ),
              Positioned(
                left: 13,
                top: 436,
                child: Container(
                  width: 348,
                  height: 172,
                  decoration: ShapeDecoration(
                    color: Color(0x8C080808),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 122,
                top: 467,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                  child: Container(
                    width: 30,
                    height: 28,
                    padding: const EdgeInsets.only(
                      top: 7,
                      left: 10.74,
                      right: 10,
                      bottom: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      ,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 438,
                child: Container(
                  width: 344,
                  height: 168,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://picsum.photos/344/168"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 119,
                top: 531,
                child: Text(
                  '▲ 650m, Climb \n▼ 300m, Decent ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    height: 0.06,
                    letterSpacing: 0.36,
                  ),
                ),
              ),
              Positioned(
                left: 122,
                top: 467,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57),
                  child: Container(
                    width: 30,
                    height: 28,
                    padding: const EdgeInsets.only(
                      top: 7,
                      left: 10.74,
                      right: 10,
                      bottom: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      ,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 365,
                top: 567,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  child: Container(
                    width: 30,
                    height: 28,
                    padding: const EdgeInsets.only(
                      top: 7,
                      left: 10.74,
                      right: 10,
                      bottom: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      ,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}