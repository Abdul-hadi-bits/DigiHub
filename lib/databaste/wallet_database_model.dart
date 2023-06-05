import 'package:my_project/databaste/database_helper.dart' as helper;

class WalletDatabase {
  //late int sumOfYear;

  Future<List<Map<String, dynamic>>> getAllTransactionsInYear(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getAllTransactionsInYear(date: date, transType: transType);
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInMonth(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getAllTransactionsInMonth(date: date, transType: transType);
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsAtDay(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getAllTransactionsInDay(date: date, transType: transType);
  }

  Future<int> getSumOfYear(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getSumOfYear(date: date, transType: transType);
  }

  Future<int> getSumOfMonth(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getSumOfMonth(date: date, transType: transType);
  }

  Future<int> getSumOfDay(
      {required String date, required String transType}) async {
    return await helper.DatabaseHelper.instance
        .getSumOfDay(date: date, transType: transType);
  }

  void insertTransaction(
      {required int amount,
      required String transType,
      required String description,
      required String title}) {
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month.toString();
    String day = DateTime.now().day.toString();
    var date = year + "-" + month + "-" + day;

    helper.DatabaseHelper.instance.addTransaction(
        date: date,
        amount: amount,
        transType: transType,
        description: description,
        title: title);
  }

  Future<void> insertTransactionCunstom(
      {required String date,
      required int amount,
      required String transType,
      required String description,
      required String title}) async {
    await helper.DatabaseHelper.instance.addTransaction(
        date: date,
        amount: amount,
        transType: transType,
        description: description,
        title: title);
  }

  Future<void> deleteTransactions({required int transId}) async {
    int response = await helper.DatabaseHelper.instance
        .deleteTransaction(transId: transId);
  }

  void updateTransaction(
      {required int transId,
      required int amount,
      required String transType,
      required description}) async {
    await helper.DatabaseHelper.instance.updateTransaction(
        transId: transId,
        amount: amount,
        transType: transType,
        description: description);
  }
}
