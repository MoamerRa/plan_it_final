import 'package:flutter/material.dart';
import 'package:planit_mt/screens/community/community_page.dart';
import 'package:planit_mt/screens/user/explore_vendors_page.dart';
import 'package:planit_mt/screens/user/plan_event.dart';
import 'package:planit_mt/screens/user/user_home_screen.dart';
import 'package:planit_mt/screens/user/user_profile_page.dart';
import 'package:planit_mt/widgets/custom_bottom_nav_bar.dart';

class MainUserShell extends StatefulWidget {
  const MainUserShell({super.key});

  @override
  State<MainUserShell> createState() => _MainUserShellState();
}

class _MainUserShellState extends State<MainUserShell> {
  int _selectedIndex = 0;

  // רשימת המסכים הראשיים למשתמש
  static const List<Widget> _pages = <Widget>[
    UserHomeScreen(),
    ExploreVendorsPage(),
    PlanEvent(),
    CommunityPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
