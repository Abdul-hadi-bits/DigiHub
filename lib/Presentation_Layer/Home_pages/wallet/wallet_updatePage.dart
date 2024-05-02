import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Repositories/Wallet_Data_Repository.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:list_picker/list_picker.dart';

class WalletUpdateTransaction extends StatefulWidget {
  int id;
  String desc;
  String amount;
  String type;
  String title;
  String category;
  WalletUpdateTransaction(
      this.id, this.desc, this.amount, this.type, this.title,
      {super.key, required this.category});

  @override
  State<WalletUpdateTransaction> createState() => _WalletUpdateTransactionState(
      amount: this.amount,
      category: this.category,
      id: this.id,
      desc: this.desc,
      title: this.title,
      type: this.type);
}

class _WalletUpdateTransactionState extends State<WalletUpdateTransaction> {
  late int id;
  late String category;
  late String desc;
  late String amount;
  late String type;
  late String title;
  _WalletUpdateTransactionState(
      {required this.id,
      required this.amount,
      required this.desc,
      required this.title,
      required this.category,
      required this.type});
  TextEditingController moneyField = TextEditingController();
  TextEditingController titleField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  /*  WalletDataProvider _walletDataProvider =
      WalletDataProvider(database: LocalDbProvider.database!); */
  late WalletDataRepository _walletRepository =
      WalletDataRepository(database: LocalDbProvider.database!);

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
    // TODO: implement initState
    moneyField = TextEditingController(text: amount.toString());
    titleField = TextEditingController(text: title.toString());
    selectedCategory = category;

    descriptionField = TextEditingController(text: desc.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          context: context,
          ttle: "Update",
          statusBarDark: false,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
          children: [
            SingleChildScrollView(
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
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter()
                              ],
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
                                fillColor:
                                    const Color.fromARGB(255, 255, 150, 0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                              onTap: () {
                                moneyField.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: moneyField.text.length));
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
                                          selectedCategory =
                                              await showPickerDialog(
                                            context: context,
                                            label: "Category",
                                            items: categories,
                                          );
                                          setState(() {});
                                        },
                                        icon: Icon(
                                            Icons.keyboard_arrow_down_rounded))
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

                              if (amount != null) {
                                await updateTrans(
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
                              }

                              // Respond to button press
                            },
                            icon: const Icon(Icons.update, size: 18),
                            label: const Text("Update Transaction"),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              textStyle: MaterialStateTextStyle.resolveWith(
                                  (textStyle) => const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (color) => Color.fromARGB(255, 255, 160, 0)),
                              foregroundColor: MaterialStateColor.resolveWith(
                                  (color) => Colors.black),
                            ),
                          )
                        ],
                      ),
                    )))
          ],
        )));
  }

  Future<void> updateTrans({
    required int amount,
    required String title,
    required String description,
    required String? category,
  }) async {
    print(currentDateFormatted());

    await _walletRepository.updateTransaction(
        amount: amount,
        transType: 'spent',
        description: description,
        transId: this.id,
        title: title,
        category: category);
  }
}

String currentDateFormatted() {
  DateTime now = DateTime.now();
  intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd');
  String formatted = formatter.format(now);
  return formatted;
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
