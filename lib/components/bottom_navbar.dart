import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../theme/app_theme.dart';
import '../pages/posts/posts_page.dart';
import '../pages/book/bookmarks_page.dart';
import '../pages/mypost/mypost_page.dart';
import '../pages/profile/profile_page.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  void navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PostsPage()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookmarksPage()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPostPage()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          // The bar fills the screen width and only becomes scrollable when the
          // tabs no longer fit (very narrow screens / large system fonts).
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : 0,
                  ),
                  child: GNav(
                    selectedIndex: currentIndex,
                    onTabChange: (index) {
                      navigate(context, index);
                    },
                    gap: 6,
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    tabBorderRadius: AppRadius.button,
                    backgroundColor: AppColors.surface,
                    color: AppColors.textSecondary,
                    activeColor: Colors.white,
                    tabBackgroundColor: AppColors.primary,
                    iconSize: 22,
                    textStyle: AppText.label.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    tabs: const [
                      GButton(icon: Icons.home_outlined, text: 'Beranda'),
                      GButton(icon: Icons.bookmark_outline, text: 'Tersimpan'),
                      GButton(icon: Icons.article_outlined, text: 'Postingan'),
                      GButton(icon: Icons.person_outline, text: 'Profil'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
