import 'package:flutter/material.dart';
import 'package:novacall/presentation/screens/main/contacts_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // دي الشاشات اللي هيتنقل بينها الـ Bottom Navigation Bar
  final List<Widget> _screens = [
    const HomeTab(), // التاب الرئيسية اللي فيها الشغل
    const ContactsScreen(),
    const Center(child: Text("Profile Tab", style: TextStyle(fontSize: 24))),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex], // بيعرض الشاشة حسب التاب اللي متداس عليه
      // الـ Bottom Navigation Bar بناءً على الصورة
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // ضروري عشان لو أكتر من 3 عناصر
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

// ==========================================
// محتوى التاب الأول (Home) اللي فيه السكرول والسيرش
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // الـ SliverAppBar هو اللي بيسمح للـ AppBar إنه يختفي مع السكرول
        SliverAppBar(
          floating: true, // بيخلي الـ AppBar يظهر أول ما تسكرول لفوق
          snap: true, // بيخليه يظهر بالكامل بمجرد لمسة سكرول خفيفة لفوق
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
            // User Profile (زي ما مطلوب في الصورة)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
                // backgroundImage: NetworkImage('رابط صورة اليوزر لو موجودة'),
              ),
            ),
          ],
          // السيرش بار جوه الـ bottom عشان ينزل ويطلع مع الـ AppBar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                // onChanged: (value) => BlocProvider.of<ContactCubit>(context).search(value),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search contacts or calls...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
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

        // محتوى الشاشة (Recent Calls & Contacts)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Recent Calls Section
                const Text(
                  "Recent Calls",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // بنقفل السكرول الداخلي عشان الـ CustomScrollView يشتغل صح
                  itemCount: 3, // عدد وهمي للتجربة
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text("User ${index + 1}"),
                      subtitle: const Text(
                        "Missed call • 2h ago",
                        style: TextStyle(color: Colors.red),
                      ),
                      trailing: const Icon(Icons.call, color: Colors.green),
                    );
                  },
                ),

                const Divider(height: 30, thickness: 1),

                // 2. Contacts / Users Section
                const Text(
                  "Contacts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // هنا هتحط الـ BlocBuilder بتاع الـ ContactCubit
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 15, // عدد وهمي للتجربة عشان تشوف تأثير السكرول
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text("C${index + 1}"),
                      ),
                      title: Text("Contact ${index + 1}"),
                      subtitle: const Text("Online"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
