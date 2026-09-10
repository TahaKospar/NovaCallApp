part of 'contact_cubit.dart';

@immutable
abstract class ContactState {}

final class ContactInitial extends ContactState {}

final class ContactLoading extends ContactState {}

final class ContactLoaded extends ContactState {
  final List<Contacts> contacts;
  ContactLoaded(this.contacts);
}

final class ContactError extends ContactState {
  final String errorMessage;
  ContactError(this.errorMessage);
}
