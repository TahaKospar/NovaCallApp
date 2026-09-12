import 'package:novacall/data/model/contacts.dart';
import 'package:novacall/data/services/contactServices.dart';

class ContactRepository {
  final Contactservices contactServices;
  ContactRepository(this.contactServices);

  Future<List<Contacts>> getAllContacts() async {
    final rawContacts = await contactServices.getAllContacts();
    return rawContacts.map((e) => Contacts.fromJson(e)).toList();
  }

  Stream<List<Contacts>> getUserStream() {
    return contactServices
        .getUserStream()
        .map((list) => list.map((e) => Contacts.fromJson(e)).toList());
  }

  Future<void> blockUser(String userId) async {
    await contactServices.blockUser(userId);
  }

  Future<void> unblockUser(String userId) async {
    await contactServices.unblockUser(userId);
  }

  Future<List<String>> getBlockedUsers() async {
    return await contactServices.getBlockedUsers();
  }
}