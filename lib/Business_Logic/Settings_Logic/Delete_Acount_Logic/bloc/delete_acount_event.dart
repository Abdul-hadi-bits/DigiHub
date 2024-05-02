part of 'delete_acount_bloc.dart';

sealed class DeleteAcountEvent extends Equatable {
  const DeleteAcountEvent();

  @override
  List<Object> get props => [];
}

class PasswordChangedEvent extends DeleteAcountEvent {
  final String password;
  PasswordChangedEvent({required this.password});
}

class AcountDeletedEvent extends DeleteAcountEvent {
  final ChatState chatState;
  AcountDeletedEvent(this.chatState);
}

class TogglePasswordEvent extends DeleteAcountEvent {}
