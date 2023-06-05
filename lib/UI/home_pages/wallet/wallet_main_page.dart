import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_project/UI/home_pages/settings/settings.dart';
import 'package:my_project/UI/home_pages/wallet/wallet_page.dart';
import 'package:my_project/databaste/database_helper.dart';
import 'package:intl/intl.dart' as intl;

import 'package:my_project/databaste/wallet_database_model.dart' as dbModel;

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  dbModel.WalletDatabase walletDatabase = dbModel.WalletDatabase();
  List<Color> gradientColors = [
    /* const Color(0xff23b6e6),
    const Color(0xff02d39a), */
    const Color.fromARGB(255, 255, 160, 0),
    Colors.orangeAccent.shade700
  ];

  bool showAvg = false;
  // double avgPerMonth = 0.0;
  int oldsize = 0;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.all_inbox,
              size: 25,
              color: Colors.orangeAccent,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseDetails(),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          )
        ],
        title: const Text(
          "Wallet",
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black),
        ),
        titleSpacing: 70,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
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
            InkWell(child: transactions()),
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
    );
  }

  showBottomSheet() {
    return showModalBottomSheet<dynamic>(
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
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
                  setState(() {});
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          );
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
                right: 18.0, left: 12.0, top: 36, bottom: 12),
            child: FutureBuilder(
                future: getAllSpotsAndAvg(),
                builder: (context, AsyncSnapshot<List<List<FlSpot>>> snapshot) {
                  if (snapshot.hasData && snapshot.requireData.isNotEmpty) {
                    List<FlSpot> data = snapshot.data![0];
                    List<FlSpot> avgCord = snapshot.data![1];
                    return LineChart(
                      showAvg ? avgData(avgCord) : mainData(data),
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
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                  fontSize: 15,
                  color: showAvg ? Colors.orange.shade700 : Colors.grey),
            ),
          ),
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
      int? yInt =
          await walletDatabase.getSumOfMonth(date: date, transType: 'spent');
      double y = yInt == 0 ? 0.0 : yInt.toDouble();

      cordinates.add(FlSpot(month.toDouble(), y));
    }
    // for avg of year
    int avgOfYear = await walletDatabase.getSumOfYear(
        date: '$year-01-01', transType: 'spent');
    double avgY = avgOfYear == 0 ? 0.0 : avgOfYear.toDouble();
    avgY = avgY / 12;
    /*  setState(() {
      avgPerMonth = avgY;
    }); */

    avgCord.add(FlSpot(0.0, avgY.truncateToDouble()));
    avgCord.add(FlSpot(11.0, avgY.truncateToDouble()));

    List<List<FlSpot>> returnValue = [cordinates, avgCord];

    return returnValue;
  }

  LineChartData mainData(List<FlSpot> spots) {
    Color color = Colors.orangeAccent.shade100;
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
              color: color /*  const Color(0xff37434d) */, width: 1)),
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
        

        topTitles: SideTitles(showTitles: false) 
        ,//AxisTitles(drawBehindEverything: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color.fromARGB(255, 255, 160, 0) /* Color(0xff68737d) */,
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
          reservedSize: 50,
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
              return '${(value / 1000000)}m';
            }
            if (value == maxValue / 2) {
              return '${(value / 1000000)}m';
            }
            if (value == 0.0) {
              return '0';
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
    Color color = Colors.orangeAccent.shade100;
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
              color: Color.fromARGB(255, 255, 160, 0),
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
          reservedSize: 35,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          showTitles: true,
          interval: (maxValue / 2),
          getTextStyles: (context, value) => const TextStyle(
            color: Color.fromARGB(255, 255, 160, 0),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value == maxValue) {
              return '${(value / 1000000)}m';
            }
            if (value == maxValue / 2) {
              return '${(value / 1000000)}m';
            }
            if (value == 0.0) {
              return '0';
            }

            return '';
          },

          // responsible for values of x ,

          //reservedSize: 32,
          margin: 10,
        ),
      ),
      borderData:
          FlBorderData(show: true, border: Border.all(color: color, width: 1)),
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
            show: false,
            colors: gradientColors,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        showAvg
            ? const Text("Average Spent Per Month",
                style: TextStyle(fontSize: 20, color: Colors.grey))
            : const Text(
                "Total Spent Current Month",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
        FutureBuilder<int>(
            future: walletDatabase.getSumOfYear(
                date: currentDateFormatted(), transType: 'spent'),
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
    );
  }

  Widget transactions() {
    return SingleChildScrollView(
      dragStartBehavior: DragStartBehavior.down,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Transcations",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Latest",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )
                ]),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 3.25,
            child: FutureBuilder(
              future: futureData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> data = snapshot.data;

                  int itemNumber = data.length;
                  itemNumber = itemNumber < 3 ? itemNumber : 3;
                  int numOfIndexes = data.length - 1;
                  //int id = 0;
                  //String type = "default";
                  int amount = 0;
                  String desc = "description";
                  String transDate = "0000-00-00";
                  String title = "";

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemNumber,
                    itemBuilder: (context, itemIndex) {
                      int reversIndex = numOfIndexes - itemIndex;
                      transDate = data[reversIndex]['trans_date'].toString();
                      amount = data[reversIndex]['trans_amount'];
                      // type = data[reversIndex]['trans_type'].toString();
                      desc = data[reversIndex]['trans_desc'].toString();
                      title = data[reversIndex]['trans_title'].toString();

                      return listTile(
                          title: title,
                          desc: desc,
                          amount: amount,
                          date: transDate);
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

  Future<List<Map<String, dynamic>>> futureData() async {
    String date = currentDateFormatted();
    return await walletDatabase.getAllTransactionsInYear(
        date: date, transType: "spent");
  }

  Widget listTile(
      {required String title,
      required String desc,
      required int amount,
      required String date}) {
    var formatter = intl.NumberFormat('#,###,000');
    return ListTile(
      leading: const FaIcon(
        FontAwesomeIcons.dollyFlatbed,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(fontSize: 15, color: Colors.grey),
      ),
      trailing: Text(
        "${formatter.format(amount)} IQD",
        style: const TextStyle(
            fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
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
  dbModel.WalletDatabase walletDatabase = dbModel.WalletDatabase();
  _WalletState reachWallet = _WalletState();
  late FToast ftoast;

  @override
  void initState() {
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
              padding: const EdgeInsets.only(top: 40.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        cursorColor: Colors.white10,
                        controller: moneyField,
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
                    OutlinedButton.icon(
                      onPressed: () async {
                        String moneyOnlyNumber =
                            moneyField.text.replaceAll(',', '');

                        int? amount = int.tryParse(moneyOnlyNumber);
                        String title = titleField.text;
                        String desc = descriptionField.text;

                        if (amount != null) {
                          await addTrans(
                            amount: amount,
                            title: title,
                            description: desc,
                          );
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
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
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
  }) async {
    print(currentDateFormatted());

    await walletDatabase.insertTransactionCunstom(
        date: currentDateFormatted(),
        amount: amount,
        transType: 'spent',
        description: description,
        title: title);
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
