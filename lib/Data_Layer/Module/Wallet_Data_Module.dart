// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WalletDataModule {
  int transactionId = 0;
  int transactionAmount = 0;
  String transactionDate = "";
  String transactionType = "";
  String transactionDescription = "";
  String transactionTitle = "";
  String transactionCategory = "";
  WalletDataModule({
    required this.transactionCategory,
    required this.transactionId,
    required this.transactionAmount,
    required this.transactionDate,
    required this.transactionType,
    required this.transactionDescription,
    required this.transactionTitle,
  });

  WalletDataModule copyWith({
    String? transactionCategory,
    int? transactionId,
    int? transactionAmount,
    String? transactionDate,
    String? transactionType,
    String? transactionDescription,
    String? transactionTitle,
  }) {
    return WalletDataModule(
      transactionCategory: transactionCategory ?? this.transactionCategory,
      transactionId: transactionId ?? this.transactionId,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionType: transactionType ?? this.transactionType,
      transactionDescription:
          transactionDescription ?? this.transactionDescription,
      transactionTitle: transactionTitle ?? this.transactionTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transactionId': transactionId,
      'transactionAmount': transactionAmount,
      'transactionDate': transactionDate,
      'transactionType': transactionType,
      'transactionDescription': transactionDescription,
      'transactionTitle': transactionTitle,
      'transactionCategory': transactionCategory,
    };
  }

///////////please fix the names of fields , make them the same in both DataModules and DataProvider queries.
  factory WalletDataModule.fromMap(Map<String, dynamic> map) {
    return WalletDataModule(
      transactionId: map['transactionId'] as int,
      transactionAmount: map['transactionAmount'] as int,
      transactionDate: map['transactionDate'] as String,
      transactionType: map['transactionType'] as String,
      transactionDescription: map['transactionDescription'] as String,
      transactionTitle: map['transactionTitle'] as String,
      transactionCategory: map['transactionCategory'] as String,
    );
  }

  static List<WalletDataModule> fromListMap(
      List<Map<String, dynamic>> listMap) {
    List<WalletDataModule> listOfWalletDataModuleObjects = [];

    listMap.forEach((map) {
      listOfWalletDataModuleObjects.add(WalletDataModule.fromMap(map));
    });
    return listOfWalletDataModuleObjects;
  }

  String toJson() => json.encode(toMap());

  factory WalletDataModule.fromJson(String source) =>
      WalletDataModule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WalletDataModule(transactionId: $transactionId, transactionAmount: $transactionAmount, transactionDate: $transactionDate, transactionType: $transactionType, transactionDescription: $transactionDescription, transactionTitle: $transactionTitle,transactionCategory:$transactionCategory)';
  }

  @override
  bool operator ==(covariant WalletDataModule other) {
    if (identical(this, other)) return true;

    return other.transactionId == transactionId &&
        other.transactionAmount == transactionAmount &&
        other.transactionDate == transactionDate &&
        other.transactionType == transactionType &&
        other.transactionDescription == transactionDescription &&
        other.transactionTitle == transactionTitle &&
        other.transactionCategory == transactionCategory;
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^
        transactionAmount.hashCode ^
        transactionDate.hashCode ^
        transactionType.hashCode ^
        transactionDescription.hashCode ^
        transactionTitle.hashCode ^
        transactionCategory.hashCode;
  }
}
