import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/presentation/widgets/user_tile.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactCubit>(context).listenToContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contacts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ContactCubit, ContactState>(
        builder: (context, state) {
          if (state is ContactLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 45, 95, 185),
              ),
            );
          } else if (state is ContactLoaded) {
            final users = state.contacts;

            if (users.isEmpty) {
              return const Center(
                child: Text(
                  "No contacts found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserTile(
                  userId: user.uid,
                  userName: user.name,
                  isOnline: user.isOnline,
                );
              },
            );
          } else if (state is ContactError) {
            return Center(
              child: Text(
                "Error: ${state.errorMessage}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
