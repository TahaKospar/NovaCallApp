import 'package:novacall/data/model/contacts.dart';
import 'package:novacall/data/services/contactServices.dart';
class ContactRepository {
  final Contactservices contactServices;
  ContactRepository(this.contactServices);
  Future<List<Contacts>> getAllContacts() async {
    final rawContacts = await contactServices.getAllContacts();
    return rawContacts.map((e) => Contacts.fromJson(e)).toList();
  }
}