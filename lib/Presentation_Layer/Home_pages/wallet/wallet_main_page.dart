import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/Wallet_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Wallet_Data_Repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:list_picker/list_picker.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  /*  WalletDataProvider _walletProvider =
      WalletDataProvider(database: LocalDbProvider.database!); */

  late WalletDataRepository _walletRepository =
      WalletDataRepository(database: LocalDbProvider.database!);
  //dbModel.WalletDatabase _walletRepository = dbModel.WalletDatabase();
  List<Color> gradientColors = [
    /* const Color(0xff23b6e6),
    const Color(0xff02d39a), */
    const Color.fromARGB(255, 255, 160, 0),
    Colors.orangeAccent.shade700
  ];
  ScrollController listScrollController = ScrollController();
  List<String> categories = const [
    "All",
    "None",
    "Snacks",
    "Clothes",
    "Fuel",
    "Grocery",
    "Health Care",
    "Lending",
    "Food",
    "Transportation",
    "Bills",
    "Shopping",
    "Rent",
    "Credit",
    "Enteratainment",
    "Monthly Subscription",
    "Car Related",
    "Technical Equipments",
  ];

  String selectedCategory = "All";

  bool showAvg = false;
  bool showYear = false;
  // double avgPerMonth = 0.0;
  @override
  void initState() {
    //_walletRepository = WalletDataRepository(walletProvider: _walletProvider);
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          context: context,
          ttle: "Wallet",
          italikTitle: true,
          fitTitle: true,
          showLeading: false,
          titleSpacing: 70,
          statusBarDark: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.all_inbox,
                size: 25,
                color: Colors.orangeAccent,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/ExpenseDetailPage",
                  /* MaterialPageRoute(
                    builder: (context) => const ExpenseDetails(),0, */
                ).then((value) {
                  setState(() {});
                });
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 2.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow

                      offset: Offset(
                        0.0, // Move to right 10  horizontally
                        1.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text(
                            "Showing   ",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 18),
                          ),
                          Text(
                            selectedCategory,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () async {
                                String? selected = await showPickerDialog(
                                  context: context,
                                  label: "Category",
                                  items: categories,
                                );
                                if (selected != null)
                                  selectedCategory = selected;
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.more_horiz_outlined,
                                color: Colors.blue,
                              )),
                        ],
                      ).paddingOnly(left: 10),
                    ),
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3.5,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2,
                          //  height: MediaQuery.of(context).size.height / 4,

                          child: graph(),
                        ),
                      ),
                    ),
                    totalSpent(),
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Transcations",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Latest",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(bottom: 4),
              transactions(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),
          child: const FaIcon(
            FontAwesomeIcons.plus,
            size: 30,
            color: Colors.black,
          ),
          onPressed: () {
            showBottomSheet();
            //open bottom sheet to add transactions
          },
        ),
      ),
    );
  }

  showBottomSheet() {
    return showModalBottomSheet<dynamic>(
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        context: context,
        builder: (constext) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              const MyBottomSheet(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  listScrollController.jumpTo(0.0);
                  setState(() {});
                },
                icon: Icon(
                  Icons.expand_circle_down_outlined,
                  color: Colors.grey.shade500,
                  size: 30,
                ),
              ),
            ],
          );
        }).whenComplete(() {
      listScrollController.jumpTo(0.0);
      setState(() {});
    });
  }

  Widget graph() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(0),
              ),
              color: Colors.white /*  Color(0xff232d37) */),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 20.0, left: 10.0, top: 36, bottom: 12),
            child: FutureBuilder(
                future: getAllSpotsAndAvg(),
                builder: (context, AsyncSnapshot<List<List<FlSpot>>> snapshot) {
                  if (snapshot.hasData && snapshot.requireData.isNotEmpty) {
                    List<FlSpot> data = snapshot.data![0];
                    List<FlSpot> avgCord = snapshot.data![1];
                    return LineChart(
                      showAvg ? avgData(avgCord) : mainData(data),
                      swapAnimationCurve: Curves.decelerate,
                      swapAnimationDuration: Duration(milliseconds: 300),
                    );
                  }
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Center(
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.orange.shade100,
                          color: Colors.orange
                              .shade700) /* Text(
                        "Now Loading...",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),) */
                      ,
                    ),
                  );
                }),
          ),
        ).paddingOnly(top: 15),
        TextButton(
          onPressed: () {
            setState(() {
              showAvg = !showAvg;
              showYear = showAvg == true ? true : showYear;
            });
          },
          child: Text(
            showAvg ? 'Avg' : 'Total',
            style: TextStyle(fontSize: 15, color: Colors.blue),
          ).paddingOnly(bottom: 10),
        ),
      ],
    );
  }

  Future<List<List<FlSpot>>> getAllSpotsAndAvg() async {
    List<FlSpot> cordinates = [];
    List<FlSpot> avgCord = [];
    String year = currentDateFormatted().substring(0, 4); //get current year
    // print(year);
    String date;
    List<String> monthes = [
      '01',
      '02',
      '03',
      '04',
      '05',
      '06',
      '07',
      '08',
      '09',
      '10',
      '11',
      '12'
    ];
    for (int month = 0; month <= 11; month++) {
      //do it for every month in the year
      //date = currentDateFormatted();
      date = '$year-${monthes[month]}-01';
      int? yInt = await _walletRepository.getSumOfMonth(
          date: date, transType: 'spent', category: selectedCategory);

      double y = yInt == 0 ? 0.0 : yInt.toDouble();
      if (y.isNegative) {
        y = 0.0;
      }

      cordinates.add(FlSpot(month.toDouble(), y));
    }
    // for avg of year
    int avgOfYear = await _walletRepository.getSumOfYear(
        date: '$year-01-01', transType: 'spent', category: selectedCategory);
    double avgY = avgOfYear == 0 ? 0.0 : avgOfYear.toDouble();
    avgY = avgY / 12;
    /*  setState(() {
      avgPerMonth = avgY;
    }); */
    if (avgY.isNegative) {
      avgY = 0.0;
    }

    avgCord.add(FlSpot(0.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(1.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(2.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(3.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(4.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(5.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(6.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(7.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(8.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(9.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(10.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(11.0, avgY.truncateToDouble()));
    List<List<FlSpot>> returnValue = [cordinates, avgCord];

    return returnValue;
  }

  LineChartData mainData(List<FlSpot> spots) {
    Color color = Colors.grey.shade300; // Colors.orangeAccent.shade100;
    double max = 0;
    for (var element in spots) {
      max = element.y > max ? element.y : max;
    }

    double maxValue =
        max > 1000000 ? ((max / 1000000).ceil() * 1000000) : 1000000;

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,

        //touchSpotThreshold: 50,
        touchTooltipData: LineTouchTooltipData(
            fitInsideVertically: true,
            tooltipRoundedRadius: 10.0,
            tooltipBgColor: const Color.fromARGB(255, 220, 100, 0),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;

                TextAlign textAlign;
                switch (flSpot.x.toInt()) {
                  case 0:
                    textAlign = TextAlign.right;
                    break;
                  case 11:
                    textAlign = TextAlign.left;
                    break;
                  default:
                    textAlign = TextAlign.center;
                }
                var formatter = intl.NumberFormat('#,###,000');

                return LineTooltipItem(
                  formatter.format(flSpot.y).toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(
                      text: ' IQD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                  textAlign: textAlign,
                );
              }).toList();
            }),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(
              color: color /*  const Color(0xff37434d) */, width: 3)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          preventCurveOverShooting: true,
          // responsible for values of y
          spots: spots,
          isCurved: true,

          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,

          dotData: FlDotData(
            show: true,
          ),

          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.black /* const Color(0xff37434d) */,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: color /* const Color(0xff37434d) */,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,

        rightTitles: SideTitles(showTitles: false),

        topTitles: SideTitles(
            showTitles: false), //AxisTitles(drawBehindEverything: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color.fromARGB(255, 0, 160, 255) /* Color(0xff68737d) */,
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'JAN';
              case 1:
                return 'FEB';
              case 2:
                return 'MAR';
              case 3:
                return 'APR';
              case 4:
                return 'MAY';
              case 5:
                return 'JUN';
              case 6:
                return 'JUL';
              case 7:
                return 'AUG';
              case 8:
                return 'SEP';
              case 9:
                return 'OCT';
              case 10:
                return 'NOV';
              case 11:
                return 'DEC';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          rotateAngle: 0,
          reservedSize: MediaQuery.of(context).size.width / 8,
          textDirection: TextDirection.ltr,
          interval: maxValue / 2,
          textAlign: TextAlign.center,
          showTitles: true,

          getTextStyles: (context, value) => TextStyle(
            color: Colors.grey.shade700 /* Color(0xff67727d) */,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),

          getTitles: (value) {
            if (value == maxValue) {
              if (value > 9000000) {
                int val = (value ~/ 1000000);
                String title = val.toString();
                return '${title} M';
                //return '${(value ~/ 1000000) >= 1 ? (value ~/ 1000000).toInt() : value ~/ 1000000} mill';
              }

              double val = (value / 1000000);
              String title = val.toString(); // >= 1 ? "t" : "f";
              return '${title} M';

              // return '${(value / 1000000)} mill';
            }
            if (value == maxValue / 2) {
              if (value > 9000000) {
                int val = (value ~/ 1000000);
                String title = val.toString();
                return '${title} M';
              }

              double val = (value / 1000000);
              String title = val.toString(); //>= 1 ? "t" : "f";
              return '${title} M';
            }
            if (value == 0.0) {
              return '0 M';
            }

            return '';
          },
          //reservedSize: 32,
          margin: 10,
        ),
      ),
    );
  }

  LineChartData avgData(List<FlSpot> avgCord) {
    Color color = Colors.grey.shade300; //Colors.orangeAccent.shade100;
    double maxValue = avgCord[0].y > 1000000
        ? ((avgCord[0].y / 1000000).ceil() * 1000000)
        : 1000000;
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,

        //touchSpotThreshold: 50,
        touchTooltipData: LineTouchTooltipData(
          fitInsideVertically: true,
          tooltipRoundedRadius: 10.0,
          tooltipBgColor: const Color.fromARGB(255, 220, 100, 0),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;

              TextAlign textAlign;
              switch (flSpot.x.toInt()) {
                case 0:
                  textAlign = TextAlign.right;
                  break;
                case 11:
                  textAlign = TextAlign.left;
                  break;
                default:
                  textAlign = TextAlign.center;
              }
              var formatter = intl.NumberFormat('#,###,000');

              return LineTooltipItem(
                formatter.format(flSpot.y).toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  const TextSpan(
                    text: ' IQD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
                textAlign: textAlign,
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: false,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: color,
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: color,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color.fromARGB(255, 0, 160, 255),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'JAN';
              case 1:
                return 'FEB';
              case 2:
                return 'MAR';
              case 3:
                return 'APR';
              case 4:
                return 'MAY';
              case 5:
                return 'JUN';
              case 6:
                return 'JUL';
              case 7:
                return 'AUG';
              case 8:
                return 'SEP';
              case 9:
                return 'OCT';
              case 10:
                return 'NOV';
              case 11:
                return 'DEC';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          rotateAngle: 0,
          reservedSize: MediaQuery.of(context).size.width / 8,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          showTitles: true,
          interval: (maxValue / 2),
          getTextStyles: (context, value) => TextStyle(
            color: Colors.grey.shade700, // Color.fromARGB(255, 255, 160, 0),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value == maxValue) {
              if (value > 9000000) return '${value ~/ 1000000} M';

              return '${(value / 1000000)} M';
            }
            if (value == maxValue / 2) {
              if (value > 9000000) return '${value ~/ 1000000} M';

              return '${(value / 1000000)} M';
            }
            if (value == 0.0) {
              return '0 M';
            }

            return '';
          },

          // responsible for values of x ,

          //reservedSize: 32,
          margin: 10,
        ),
      ),
      borderData:
          FlBorderData(show: true, border: Border.all(color: color, width: 3)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          preventCurveOverShooting: true,
          spots: avgCord,
          isCurved: true,
          colors: gradientColors,

          /*  LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ), */
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          aboveBarData: BarAreaData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),

            /* gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ), */
          ),
        ),
      ],
    );
  }

  Widget totalSpent() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showAvg
              ? const Text("Average Spent Per Month",
                  style: TextStyle(fontSize: 20, color: Colors.grey))
              : showYear
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Spent Current Year",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                showYear = showYear ? false : true;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: Icon(
                                size: 25,
                                Icons.swap_horiz_rounded,
                              ),
                            ))
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Total Spent Current Month",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                showYear = showYear ? false : true;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: Icon(
                                size: 25,
                                Icons.swap_horiz_rounded,
                              ),
                            ))
                      ],
                    ),
          FutureBuilder<int>(
              future: showYear
                  ? _walletRepository.getSumOfYear(
                      date: currentDateFormatted(),
                      transType: 'spent',
                      category: selectedCategory)
                  : _walletRepository.getSumOfMonth(
                      date: currentDateFormatted(),
                      transType: 'spent',
                      category: selectedCategory),
              builder: (context, snapshot) {
                var formatter = intl.NumberFormat('#,###,000');
                try {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Center(
                      child: Text(
                        showAvg
                            ? "${formatter.format(snapshot.data! / 12)} IQD"
                            : "${formatter.format(snapshot.data)} IQD",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 160, 0),
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: Text("Loading..."),
                  );
                } catch (e) {
                  return Center(
                    child: Text(
                      "${formatter.format(000)} IQD",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 160, 0),
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  String dateFormatter(String date) {
    final newDate = DateTime.parse(date);
    print(newDate);

    intl.DateFormat formatterText =
        intl.DateFormat(intl.DateFormat.YEAR_MONTH_DAY);

    String formatted = formatterText.format(newDate);

    return formatted;
  }

  Widget transactions() {
    return SingleChildScrollView(
      dragStartBehavior: DragStartBehavior.down,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: FutureBuilder(
              future: futureData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<WalletDataModule> data = snapshot.data;

                  int itemNumber = data.length;
                  itemNumber = itemNumber < 10 ? itemNumber : 10;
                  int numOfIndexes = data.length - 1;
                  //int id = 0;
                  //String type = "default";
                  int amount = 0;
                  String desc = "description";
                  String transDate = "0000-00-00";
                  String title = "";

                  return ListView.separated(
                    // physics: BouncingScrollPhysics(),
                    //physics: const NeverScrollableScrollPhysics(),
                    controller: listScrollController,
                    itemCount: itemNumber,
                    itemBuilder: (context, itemIndex) {
                      int reversIndex = numOfIndexes - itemIndex;
                      transDate = data[reversIndex].transactionDate;
                      amount = data[reversIndex].transactionAmount;
                      // type = data[reversIndex]['trans_type'].toString();
                      desc = data[reversIndex].transactionDescription;
                      title = data[reversIndex].transactionTitle;

                      return InkWell(
                        child: listTile(
                            title: title,
                            desc: desc,
                            amount: amount,
                            date: transDate),
                        onTap: () {
                          var formatter = intl.NumberFormat('#,###,000');
                          myCustomShowDialog(
                              barrierColor: Colors.black.withOpacity(0.3),
                              dissmissable: true,
                              context: context,
                              blur: false,
                              child: Center(
                                child: Container(
                                  /*  height:
                                      MediaQuery.of(context).size.height * 0.6, */
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${data[reversIndex].transactionTitle}",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 30),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Amount ",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  " ${formatter.format(data[reversIndex].transactionAmount)} IQE",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    width: double.maxFinite),
                                                Text(
                                                  "Description",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "${data[reversIndex].transactionDescription}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 50),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${dateFormatter(data[reversIndex].transactionDate)}",
                                                style: TextStyle(fontSize: 17),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 5,
                      );
                    },
                  );
                }
                return Center(
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.orange.shade100,
                        color: Colors.orange.shade700));
              },
            ),
          ),
        ],
      ),
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  Future<List<WalletDataModule>> futureData() async {
    String date = currentDateFormatted();
    return await _walletRepository.getAllTransactionsInYear(
        date: date, transType: "spent", category: selectedCategory);
  }

  Widget listTile(
      {required String title,
      required String desc,
      required int amount,
      required String date}) {
    var formatter = intl.NumberFormat('#,###,000');
    return SizedBox(
      height: MediaQuery.of(context).size.height / 13,
      child: ListTile(
        leading: const FaIcon(
          FontAwesomeIcons.dollyFlatbed,
          size: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: RichText(
          text: new TextSpan(
            text: '${formatter.format(amount)}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            children: <TextSpan>[
              new TextSpan(
                  text: ' IQD',
                  style: new TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({Key? key}) : super(key: key);

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  TextEditingController moneyField = TextEditingController();
  TextEditingController titleField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  /*  WalletDataProvider _walletDataProvider =
      WalletDataProvider(database: LocalDbProvider.database!); */
  late WalletDataRepository _walletRepository =
      WalletDataRepository(database: LocalDbProvider.database!);

  _WalletState reachWallet = _WalletState();
  late FToast ftoast;
  List<String> categories = const [
    "Snacks",
    "Clothes",
    "Fuel",
    "Grocery",
    "Health Care",
    "Lending",
    "Food",
    "Transportation",
    "Bills",
    "Shopping",
    "Rent",
    "Credit",
    "Enteratainment",
    "Monthly Subscription",
    "Car Related",
    "Technical Equipments",
  ];
  String? selectedCategory = null;

  @override
  void initState() {
    /*  _walletRepository =
        WalletDataRepository(walletProvider: _walletDataProvider); */
    ftoast = FToast();
    ftoast.init(context);
    super.initState();
    // DatabaseHelper.instance.delDatabase(dbName: "Plans.db");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 1,
        minChildSize: 0.7,
        builder: (context, controller) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextField(
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        textAlignVertical: TextAlignVertical.center,
                        cursorHeight: 40,
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.white70.withOpacity(0.3),
                        controller: moneyField,
                        showCursor: true,
                        cursorWidth: 3,
                        cursorRadius: Radius.circular(10),
                        cursorOpacityAnimates: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          suffix: const Text("IQD",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          contentPadding: const EdgeInsets.all(10),
                          focusColor: Colors.white,
                          hintText: "0.000 IQD",
                          hintStyle: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 150, 0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        onTap: () {
                          moneyField.selection = TextSelection.fromPosition(
                              TextPosition(offset: moneyField.text.length));
                        },
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        controller: titleField,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 255, 160, 0),
                                width: 3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              width: 3,
                              color: Color.fromARGB(255, 255, 160, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        controller: descriptionField,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              width: 3,
                              color: Color.fromARGB(255, 255, 160, 0),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              width: 3,
                              color: Color.fromARGB(255, 255, 160, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.dollyFlatbed,
                            size: 25,
                          ),
                          Row(
                            children: [
                              Text(
                                "${selectedCategory ?? "Category"}",
                                style: TextStyle(fontSize: 18),
                              ).paddingOnly(right: 10, left: 20),
                              IconButton(
                                  onPressed: () async {
                                    selectedCategory = await showPickerDialog(
                                      context: context,
                                      label: "Category",
                                      items: categories,
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.keyboard_arrow_down_rounded))
                            ],
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        String moneyOnlyNumber =
                            moneyField.text.replaceAll(',', '');

                        int? amount = int.tryParse(moneyOnlyNumber);
                        String title = titleField.text;
                        String desc = descriptionField.text;
                        if (title.isEmpty) title = "No Title";

                        if (amount != null) {
                          await addTrans(
                            amount: amount,
                            title: title,
                            description: desc,
                            category: selectedCategory,
                          );
                          selectedCategory = null;
                          moneyField.clear();
                          titleField.clear();
                          descriptionField.clear();
                          setState(() {});
                          _showToast();
                        }

                        // Respond to button press
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add Transaction"),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.resolveWith(
                          (states) => RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        textStyle: MaterialStateTextStyle.resolveWith(
                            (textStyle) => const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        backgroundColor: MaterialStateColor.resolveWith(
                            (color) => Color.fromARGB(255, 255, 160, 0)),
                        foregroundColor: MaterialStateColor.resolveWith(
                            (color) => Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.amber.shade900,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(FontAwesomeIcons.timesCircle),
          SizedBox(
            width: 12.0,
          ),
          Text(
            "Successfull",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(milliseconds: 500),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  Future<void> addTrans({
    required int amount,
    required String title,
    required String description,
    required String? category,
  }) async {
    print(currentDateFormatted());

    await _walletRepository.insertTransactionCunstom(
        date: currentDateFormatted(), //"2024-04-21",
        amount: amount,
        transType: 'spent',
        description: description,
        title: title,
        category: category);
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1)
          newString = separator + newString;
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
