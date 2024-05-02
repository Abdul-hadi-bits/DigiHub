// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'wallet_bloc.dart';

enum WalletStatus {
  initalized,
  updatedMoneyField,
  updatedTitleField,
  updatedDescriptionField,
  addedTransaction,
  toggledGraph
}

class WalletState extends Equatable {
  WalletState({
    required this.status,
    required this.showAvg,
    required this.sumOfYear,
    required this.sumOfMonths,
    required this.allTransactionInCurrentYear,
    required this.allTransactionInCustomYear,
  });

  @override
  List<Object> get props => [
        status,
        showAvg,
        sumOfYear,
        sumOfMonths,
        allTransactionInCurrentYear,
      ];

  late final WalletStatus status;
  late final bool showAvg;

  late final int sumOfYear;
  late final List<int> sumOfMonths;
  late final List<WalletDataModule> allTransactionInCurrentYear;
  late final List<WalletDataModule> allTransactionInCustomYear;

  WalletState copyWith({
    WalletStatus? status,
    bool? showAvg,
    int? sumOfYear,
    List<int>? sumOfMonths,
    List<WalletDataModule>? allTransactionInCurrentYear,
    List<WalletDataModule>? allTransactionInCustomYear,
  }) {
    return WalletState(
      status: status ?? this.status,
      showAvg: showAvg ?? this.showAvg,
      sumOfYear: sumOfYear ?? this.sumOfYear,
      sumOfMonths: sumOfMonths ?? this.sumOfMonths,
      allTransactionInCurrentYear:
          allTransactionInCurrentYear ?? this.allTransactionInCurrentYear,
      allTransactionInCustomYear:
          allTransactionInCustomYear ?? this.allTransactionInCustomYear,
    );
  }
}
