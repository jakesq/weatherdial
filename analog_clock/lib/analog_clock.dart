// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'package:flutter/painting.dart';
import 'face.dart';

import 'container_hand.dart';

import 'dart:ui';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Color filterColour = Colors.white.withAlpha(65);
    // controls the tint of the animated background filter
    Color clockColour = Colors.white.withAlpha(20);
    // controls the outer clock ring
    Color accentColour = Colors.black;
    // controls details such as second indicators and clock hands

    String daylightCondition = 'light';
    // used to convert brightness state for dynamic background usage

    if (Theme.of(context).brightness == Brightness.dark) {
      filterColour = Colors.black.withAlpha(25);
      clockColour = Colors.black;
      accentColour = Colors.white;
      daylightCondition = 'dark';
    } else if (Theme.of(context).brightness == Brightness.light) {
      filterColour = Colors.white.withAlpha(25);
      clockColour = Colors.white;
      accentColour = Colors.black;
      daylightCondition = 'light';
    }

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                width: 5,
                color: Colors.black,
              ),
              image: DecorationImage(
                image: AssetImage(
                  'assets/'+_condition+'_'+daylightCondition+'.gif',
                  // takes a combinatinon of the weather condition and brightness (simulated time of day)
                  // to select a suitable dynamic background
                  ),
                  fit: BoxFit.cover
              )
            ),
          ),
          BackdropFilter(
            // a frosted glass effect is utilised to focus user attention on the clock face
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                color: filterColour,
              ),
            ),
          ),
          Container(
            // easy method of creating a curved border, background blur causes an unpleasant 
            // gradient around the border
            width: _width,
            height: _height,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: Colors.black,
                    )
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      width: 5,
                      color: Colors.black,
                    )
                  ),
                )
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1/1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1/1,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(185)
                      ),
                      // placing the ClockDialPainter gives the clock a sense of elevation, and seperation
                      // from the background
                      child: Container(
                        decoration: BoxDecoration(
                          color: clockColour,
                          shape: BoxShape.circle
                        ),
                        padding: EdgeInsets.all(5),
                        child: CustomPaint(
                          painter: ClockDialPainter(accentColour: accentColour),
                        ),
                      ),
                    )
                  ),
                  Container(
                    // seperates the second indicators from the clock hands
                    width: 295,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withAlpha(40),
                    ),
                  ),
                  Transform.translate(
                    // simple date displayed at the bottom centre of clock face
                    offset: Offset(0.0,100.0),
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 22,
                          height: 22,
                          padding: EdgeInsets.only(bottom:2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(15),
                            border: Border(
                              top: BorderSide(
                                width: 3,
                                color: Colors.red,
                              )
                            )
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            DateTime.now().day.toString(),
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: accentColour
                            ),
                          ),
                        ),
                      )
                    )
                  ),
                  ContainerHand(
                    // minute hand
                    color: Colors.transparent,
                    size: 0.5,
                    angleRadians: _now.minute * radiansPerTick,
                    child: Transform.translate(
                      offset: Offset(0.0, -60.0),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: 430,
                        child: Card(
                          elevation: 3,
                          color: Colors.black,
                          child: Container(
                            width: 10,
                            height: 240,
                            decoration: BoxDecoration(
                              color: accentColour,
                            ),
                          ),
                        )
                      )
                    ),
                  ),
                  ContainerHand(
                    // hour hand
                    color: Colors.transparent,
                    size: 0.5,
                    angleRadians: _now.hour * radiansPerHour +
                        (_now.minute / 60) * radiansPerHour,
                    child: Transform.translate(
                      offset: Offset(0.0, -75.0),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: 230,
                        child: Card(
                          elevation: 3,
                          color: Colors.black,
                          child: Container(
                            width: 10,
                            height: 200,
                            decoration: BoxDecoration(
                              color: accentColour
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                  ContainerHand(
                    // second hand
                    color: Colors.transparent,
                    size: 0.630,
                    angleRadians: _now.second * radiansPerTick,
                    child: Transform.translate(
                      offset: Offset(0.0, -65),
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: 700,
                        child: Card(
                          color: Color(0xFFffb84d),
                          elevation: 3,
                          child: Container(
                            width: 5,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Color(0xFFffb84d),
                            ),
                          ),
                        )
                      )
                    ),
                  ),
                  Card(
                    // centre yellow circle, purely cosmetic
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(185)
                    ),
                    color: Color(0xFFffb84d),
                    elevation: 3,
                    child: Container(
                      height: 17,
                      width: 17,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFffb84d),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            // information card
            left: 10,
            bottom: 10,
            child: Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 1.5,
                    color: filterColour
                  )
                ),
                padding: EdgeInsets.only(
                  top:6,
                  left:6,
                  right:6,
                  bottom:3
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      // weather condition
                      _condition,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 6,
                    ),
                    Row(
                      // row containing current temperature and temperature range
                      children: <Widget>[
                        Text(
                          _temperature,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400
                          ),
                        ),
                        Container(
                          width: 5,
                          height: 15,
                          alignment: Alignment.center,
                        ),
                        Container(
                          height: 10,
                          child: Text(
                            _temperatureRange,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              fontSize: 10
                            ),
                          )
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 6,
                    ),
                    Text(
                      // user location
                      _location.toLowerCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ],
                )
              )
            )
          )
        ],
      )
    );
  }
}
