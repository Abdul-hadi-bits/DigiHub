import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/Wallet_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Wallet_Data_Repository.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart' as intl;

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  late WalletDataRepository _walletRepository =
      WalletDataRepository(database: LocalDbProvider.database!);
  WalletBloc()
      : super(WalletState(
          status: WalletStatus.initalized,
          showAvg: false,
          allTransactionInCurrentYear: [],
          allTransactionInCustomYear: [],
          sumOfMonths: [],
          sumOfYear: 0,
        )) {
    on<WalletInitalized>(_intializeWallet);
    on<WalletUpdatedMoneyField>(_updateMoneyField);
    on<WalletUpdatedTitleField>(_updateTitile);
    on<WalletUpdatedDescriptionField>(_updateDescription);
    on<WalletAddedTransaction>(_addTransaction);
    on<WalletToggledGraph>(_toggleGraph);
  }

  FutureOr<void> _intializeWallet(
      WalletInitalized event, Emitter<WalletState> emit) async {
    final currentDate = currentDateFormatted();
    String year = currentDate.substring(0, 4);
    final sumOfYear = await _walletRepository.getSumOfYear(
        date: '$year-01-01', transType: 'spent', category: "All");
    final sumOfMonths = await sumOfmonths(year: year);
    final allTransactionInCurrentYear =
        await _walletRepository.getAllTransactionsInYear(
            date: currentDateFormatted(), transType: 'spent', category: "All");

    emit(state.copyWith(
        allTransactionInCurrentYear: allTransactionInCurrentYear,
        sumOfYear: sumOfYear,
        sumOfMonths: sumOfMonths,
        allTransactionInCustomYear: [],
        status: WalletStatus.initalized));
  }

  FutureOr<void> _updateMoneyField(
      WalletUpdatedMoneyField event, Emitter<WalletState> emit) {}

  FutureOr<void> _updateTitile(
      WalletUpdatedTitleField event, Emitter<WalletState> emit) {}

  FutureOr<void> _updateDescription(
      WalletUpdatedDescriptionField event, Emitter<WalletState> emit) {}

  FutureOr<void> _addTransaction(
      WalletAddedTransaction event, Emitter<WalletState> emit) {}

  FutureOr<void> _toggleGraph(
      WalletToggledGraph event, Emitter<WalletState> emit) {}

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    intl.DateFormat formatter = intl.DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  Future<List<int>> sumOfmonths({required String year}) async {
    List<String> months = [
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
      '12',
    ];
    List<int> sumOfMons = [];
    for (int month = 0; month <= 11; month++) {
      //do it for every month in the year
      //date = currentDateFormatted();
      String date = '$year-${months[month]}-01';
      int sumMonth = await _walletRepository.getSumOfMonth(
          date: date, transType: 'spent', category: "All");
      sumOfMons.add(sumMonth);
    }

    return sumOfMons;
  }
}
