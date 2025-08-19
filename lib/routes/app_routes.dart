import 'package:flutter/material.dart';
import 'package:planit_mt/screens/admin/admin_home_screen.dart';
import 'package:planit_mt/screens/admin/approve_vendors_page.dart';
import 'package:planit_mt/screens/admin/manage_vendors_page.dart';
import 'package:planit_mt/screens/admin/statistics_page.dart';
import 'package:planit_mt/screens/admin/user_reports_page.dart';
import 'package:planit_mt/screens/authentication/login.dart';
import 'package:planit_mt/screens/authentication/signup.dart';
import 'package:planit_mt/screens/community/community_page.dart';
import 'package:planit_mt/screens/user/create_event_page.dart';
import 'package:planit_mt/screens/user/explore_vendors_page.dart';
import 'package:planit_mt/screens/user/budget.dart';
import 'package:planit_mt/screens/user/full_calendar_page.dart';
import 'package:planit_mt/screens/user/main_user_shell.dart';
import 'package:planit_mt/screens/user/plan_event.dart';
import 'package:planit_mt/screens/user/recommended_packages_page.dart';
import 'package:planit_mt/screens/user/task_screen.dart';
import 'package:planit_mt/screens/user/user_profile_page.dart';
import 'package:planit_mt/screens/user/vendor_details.dart';
import 'package:planit_mt/screens/vendor/add_post_page.dart';
import 'package:planit_mt/screens/vendor/client_messages_page.dart';
import 'package:planit_mt/screens/vendor/edit_vendor_profile_page.dart';
import 'package:planit_mt/screens/vendor/main_vendor_shell.dart';
import 'package:planit_mt/screens/vendor/vendor_community_page.dart';
import 'package:planit_mt/screens/authentication/welcome_screen.dart';
import 'package:planit_mt/screens/vendor/vendor_profile_page.dart';
import 'package:planit_mt/screens/vendor/your_packages_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        //Authentication
        '/': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        //User
        '/userHome': (context) => const MainUserShell(),
        '/userprofile': (context) => const UserProfilePage(),
        '/userplan': (context) => const PlanEvent(),
        '/recommend': (context) => const RecommendedPackagesPage(),
        '/budget': (context) => const BudgetBreakdownPage(),
        '/calendar': (context) => const FullCalendarPage(),
        '/createEvent': (context) => const CreateEventPage(),
        '/tasks': (context) => const TaskScreen(), // Add the new route

        '/vendordetails': (context) => const VendorDetailsPage(),
        //Vendor
        '/vendorHome': (context) => const MainVendorShell(),
        '/vendorprofile': (context) => const VendorProfilePage(),
        '/addPost': (context) => const AddPostPage(),
        '/vendorcommunity': (context) => const VendorCommunityPage(),
        '/packages': (context) => const YourPackagesPage(),
        '/clientmessage': (context) => const ClientMessagesPage(),
        '/editVendorProfile': (context) => const EditVendorProfilePage(),

        //Admin
        '/adminHome': (context) => const AdminHomeScreen(),
        '/managevendors': (context) => const ManageVendorsPage(),
        '/statistics': (context) => const StatisticsPage(),
        '/reports': (context) => const UserReportsPage(),
        '/approveVendors': (context) => const ApproveVendorsPage(),

        //Community
        '/community': (context) => const CommunityPage(),
        '/task': (context) => const ExploreVendorsPage(),
      };
}
