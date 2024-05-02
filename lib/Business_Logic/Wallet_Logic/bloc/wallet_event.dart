part of 'wallet_bloc.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class WalletInitalized extends WalletEvent {}

class WalletUpdatedMoneyField extends WalletEvent {}

class WalletUpdatedDescriptionField extends WalletEvent {}

class WalletUpdatedTitleField extends WalletEvent {}

class WalletAddedTransaction extends WalletEvent {}

class WalletToggledGraph extends WalletEvent {}
