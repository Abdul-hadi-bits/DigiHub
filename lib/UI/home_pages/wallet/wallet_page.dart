import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_project/databaste/wallet_database_model.dart'
    as wallet_model;
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;

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

  late wallet_model.WalletDatabase walletDatabase;
  DateTime _selectedDate = DateTime.now();
  bool allDays = false;
  bool allMonths = false;
  late FToast ftoast;

  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    super.initState();
    walletDatabase = wallet_model.WalletDatabase();
    selectedMonth = partOfCurrentDate(partOfDate: "month");
    selectedYear = partOfCurrentDate(partOfDate: "year");
    selectedDay = partOfCurrentDate(partOfDate: "day");
    selectedTransType = "All";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 70,
        title: const Text(
          "Transactions",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black)),
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
                      elevation: 5,
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
                                        Icons.check_box,
                                        color: Color.fromARGB(255, 255, 100, 0),
                                      )
                                    : const Icon(Icons.check_box_outline_blank),
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
                                        Icons.check_box,
                                        color: Color.fromARGB(255, 255, 100, 0),
                                      )
                                    : const Icon(Icons.check_box_outline_blank),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 200,
                          child: SizedBox(
                            width: 150,
                            child: ScrollDatePicker(
                              maximumDate: DateTime.parse("2030-01-01"),
                              minimumDate: DateTime.parse("2020-01-01"),
                              scrollViewOptions: DatePickerScrollViewOptions(
                                      day: ScrollViewDetailOptions(textStyle: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold), selectedTextStyle:TextStyle(
                                        
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                      
                                      ),
                                      month: ScrollViewDetailOptions(textStyle: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                      selectedTextStyle:TextStyle(
                                        
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                      
                                      ),
                                      year: ScrollViewDetailOptions(textStyle: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                      selectedTextStyle:TextStyle(

                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                      )

                              ),

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
                        elevation: 7,
                        child: Container(
                          color: Color.fromARGB(255, 255, 160, 0),
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
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                List<Map<String, dynamic>> data = snapshot.data;
                                int itemNumber = data.length;
                                int id = 0;
                                String type = "default";
                                int amount = 0;
                                String desc = "description";
                                String transDate = "0000-00-00";
                                String title = "";
                                print(itemNumber);

                                return ListView.separated(
                                  itemCount: itemNumber,
                                  itemBuilder: (context, itemIndex) {
                                    itemIndex = itemNumber - 1 - itemIndex;
                                    id = data[itemIndex]['trans_id'];

                                    transDate = data[itemIndex]['trans_date']
                                        .toString();
                                    amount = data[itemIndex]['trans_amount'];

                                    type = data[itemIndex]['trans_type']
                                        .toString();
                                    desc = data[itemIndex]['trans_desc']
                                        .toString();
                                    title = data[itemIndex]['trans_title']
                                        .toString();

                                    transIdOfEeachIndex.add(0);
                                    return transactionCard(
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
      required int id}) {
    var formatter = intl.NumberFormat('#,###,000');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 4,
      child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 30, right: 8, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Text(transDate),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.clip),
                  ),

                  Row(
                    children: [
                      Text("${formatter.format(amount)} ",
                          style: const TextStyle(fontSize: 30)),
                      const Text(
                        "IQD",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 255, 160, 0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
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
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Text(
                      transDate,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade500),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                    InkWell(
                        onTap: () {
                          _showToast();
                        },
                        onLongPress: () async {
                          await walletDatabase.deleteTransactions(transId: id);
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
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.deepOrange.shade900,
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
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  String partOfCurrentDate({required partOfDate}) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    List<String> dateApart = formatted.split('-');
    switch (partOfDate) {
      case "year":
        print(dateApart[0]);
        return dateApart[0];
      case "month":
        print(dateApart[1]);
        return dateApart[1];
      case "day":
        print(dateApart[2]);
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

  Future<List<Map<String, dynamic>>> futureData() async {
    String newMonth = selectedMonth == "All" ? "01" : selectedMonth;
    String newDay = selectedDay == "All" ? "01" : selectedDay;
    //String date = "$selectedYear-$newMonth-$newDay";
    String date = dateFormatter(date: _selectedDate);
    print(date);
    String transType;
    selectedTransType != "All"
        ? {transType = selectedTransType}
        : {transType = ""};

    return await (allDays == true
        ? allMonths == true
            ? walletDatabase.getAllTransactionsInYear(
                date: date, transType: transType)
            : walletDatabase.getAllTransactionsInMonth(
                date: date, transType: transType)
        : walletDatabase.getAllTransactionsAtDay(
            date: date, transType: transType));

    /*  return await (selectedDay == "All"
        ? selectedMonth == "All"
            ? walletDatabase.getAllTransactionsInYear(
                date: date, transType: transType)
            : walletDatabase.getAllTransactionsInMonth(
                date: date, transType: transType)
        : walletDatabase.getAllTransactionsAtDay(
            date: date, transType: transType)); */
  }
}
