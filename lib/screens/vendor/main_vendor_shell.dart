import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planit_mt/providers/auth_provider.dart';
import 'package:planit_mt/providers/booking_provider.dart';
import 'package:planit_mt/providers/chat_provider.dart';
import 'package:planit_mt/screens/vendor/client_messages_page.dart';
import 'package:planit_mt/screens/vendor/vendor_community_page.dart';
import 'package:planit_mt/screens/vendor/vendor_home_screen.dart';
import 'package:planit_mt/screens/vendor/vendor_profile_page.dart';
import 'package:planit_mt/screens/vendor/your_packages_page.dart';

class MainVendorShell extends StatefulWidget {
  const MainVendorShell({super.key});

  @override
  State<MainVendorShell> createState() => _MainVendorShellState();
}

class _MainVendorShellState extends State<MainVendorShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final user = context.read<AuthProvider>().firebaseUser;
    final vendorId = user?.uid;
    if (vendorId == null) return;

    // fire-and-forget; providers יכולים לנהל טעינה/שגיאות פנימית
    try {
      context.read<BookingProvider>().fetchVendorBookings(vendorId);
    } catch (_) {}
    try {
      context.read<ChatProvider>().getChatRooms(vendorId);
    } catch (_) {}
  }

  static const List<Widget> _pages = <Widget>[
    VendorHomeScreen(),
    YourPackagesPage(),
    VendorCommunityPage(),
    ClientMessagesPage(),
    VendorProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Packages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFBFA054),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }
}
