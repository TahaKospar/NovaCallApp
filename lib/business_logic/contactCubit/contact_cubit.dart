import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:novacall/data/model/contacts.dart';
import 'package:novacall/data/repository/contact_repository.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepository contactRepository;
  StreamSubscription? _contactsSubscription;

  ContactCubit(this.contactRepository) : super(ContactInitial());

  void listenToContacts() {
    emit(ContactLoading());

    _contactsSubscription?.cancel();
    _contactsSubscription = contactRepository.getUserStream().listen(
      (contactsList) {
        emit(ContactLoaded(contactsList));
      },
      onError: (error) {
        emit(ContactError(error.toString()));
      },
    );
  }

  Future<void> emitGetAllContacts() async {
    emit(ContactLoading());
    try {
      final contactsList = await contactRepository.getAllContacts();
      emit(ContactLoaded(contactsList));
    } catch (error) {
      emit(ContactError(error.toString()));
    }
  }

  void searchContacts(String query) {
    final currentState = state;
    if (currentState is ContactLoaded) {
      if (query.isEmpty) {
        emit(ContactLoaded(currentState.contacts));
        return;
      }

      final filtered = currentState.contacts.where((contact) {
        final name = contact.name.toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower);
      }).toList();

      emit(
        ContactLoaded(
          currentState.contacts,
          filteredContacts: filtered,
          searchQuery: query,
        ),
      );
    }
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is ContactLoaded) {
      emit(ContactLoaded(currentState.contacts));
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await contactRepository.blockUser(userId);
      listenToContacts();
    } catch (e) {
      emit(ContactError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}