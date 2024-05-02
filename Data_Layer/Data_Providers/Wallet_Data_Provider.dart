// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:sqflite/sqflite.dart" as sqflite;

class WalletDataProvider {
  sqflite.Database database;
  WalletDataProvider({
    required this.database,
  });
  Future<bool> addTransaction(
      {required String date,
      required int amount,
      required String transType,
      required String description,
      required String title,
      required String category}) async {
    try {
      await database.execute('''insert into daily_trans(
        transactionDate,
         transactionAmount,
         transactionType,
         transactionDescription,
         transactionTitle,
         transactionCategory
         )values(date('$date'),$amount,'$transType','$description','$title','$category')
      ''');
      return true;
    } on sqflite.DatabaseException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<int> getSumOfYear(
      {required String date,
      required String transType,
      required String transCategory}) async {
    try {
      List<Map<String, dynamic>> result;
      if (transCategory == "All") {
        if (transType.isEmpty && transCategory == "All") {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where strftime('%Y', transactionDate)=strftime('%Y', '$date')
       ''');
        } else {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
        strftime('%Y', transactionDate)=strftime('%Y', '$date') AND 
        transactionType='$transType'
        )
       ''');
        }
      } else {
        if (transType.isEmpty && transCategory == "All") {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where strftime('%Y', transactionDate)=strftime('%Y', '$date')
      AND transactionCategory='$transCategory'

       ''');
        } else {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
        strftime('%Y', transactionDate)=strftime('%Y', '$date') AND 
        transactionType='$transType'
        AND transactionCategory='$transCategory'

        )
       ''');
        }
      }

      return result.first["sum(transactionAmount)"];
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getSumOfMonth(
      {required String date,
      required String transType,
      required String tranCategory}) async {
    try {
      List<Map<String, dynamic>> result;
      if (tranCategory == "All") {
        if (transType.isEmpty) {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
          strftime('%Y', transactionDate)=strftime('%Y', '$date') 
          AND strftime('%m', transactionDate)=strftime('%m', '$date')
      )
       ''');
        } else {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
          strftime('%Y', transactionDate)=strftime('%Y', '$date') 
          AND strftime('%m', transactionDate)=strftime('%m', '$date')
          AND transactionType='$transType'
          
          )
      ''');
        }
      } else {
        if (transType.isEmpty) {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
          strftime('%Y', transactionDate)=strftime('%Y', '$date') 
          AND strftime('%m', transactionDate)=strftime('%m', '$date')
          AND transactionCategory='$tranCategory'

      )
       ''');
        } else {
          result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
      where (
          strftime('%Y', transactionDate)=strftime('%Y', '$date') 
          AND strftime('%m', transactionDate)=strftime('%m', '$date')
          AND transactionType='$transType'
          AND transactionCategory='$tranCategory'
          
          )
      ''');
        }
      }

      // print('in database helper : ${result.first["sum(transactionAmount)"]}');
      if (result.first["sum(transactionAmount)"] != null) {
        return result.first["sum(transactionAmount)"];
      }
      return 0;
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getSumOfDay(
      {required String date, required String transType}) async {
    try {
      List<Map<String, dynamic>> result;
      if (transType.isEmpty) {
        result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
       where (
          date(transactionDate)=date('$date') 
          
      )
       ''');
      } else {
        result = await database.rawQuery('''
      select sum(transactionAmount)  
      from daily_trans 
       where (
          date(transactionDate)=date('$date') 
          AND transactionType='$transType'
      )
       ''');
      }

      return result.first["sum(transactionAmount)"];
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInDay(
      {required String date, required String transType}) async {
    try {
      if (transType.isEmpty) {
        return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE transactionDate=date('$date')
    ''');
      } else {
        return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( transactionDate=date('$date')
        AND transactionType='$transType'
        )

    ''');
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInMonth(
      {required String date, required String transType}) async {
    try {
      if (transType.isEmpty) {
        return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE (
          strftime('%Y', transactionDate)=strftime('%Y', '$date') 
          AND strftime('%m', transactionDate)=strftime('%m', '$date')
          )
    ''');
      } else {
        return await database.rawQuery('''
        SELECT * from daily_trans WHERE (
          strftime('%Y',transactionDate)= strftime('%Y',date('$date') ) AND
          strftime('%m',transactionDate)= strftime('%m',date('$date') ) AND
          transactionType='$transType'
          )
    ''');
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInYear(
      {required String date,
      required String transType,
      required String transCategory}) async {
    try {
      if (transCategory == "All") {
        if (transType.isEmpty) {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date')
        )
    ''');
        } else {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND
        transactionType='$transType'
        )
    ''');
        }
      } else {
        if (transType.isEmpty) {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date')
        AND transactionType='$transType'
          AND transactionCategory='$transCategory'


        )
    ''');
        } else {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND
        transactionType='$transType'
          AND transactionCategory='$transCategory'

        )
    ''');
        }
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInYearWhereDayIs(
      {required String date,
      required String transType,
      required String transCategory}) async {
    try {
      if (transCategory == "All") {
        if (transType.isEmpty) {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND
        strftime('%d',transactionDate)= strftime('%d',date('$date') )
        )
    ''');
        } else {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND
        strftime('%d',transactionDate)= strftime('%d',date('$date') ) AND
        transactionType='$transType'
        )
    ''');
        }
      } else {
        if (transType.isEmpty) {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND 
        strftime('%d',transactionDate)= strftime('%d',date('$date') ) AND
        transactionType='$transType' AND
        transactionCategory='$transCategory'


        )
    ''');
        } else {
          return await database.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',transactionDate)=strftime('%Y','$date') AND
        strftime('%d',transactionDate)= strftime('%d',date('$date') ) AND
        transactionType='$transType' AND
        transactionCategory='$transCategory'

        )
    ''');
        }
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<int> updateTransaction(
      {required int transId,
      required String title,
      required String category,
      required int amount,
      required String transType,
      required String description}) async {
    try {
      return await database.rawUpdate('''
      UPDATE daily_trans
      SET transactionAmount=$amount, transactionType='$transType', transactionCategory='$category', transactionTitle='$title', transactionDescription='$description' 
      WHERE transactionId=$transId;
    ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteTransaction({required int transId}) async {
    try {
      print("id is $transId");
      return await database.rawDelete('''
      delete from daily_trans where transactionId=$transId
     ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
