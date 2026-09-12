part of 'contact_cubit.dart';

@immutable
abstract class ContactState {}

final class ContactInitial extends ContactState {}

final class ContactLoading extends ContactState {}

final class ContactLoaded extends ContactState {
  final List<Contacts> contacts;
  final List<Contacts> filteredContacts;
  final String searchQuery;

  ContactLoaded(
    this.contacts, {
    List<Contacts>? filteredContacts,
    this.searchQuery = '',
  }) : filteredContacts = filteredContacts ?? contacts;
}

final class ContactError extends ContactState {
  final String errorMessage;
  ContactError(this.errorMessage);
}