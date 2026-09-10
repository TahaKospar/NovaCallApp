import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:novacall/data/model/contacts.dart';
import 'package:novacall/data/repository/contact_repository.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepository contactRepository;
  ContactCubit(this.contactRepository) : super(ContactInitial());

  void emitGetAllContacts() {
    emit(ContactLoading());

    contactRepository
        .getAllContacts()
        .then((contactsList) {
          emit(ContactLoaded(contactsList));
        })
        .catchError((error) {
          emit(ContactError(error.toString()));
        });
  }
}
