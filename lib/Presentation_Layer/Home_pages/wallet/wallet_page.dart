import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/wallet/wallet_updatePage.dart';
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/Wallet_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Wallet_Data_Repository.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:page_transition/page_transition.dart';

import 'package:scroll_date_picker/scroll_date_picker.dart';

class ExpenseDetails extends StatefulWidget {
  const ExpenseDetails({Key? key}) : super(key: key);

  @override
  ExpenseDetailsState createState() => ExpenseDetailsState();
}

class ExpenseDetailsState extends State<ExpenseDetails> {
  var transIdOfEeachIndex = [];
  late String selectedYear;
  late String selectedMonth;
  late String selectedDay;
  late String selectedTransType;
  late int totalOfSelectedQuery = 0;

  /*  WalletDataProvider _walletProvider =
      WalletDataProvider(database: LocalDbProvider.database!); */

  late WalletDataRepository _walletRepository =
      WalletDataRepository(database: LocalDbProvider.database!);

  DateTime _selectedDate = DateTime.now();
  bool allDays = false;
  bool allMonths = false;
  late FToast ftoast;

  @override
  void initState() {
    //  _walletRepository = WalletDataRepository(walletProvider: _walletProvider);
    ftoast = FToast();
    ftoast.init(context);
    super.initState();

    selectedMonth = partOfCurrentDate(partOfDate: "month");
    selectedYear = partOfCurrentDate(partOfDate: "year");
    selectedDay = partOfCurrentDate(partOfDate: "day");
    selectedTransType = "All";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MyAppBar(
        context: context,
        ttle: "Transactions",
        italikTitle: true,
        fitTitle: true,
        statusBarDark: false,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          //2
          SliverAppBar(
            leading: const Icon(Icons.arrow_back,
                color: Colors.transparent //Colors.deepOrange.shade100,
                ),

            expandedHeight: 270,

            backgroundColor:
                Colors.white, // Color.fromARGB(255, 255, 210, 200),
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: Column(
                  children: [
                    Card(
                      elevation: 1,
                      child: Container(
                        color: Colors.white, //Colors.deepOrange.shade100,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(children: [
                              const Text(
                                "Select All Days ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  allDays = allDays ? false : true;
                                  setState(() {});
                                },
                                icon: allDays
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color.fromARGB(255, 255, 100, 0),
                                      )
                                    : const Icon(Icons.check_circle),
                              ),
                              const Spacer(),
                              const Text(
                                "Select All Months",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  allMonths = allMonths ? false : true;
                                  setState(() {});
                                },
                                icon: allMonths
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color.fromARGB(255, 255, 100, 0),
                                      )
                                    : const Icon(
                                        Icons.check_circle,
                                      ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 200,
                          child: SizedBox(
                            width: 150,
                            child: ScrollDatePicker(
                              maximumDate: DateTime.parse("2030-01-01"),
                              minimumDate: DateTime.parse("2020-01-01"),
                              scrollViewOptions: DatePickerScrollViewOptions(
                                  day: ScrollViewDetailOptions(
                                    textStyle: TextStyle(
                                        color: allDays
                                            ? Colors.orange
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                    selectedTextStyle: TextStyle(
                                        color: allDays
                                            ? Colors.orange
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  month: ScrollViewDetailOptions(
                                    textStyle: TextStyle(
                                        color: allMonths
                                            ? Colors.orange
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                    selectedTextStyle: TextStyle(
                                        color: allMonths
                                            ? Colors.orange
                                            : Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  year: ScrollViewDetailOptions(
                                    textStyle: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                    selectedTextStyle: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  )),

                              //
                              //     selectedTextStyle:
                              // selectedDate: _selectedDate,
                              // locale: DatePickerLocale.enUS,
                              onDateTimeChanged: (DateTime value) {
                                setState(() {
                                  _selectedDate = value;
                                });
                              },
                              selectedDate: _selectedDate,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //3
          SliverFillRemaining(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          //Color.fromARGB(255, 255, 160, 0),
                          child: const Center(
                              child: FittedBox(
                            child: FaIcon(
                              Icons.keyboard_double_arrow_down_sharp,
                              color: Colors.black,
                              size: 40,
                            ),
                          )),
                        ),
                      )),
                  Expanded(
                    flex: 10,
                    child: Card(
                      child: Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height / 2,
                        child: FutureBuilder(
                            future: futureData(),
                            builder: (context,
                                AsyncSnapshot<List<WalletDataModule>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                var formatter = intl.NumberFormat('#,###,000');

                                List<WalletDataModule> data = snapshot.data!;
                                int itemNumber = data.length;
                                int id = 0;
                                String type = "default";
                                int amount = 0;
                                String desc = "description";
                                String transDate = "0000-00-00";
                                String title = "";
                                String category = "";

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.75,
                                            child: Center(
                                              child: FittedBox(
                                                child: RichText(
                                                  text: new TextSpan(
                                                    text: 'Total ',
                                                    style: const TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text:
                                                              '${formatter.format(getSumOfMoney(snapshot))}',
                                                          style: new TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Colors
                                                                  .black)),
                                                      new TextSpan(
                                                          text: ' IQD',
                                                          style: new TextStyle(
                                                              fontSize: 25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Colors
                                                                  .orange)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 15,
                                      child: ListView.separated(
                                        itemCount: itemNumber,
                                        itemBuilder: (context, itemIndex) {
                                          itemIndex =
                                              itemNumber - 1 - itemIndex;
                                          id = data[itemIndex].transactionId;

                                          transDate =
                                              data[itemIndex].transactionDate;
                                          amount =
                                              data[itemIndex].transactionAmount;

                                          type =
                                              data[itemIndex].transactionType;

                                          desc = data[itemIndex]
                                              .transactionDescription;
                                          title =
                                              data[itemIndex].transactionTitle;
                                          category = data[itemIndex]
                                              .transactionCategory;

                                          transIdOfEeachIndex.add(0);
                                          return transactionCard(
                                              category: category,
                                              amount: amount,
                                              type: type,
                                              transDate: transDate,
                                              desc: desc,
                                              title: title,
                                              id: id);
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(
                                            height: 5,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Center(
                                  child: LinearProgressIndicator(
                                      backgroundColor: Colors.orange.shade100,
                                      color: Colors.orange.shade700));
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dropDownText({required String text}) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }

  Widget customText({required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Text(
          "$text : ",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget transactionCard(
      {required int amount,
      required String type,
      required String title,
      required String transDate,
      required String desc,
      required int id,
      required String category}) {
    var formatter = intl.NumberFormat('#,###,000');
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blueGrey.shade50,
            ),
            margin:
                const EdgeInsets.only(top: 10, bottom: 30, right: 20, left: 20),
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, right: 20, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Text(transDate),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: FittedBox(
                        alignment: Alignment.topLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.38,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topRight,
                        child: RichText(
                          text: new TextSpan(
                            text: '${formatter.format(amount)}',
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: ' IQD',
                                  style: new TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.4,
                        child: Text(desc,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            overflow: TextOverflow.clip),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transDate,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                      InkWell(
                          onTap: () {
                            _showToast();
                          },
                          onLongPress: () async {
                            await _walletRepository.deleteTransactions(
                                transId: id);
                            setState(() {});
                          },
                          child: const FaIcon(FontAwesomeIcons.trash,
                              color: Colors.red, size: 25)),
                    ],
                  ),
                )
                //Text(desc)
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Align(
            child: IconButton(
              icon: Icon(Icons.edit_note_outlined),
              onPressed: () {
                Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: WalletUpdateTransaction(
                                id,
                                desc,
                                category: category,
                                formatter.format(amount),
                                type,
                                title)))
                    .whenComplete(() => setState(() {}));
              },
            ),
            alignment: Alignment.topRight,
          ),
        ),
      ],
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.orange.shade600,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(FontAwesomeIcons.timesCircle),
          SizedBox(
            width: 12.0,
          ),
          Text(
            "LongPress To Delete",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(milliseconds: 200),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 1),
    );
  }

  String partOfCurrentDate({required partOfDate}) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    List<String> dateApart = formatted.split('-');
    switch (partOfDate) {
      case "year":
        return dateApart[0];
      case "month":
        return dateApart[1];
      case "day":
        return dateApart[2];
      default:
        return dateApart[0];
    }
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    String formatted = formatter.format(date);
    return formatted;
  }

  Future<List<WalletDataModule>> futureData() async {
    /*  String newMonth = selectedMonth == "All" ? "01" : selectedMonth;
    String newDay = selectedDay == "All" ? "01" : selectedDay; */
    //String date = "$selectedYear-$newMonth-$newDay";
    String date = dateFormatter(date: _selectedDate);
    String transType;
    selectedTransType != "All"
        ? {transType = selectedTransType}
        : {transType = ""};
    if (allDays == false && allMonths == false) {
      return await _walletRepository.getAllTransactionsAtDay(
          date: date, transType: transType);
    }
    if (allDays == true && allMonths == false) {
      return await _walletRepository.getAllTransactionsInMonth(
          date: date, transType: transType);
    }
    if (allDays == false && allMonths == true) {
      return await _walletRepository.getAllTransactionsInYearWhereDayIs(
          date: date, transType: transType, category: "All");
    }
    if (allDays == true && allMonths == true) {
      return await _walletRepository.getAllTransactionsInYear(
          date: date, transType: transType, category: "All");
    }

    return await _walletRepository.getAllTransactionsAtDay(
        date: date, transType: transType);

    /*  return await (allDays == true
        ? allMonths == true
            ? _walletRepository.getAllTransactionsInYear(
                date: date, transType: transType, category: "All")
            : _walletRepository.getAllTransactionsInMonth(
                date: date, transType: transType)
        : _walletRepository.getAllTransactionsAtDay(
            date: date, transType: transType)); */

    /*  return await (selectedDay == "All"
        ? selectedMonth == "All"
            ? _walletRepository.getAllTransactionsInYear(
                date: date, transType: transType)
            : _walletRepository.getAllTransactionsInMonth(
                date: date, transType: transType)
        : _walletRepository.getAllTransactionsAtDay(
            date: date, transType: transType)); */
  }

  int getSumOfMoney(AsyncSnapshot<List<WalletDataModule>> snapshot) {
    int sum = 0;
    snapshot.data!.forEach((element) {
      sum += element.transactionAmount;
    });
    return sum;
  }
}
