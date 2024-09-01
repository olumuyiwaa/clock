// ignore_for_file: prefer_const_constructors

import 'package:clock_app/components/bottom_cards.dart';

import 'components/analog_clock.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'components/leap_year_compass.dart';

void main() {
  runApp(const Clock());
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime _currentTime = DateTime.now();
  int monthvalue = DateTime.now().month;
  int weekdayvalue = DateTime.now().weekday;

  List<String> monthsnames = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
  List<String> weekdaynames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  String get monthName => monthsnames[monthvalue - 1];
  String get weekdayName => weekdaynames[weekdayvalue - 1];

  String nextNewMoonDay = '';
  String nextFullMoonDay = '';
  String lastNewMoonDay = '';
  String lastFullMoonDay = '';
  String nextNewMoonMonth = '';
  String nextFullMoonMonth = '';
  String lastNewMoonMonth = '';
  String lastFullMoonMonth = '';

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
        monthvalue = _currentTime.month;
        weekdayvalue = _currentTime.weekday;

        _updateFullMoonDates();
      });
    });
  }

  int _getNextLeapYear(int currentYear) {
    int year = currentYear;
    while (!(year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))) {
      year++;
    }
    return year;
  }

  void _updateFullMoonDates() {
    // Get the current date
    DateTime today = DateTime.now();

    // Define the average lunar cycle duration in days
    const double lunarCycle = 29.53059;

    // Calculate the days since the last known new moon
    DateTime knownNewMoon =
        DateTime(2024, 3, 10); // Example of a known new moon date
    int daysSinceNewMoon = today.difference(knownNewMoon).inDays;

    // Calculate the number of cycles since the known new moon
    int cyclesSinceNewMoon = (daysSinceNewMoon / lunarCycle).floor();

    // Calculate the last new moon date
    DateTime lastNewMoon = knownNewMoon
        .add(Duration(days: (cyclesSinceNewMoon * lunarCycle).toInt()));

    // Calculate the next new moon date
    DateTime nextNewMoon = knownNewMoon
        .add(Duration(days: ((cyclesSinceNewMoon + 1) * lunarCycle).toInt()));

    // Calculate the days since the last known full moon
    DateTime knownFullMoon =
        DateTime(2024, 7, 21); // Example of a known full moon date
    int daysSinceFullMoon = today.difference(knownFullMoon).inDays;

    // Calculate the number of cycles since the known full moon
    int cyclesSinceFullMoon = (daysSinceFullMoon / lunarCycle).floor();

    // Calculate the next full moon date
    DateTime nextFullMoon = knownFullMoon
        .add(Duration(days: ((cyclesSinceFullMoon + 1) * lunarCycle).toInt()));

    // Calculate the last full moon date
    DateTime lastFullMoon = knownFullMoon
        .add(Duration(days: (cyclesSinceFullMoon * lunarCycle).toInt()));

    // Update the date variables
    nextNewMoonMonth = monthsnames[nextNewMoon.month - 1];
    nextNewMoonDay = '${nextNewMoon.day}';
    lastNewMoonMonth = monthsnames[lastNewMoon.month - 1];
    lastNewMoonDay = '${lastNewMoon.day}';
    nextFullMoonMonth = monthsnames[nextFullMoon.month - 1];
    nextFullMoonDay = '${nextFullMoon.day}';
    lastFullMoonMonth = monthsnames[lastFullMoon.month - 1];
    lastFullMoonDay = '${lastFullMoon.day}';
  }

  int _getMoonPhase(DateTime date) {
    const double fullMoonCycle =
        29.53058867; // Average length of lunar cycle in days
    final DateTime referenceNewMoon =
        DateTime(2024, 10, 2); // Known new moon date
    final double daysSinceReference =
        date.difference(referenceNewMoon).inDays.toDouble();

    final double daysSinceNewMoon = daysSinceReference % fullMoonCycle;

    // Return an integer representing the moon phase
    // 0 = New Moon, 1 = Waxing Crescent, 2 = First Quarter, 3 = Waxing Gibbous,
    // 4 = Full Moon, 5 = Waning Gibbous, 6 = Last Quarter, 7 = Waning Crescent
    return ((daysSinceNewMoon / (fullMoonCycle / 8)).floor() % 8).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final moonPhase = _getMoonPhase(_currentTime);

    final isAM = _currentTime.hour < 12;
    final isPM = _currentTime.hour >= 12;
    final amPmText = isAM
        ? Text(
            "AM",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
            ),
          )
        : Text(
            "AM",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          );
    final pmAmText = isPM
        ? Text(
            "PM",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
            ),
          )
        : Text(
            "PM",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(
            Icons.menu,
            color: Colors.orangeAccent,
          ),
          title: const Text(
            'Time',
            style: TextStyle(color: Colors.orangeAccent),
          ),
          backgroundColor: const Color(0xFF2A292A),
        ),
        backgroundColor: const Color(0xFF2A292A),
        body: Column(
          children: [
            Container(
              height: .5,
              color: Colors.orangeAccent,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: Colors.orangeAccent,
                            size: 16,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            _currentTime.timeZoneName,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [amPmText, pmAmText],
                          ),
                          SizedBox(width: 12),
                          Text(
                            "${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 80,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  _currentTime.second
                                      .toString()
                                      .padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  _currentTime.millisecond
                                      .toString()
                                      .padLeft(3, '0'),
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Text(
                        "ATOMIC TIME SYNCED",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                  Container(
                    height: .5,
                    color: Colors.orangeAccent,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${_currentTime.toUtc().hour.toString().padLeft(2, '0')}:${_currentTime.toUtc().minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const Text(
                              "UTC",
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: .5,
                          height: 78,
                          color: Colors.orangeAccent,
                        ),
                        Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${_getNextLeapYear(DateTime.now().year + 1)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                const Text(
                                  "NEXT LEAP YEAR",
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            LeapYearCompass(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: .5,
                    color: Colors.orangeAccent,
                  ),
                  AnalogClock(moonPhase: moonPhase),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomCards(
                    lastTitle: 'Last',
                    nextTitle: 'Next',
                    icon: 'new_moon.png',
                    lastMonth: lastNewMoonMonth,
                    lastDay: lastNewMoonDay,
                    nextMonth: nextNewMoonMonth,
                    nextDay: nextNewMoonDay),
                SizedBox(
                  width: 72,
                ),
                //------------------
                BottomCards(
                    lastTitle: 'Last',
                    nextTitle: 'Next',
                    icon: 'full_moon.png',
                    lastMonth: lastFullMoonMonth,
                    lastDay: lastFullMoonDay,
                    nextMonth: nextFullMoonMonth,
                    nextDay: nextFullMoonDay)
              ],
              //------------------
            ),
          ],
        ),
      ),
    );
  }
}
