import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../../../../app_export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsCtrl>();
    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(controller),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildSectionHeader("ACCOUNT PREFERENCES"),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    Obx(
                      () => _buildMenuItem(
                        icon: Icons.notifications_active_outlined,
                        title: "Notifications",
                        subtitle: "Tone, vibrations & alerts",
                        onTap: () {},
                        trailing: Switch.adaptive(
                          value: controller.isNotificationEnabled.value,
                          onChanged: controller.toggleNotification,
                          activeColor: AppThemeColors.primaryOrange,
                          inactiveThumbColor: AppThemeColors.white,
                          inactiveTrackColor: AppThemeColors.greyText.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader("SUPPORT & LEGAL"),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(icon: Icons.article_outlined, title: "Terms of Service", onTap: controller.openTermsAndConditions),
                    _buildDivider(),
                    _buildMenuItem(icon: Icons.verified_user_outlined, title: "Privacy Policy", onTap: controller.openPrivacyPolicy),
                    _buildDivider(),
                    _buildMenuItem(icon: Icons.support_agent_rounded, title: "Contact Support", onTap: controller.contactsupport),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader("ACCOUNT POTIONS"),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      onTap: controller.logout,
                      iconColor: AppThemeColors.error.withValues(alpha: 0.8),
                      textColor: AppThemeColors.error,
                      showChevron: false,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.no_accounts_outlined,
                      title: "Delete My Account",
                      onTap: controller.deleteAccount,
                      iconColor: AppThemeColors.error,
                      textColor: AppThemeColors.error.withValues(alpha: 0.8),
                      showChevron: false,
                    ),
                  ]),
                  const SizedBox(height: 28),
                  _buildFooter(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSliverAppBar(SettingsCtrl controller) {
  //   return Obx(() {
  //     final userData = controller.authService.userAuthData;
  //     final name = userData['name'] ?? "User Name";
  //     final email = userData['email'] ?? "user@example.com";

  //     return SliverAppBar(
  //       expandedHeight: 200,
  //       pinned: true,
  //       stretch: true,
  //       backgroundColor: AppThemeColors.white.withValues(alpha: 0.1),
  //       elevation: 0,
  //       flexibleSpace: FlexibleSpaceBar(
  //         // stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
  //         background: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [
  //                     AppThemeColors.primaryOrange,
  //                     AppThemeColors.primaryOrange.withValues(alpha: 0.5),
  //                     AppThemeColors.primaryOrange.withValues(alpha: 0.3),
  //                     AppThemeColors.white.withValues(alpha: 0.1),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Opacity(opacity: 0.15, child: Image.asset(Graphics.instance.profileBackground, fit: BoxFit.cover)),
  //             Padding(
  //               padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     name,
  //                     textAlign: TextAlign.center,
  //                     style: AppTextStyle.bold.copyWith(color: AppThemeColors.blackText, fontSize: 32, letterSpacing: -1.0),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                     decoration: BoxDecoration(
  //                       color: AppThemeColors.white.withValues(alpha: 0.2),
  //                       borderRadius: BorderRadius.circular(30),
  //                       border: Border.all(color: AppThemeColors.primaryOrange),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(Icons.alternate_email_rounded, color: AppThemeColors.primaryOrange.withValues(alpha: 0.9), size: 14),
  //                         const SizedBox(width: 8),
  //                         Text(email, style: AppTextStyle.medium.copyWith(color: AppThemeColors.primaryOrange.withValues(alpha: 0.9), fontSize: 14)),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         Container(
  //           margin: const EdgeInsets.only(right: 12),
  //           child: IconButton(
  //             icon: Icon(Icons.edit_note_rounded, color: AppThemeColors.white, size: 28),
  //             onPressed: controller.navigateToEditProfile,
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }
  Widget _buildSliverAppBar(SettingsCtrl controller) {
    return Obx(() {
      final userData = controller.authService.userAuthData;
      final name = userData['name'] ?? "User Name";
      final email = userData['email'] ?? "user@example.com";

      return SliverAppBar(
        expandedHeight: 240,
        pinned: true,
        stretch: true,
        elevation: 0,
        backgroundColor: AppThemeColors.primaryOrange,
        automaticallyImplyLeading: false,
        actionsPadding: EdgeInsets.only(bottom: 5),
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.85), const Color(0xFFFFD6B8)],
                  ),
                ),
              ),

              // Background Image
              Opacity(opacity: 0.12, child: Image.asset(Graphics.instance.profileBackground, fit: BoxFit.cover)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 3),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: AppTextStyle.bold.copyWith(fontSize: 36, color: AppThemeColors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 28),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.alternate_email_rounded, color: AppThemeColors.white, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.medium.copyWith(color: AppThemeColors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppThemeColors.white.withValues(alpha: 0.3),
                border: Border.all(color: AppThemeColors.white.withValues(alpha: 0.7)),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppThemeColors.white, size: 20),
                onPressed: controller.navigateToEditProfile,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: AppTextStyle.bold.copyWith(fontSize: 11, color: AppThemeColors.greyText, letterSpacing: 1.5)),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(28), boxShadow: AppThemeStyles.shadowLight),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool showChevron = true,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: (iconColor ?? AppThemeColors.primaryOrange).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: iconColor ?? AppThemeColors.primaryOrange, size: 22),
      ),
      title: Text(title, style: AppTextStyle.semiBold.copyWith(fontSize: 16, color: textColor ?? AppThemeColors.blackText)),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle, style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.greyText)),
            )
          : null,
      trailing: trailing ?? (showChevron ? Icon(Icons.chevron_right_rounded, size: 24, color: AppThemeColors.greyText.withValues(alpha: 0.5)) : null),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppThemeColors.borderLight, indent: 76, endIndent: 24);
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppThemeStyles.shadowLight),
            child: Text("OnTrip v1.0.0", style: AppTextStyle.bold.copyWith(color: AppThemeColors.greyText, fontSize: 12)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
