import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:novacall/business_logic/callHistoryCubit/call_history_cubit.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/data/model/call_model.dart';
import 'package:novacall/presentation/screens/main/contacts_tab.dart';
import 'package:novacall/presentation/screens/main/profile_tab.dart';
import 'package:novacall/presentation/widgets/user_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeTab(searchController: searchController),
      const ContactsScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 45, 95, 185),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final TextEditingController searchController;

  const HomeTab({super.key, required this.searchController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
@override
void initState() {
  super.initState();
  context.read<CallHistoryCubit>().loadHistory();
  context.read<CallHistoryCubit>().loadFrequentContacts();
  context.read<ContactCubit>().listenToContacts();
}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: const Color.fromARGB(255, 45, 95, 185),
          elevation: 0,
          title: const Text(
            "NovaCall",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: _UserAvatar(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: widget.searchController,
                onChanged: (value) {
                  BlocProvider.of<ContactCubit>(context).searchContacts(value);
                  setState(() {});
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: widget.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            widget.searchController.clear();
                            BlocProvider.of<ContactCubit>(
                              context,
                            ).clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Frequently Called",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<CallHistoryCubit, CallHistoryState>(
                  builder: (context, state) {
                    final frequent = context
                        .read<CallHistoryCubit>()
                        .frequentContacts;

                    if (frequent.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            "No frequent contacts yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: frequent.length,
                        itemBuilder: (context, index) {
                          final contact = frequent[index];
                          final name = contact['name'] as String;

                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 45, 95, 185),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const Divider(height: 30, thickness: 1),

                Text(
                  widget.searchController.text.isNotEmpty
                      ? "Search Results"
                      : "Contacts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<ContactCubit, ContactState>(
                  builder: (context, state) {
                    if (state is ContactLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 45, 95, 185),
                          ),
                        ),
                      );
                    } else if (state is ContactLoaded) {
                      final contacts = state.filteredContacts;

                      if (contacts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "No contacts found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final user = contacts[index];
                          return UserTile(
                            userId: user.uid,
                            userName: user.name,
                            isOnline: user.isOnline,
                            onCallFinished: () {
                              context.read<CallHistoryCubit>().loadHistory();
                              context
                                  .read<CallHistoryCubit>()
                                  .loadFrequentContacts();
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const Divider(height: 30, thickness: 1),

                Text(
                  "Call History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<CallHistoryCubit, CallHistoryState>(
                  builder: (context, state) {
                    if (state is CallHistoryLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 45, 95, 185),
                          ),
                        ),
                      );
                    } else if (state is CallHistoryLoaded) {
                      final calls = state.calls;

                      if (calls.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "No call history",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: calls.length,
                        itemBuilder: (context, index) {
                          return _buildCallHistoryTile(
                            calls[index],
                            textColor,
                            FirebaseAuth.instance.currentUser!.uid,
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallHistoryTile(
    CallModel call,
    Color? textColor,
    String currentUserId,
  ) {
    final isMissed = call.isMissed();
    final isVideo = call.type == CallType.video;
    final isOutgoing = call.isOutgoing(currentUserId);
    final otherName = isOutgoing ? call.receiverName : call.callerName;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isMissed
            ? Colors.red.withOpacity(0.2)
            : Colors.blue.shade100,
        child: Icon(
          isVideo ? Icons.videocam : Icons.call,
          color: isMissed ? Colors.red : const Color.fromARGB(255, 45, 95, 185),
          size: 20,
        ),
      ),
      title: Text(
        otherName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isMissed ? Colors.red : textColor,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            isOutgoing ? Icons.call_made : Icons.call_received,
            size: 14,
            color: isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isVideo ? "Video" : "Audio",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(call.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(call.durationInSeconds),
            style: TextStyle(
              fontSize: 12,
              color: isMissed ? Colors.red : Colors.grey,
              fontWeight: isMissed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(date.year, date.month, date.day);

    if (callDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (callDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'Missed';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        String initial = '?';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] as String? ?? '';
          if (name.isNotEmpty) {
            initial = name[0].toUpperCase();
          }
        }

        return CircleAvatar(
          backgroundColor: Colors.white24,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
