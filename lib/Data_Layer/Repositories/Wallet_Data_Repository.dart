// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:digi_hub/Data_Layer/Data_Providers/Wallet_Data_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/Wallet_Data_Module.dart';
import "package:sqflite/sqflite.dart" as sqflite;

class WalletDataRepository {
  late WalletDataProvider walletProvider;
  sqflite.Database database;

  WalletDataRepository({
    required this.database,
  }) {
    walletProvider = WalletDataProvider(database: database);
  }

  Future<List<WalletDataModule>> getAllTransactionsInYear(
      {required String date,
      required String transType,
      required String category}) async {
    if (category == "None") category = "none";
    return WalletDataModule.fromListMap(
        await walletProvider.getAllTransactionsInYear(
            date: date, transType: transType, transCategory: category));
  }

  Future<List<WalletDataModule>> getAllTransactionsInYearWhereDayIs(
      {required String date,
      required String transType,
      required String category}) async {
    if (category == "None") category = "none";
    return WalletDataModule.fromListMap(
        await walletProvider.getAllTransactionsInYearWhereDayIs(
            date: date, transType: transType, transCategory: category));
  }

  Future<List<WalletDataModule>> getAllTransactionsInMonth(
      {required String date, required String transType}) async {
    return WalletDataModule.fromListMap(await walletProvider
        .getAllTransactionsInMonth(date: date, transType: transType));
  }

  Future<List<WalletDataModule>> getAllTransactionsAtDay(
      {required String date, required String transType}) async {
    return WalletDataModule.fromListMap(await walletProvider
        .getAllTransactionsInDay(date: date, transType: transType));
  }

  Future<int> getSumOfYear(
      {required String date,
      required String transType,
      required String category}) async {
    if (category == "None") category = "none";

    return await walletProvider.getSumOfYear(
        date: date, transType: transType, transCategory: category);
  }

  Future<int> getSumOfMonth(
      {required String date,
      required String transType,
      required String category}) async {
    if (category == "None") category = "none";
    return await walletProvider.getSumOfMonth(
        date: date, transType: transType, tranCategory: category);
  }

  Future<int> getSumOfDay(
      {required String date, required String transType}) async {
    return await walletProvider.getSumOfDay(date: date, transType: transType);
  }

  Future<bool> insertTransaction(
      {required int amount,
      required String transType,
      required String description,
      required String title,
      required String? category}) async {
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    var date = year + "-" + month + "-" + day;
    category = category == null ? "none" : category;
    description = description.replaceAll(RegExp("'"), "''");
    title = title.replaceAll(RegExp("'"), "''");

    return await walletProvider.addTransaction(
        date: date,
        amount: amount,
        transType: transType,
        description: description,
        title: title,
        category: category);
  }

  Future<bool> insertTransactionCunstom(
      {required String date,
      required int amount,
      required String transType,
      required String description,
      required String title,
      required String? category}) async {
    category = category == null ? "none" : category;
    description = description.replaceAll(RegExp("'"), "''");
    title = title.replaceAll(RegExp("'"), "''");
    return await walletProvider.addTransaction(
      date: date,
      amount: amount,
      transType: transType,
      description: description,
      title: title,
      category: category,
    );
  }

  Future<bool> deleteTransactions({required int transId}) async {
    return await walletProvider.deleteTransaction(transId: transId) != 0
        ? true
        : false;
  }

  Future<bool> updateTransaction(
      {required int transId,
      required int amount,
      required String transType,
      required String title,
      required String? category,
      required description}) async {
    category = category == null ? "none" : category;
    description = description.replaceAll(RegExp("'"), "''");
    title = title.replaceAll(RegExp("'"), "''");
    return await walletProvider.updateTransaction(
                title: title,
                category: category,
                transId: transId,
                amount: amount,
                transType: transType,
                description: description) !=
            0
        ? true
        : false;
  }
}
