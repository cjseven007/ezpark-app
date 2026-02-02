import 'package:ezpark/models/nav_item.dart';
import 'package:ezpark/views/pages/home_page.dart';
import 'package:ezpark/views/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ezpark/controllers/landing_page_controller.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

  final LandingPageController controller = Get.put(LandingPageController());
  final List<NavItem> navItems = [
    NavItem(label: 'Home', icon: Icons.home_rounded, page: const HomePage()),
    NavItem(label: 'Profile', icon: Icons.person, page: const ProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Obx listens to changes in the controller's tabIndex
      body: Obx(() => IndexedStack(
            index: controller.tabIndex.value,
            children: navItems.map((item) => item.page).toList(),
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            // Loop through navItems to create the bar items
            items: navItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              );
            }).toList(),
          )),
    );
  }
}