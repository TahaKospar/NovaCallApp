import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/presentation/screens/main/call_screen.dart';
// تأكد إنك عامل import لملف شاشة المكالمات بالمسار الصح بتاعك

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactCubit>(context).emitGetAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 45, 95, 185),
        title: const Text(
          "Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                // جلب البيانات من الموديل
                final userName = user.name ?? 'No Name';
                // لازم تكون ضفت isOnline في الموديل زي ما اتفقنا
                final bool isOnline = user.isOnline ?? false;
                // افترضنا إن الموديل فيه متغير uid عشان نقدر نربط المكالمة بيه
                final String targetUserId = user.uid ?? 'unknown_id'; 

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 45, 95, 185),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      isOnline ? "Online" : "Offline",
                      style: TextStyle(
                        color: isOnline ? Colors.green.shade700 : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر المكالمة الصوتية
                        IconButton(
                          icon: const Icon(
                            Icons.call,
                            color: Colors.black54,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  callID: 'call_$targetUserId', 
                                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                                  currentUserName: 'أنا', // تقدر تجيب اسم اليوزر الحالي لو مخزنه
                                  isVideo: false,
                                ),
                              ),
                            );
                          },
                        ),
                        // زر مكالمة الفيديو
                        IconButton(
                          icon: const Icon(
                            Icons.video_call,
                            color: Colors.black54,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  callID: 'call_$targetUserId',
                                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                                  currentUserName: 'أنا', 
                                  isVideo: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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