import 'package:ezpark/controllers/landing_page_controller.dart';
import 'package:ezpark/models/nav_item.dart';
import 'package:ezpark/utils/my_colours.dart';
import 'package:ezpark/views/pages/favourites_page.dart';
import 'package:ezpark/views/pages/home_page.dart';
import 'package:ezpark/views/pages/profile_page.dart';
import 'package:ezpark/views/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

  final LandingPageController controller = Get.put(LandingPageController());

  final List<NavItem> navItems = [
    NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      page: HomePage(key: homePageKey),
    ),
    NavItem(label: 'Search', icon: Icons.search, page: const SearchPage()),
    NavItem(
      label: 'Favourites',
      icon: Icons.favorite_border,
      page: const FavouritesPage(),
    ),
    NavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      page: const ProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LandingPageController>(
      init: controller,
      builder: (_) {
        return Scaffold(
          body: Obx(
            () => IndexedStack(
              index: controller.tabIndex.value,
              children: navItems.map((item) => item.page).toList(),
            ),
          ),

          floatingActionButton: Obx(() {
            final isHomeTab = controller.tabIndex.value == 0;

            if (!isHomeTab) return const SizedBox.shrink();

            return FloatingActionButton(
              onPressed: () {
                final homeState = homePageKey.currentState;
                homeState?.moveToUserLocation();
              },
              backgroundColor: MyColours.secondary,
              child: const Icon(Icons.my_location, color: Colors.black),
            );
          }),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 8,
              ),
              child: Obx(
                () => GNav(
                  haptic: true,
                  tabBorderRadius: 50,
                  gap: 5,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  duration: const Duration(milliseconds: 400),
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[300]!,
                  activeColor: Colors.white,
                  tabBackgroundColor: MyColours.primary,
                  color: Colors.grey[600]!,
                  selectedIndex: controller.tabIndex.value,
                  onTabChange: (index) {
                    controller.changeTabIndex(index);
                  },
                  tabs: navItems.map((item) {
                    return GButton(icon: item.icon, text: item.label);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
