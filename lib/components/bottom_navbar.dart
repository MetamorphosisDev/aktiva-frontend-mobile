import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../pages/posts/posts_page.dart';
// import '../pages/bookmarks/bookmarks_page.dart';
// import '../pages/profile/profile_page.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  void navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PostsPage()),
        );
        break;

      case 2:
        // TODO: BookmarksPage
        break;

      case 3:
        // TODO: ProfilePage
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: GNav(
        selectedIndex: currentIndex,
        onTabChange: (index) {
          navigate(context, index);
        },
        gap: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        tabBorderRadius: 30,
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.black,
        tabs: const [
          GButton(icon: Icons.home_outlined, text: 'Home'),
          GButton(icon: Icons.article_outlined, text: 'Posts'),
          GButton(icon: Icons.bookmark_outline, text: 'Bookmarks'),
          GButton(icon: Icons.person_outline, text: 'Profile'),
        ],
      ),
    );
  }
}
