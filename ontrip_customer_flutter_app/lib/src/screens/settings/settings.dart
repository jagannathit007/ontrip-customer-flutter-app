import '../../../../app_export.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsCtrl>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        // physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(controller),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 24),
                  // _buildQuickStats(controller),
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
                          activeColor: Constant.instance.primary,
                          inactiveThumbColor: Constant.instance.white,
                          inactiveTrackColor: Constant.instance.grey400,
                        ),
                      ),
                    ),
                    // _buildDivider(),
                    // _buildMenuItem(
                    //   icon: Icons.lock_outline_rounded,
                    //   title: "Privacy & Security",
                    //   subtitle: "Biometrics & permissions",
                    //   onTap: () {},
                    // ),
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
                  _buildSectionHeader("DANGER ZONE"),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: "Sign Out",
                      onTap: controller.logout,
                      iconColor: Colors.red.shade400,
                      textColor: Colors.red.shade600,
                      showChevron: false,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.no_accounts_outlined,
                      title: "Delete My Account",
                      onTap: controller.deleteAccount,
                      iconColor: Colors.red.shade700,
                      textColor: Colors.red.shade900,
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

  Widget _buildSliverAppBar(SettingsCtrl controller) {
    return Obx(() {
      final userData = controller.authService.userAuthData;
      final name = userData['name'] ?? "User Name";
      final email = userData['email'] ?? "user@example.com";

      return SliverAppBar(
        expandedHeight: 200,
        pinned: true,
        stretch: true,
        backgroundColor: Constant.instance.primary,
        elevation: 0,
        // leading: const CustomBackBtn(
        //   iconColor: Colors.white,
        //   bgColor: Colors.transparent,
        // ),
        flexibleSpace: FlexibleSpaceBar(
          stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
          background: Stack(
            fit: StackFit.expand,
            children: [
              // Sophisticated Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Constant.instance.primary, const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
                  ),
                ),
              ),
              // Subtle Pattern
              Opacity(opacity: 0.1, child: Image.asset(Graphics.instance.profileBackground, fit: BoxFit.cover)),
              // Profile Identity Section (No Avatar)
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 32, letterSpacing: -1.0),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.alternate_email_rounded, color: Colors.white.withValues(alpha: 0.6), size: 14),
                          const SizedBox(width: 8),
                          Text(email, style: AppTextStyle.medium.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
              onPressed: controller.navigateToEditProfile,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: AppTextStyle.bold.copyWith(fontSize: 11, color: const Color(0xFF64748B), letterSpacing: 1.5)),
    );
  }

  Widget _buildQuickStats(SettingsCtrl controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Rides", "24", Icons.local_taxi_rounded),
          _buildVerticalDivider(),
          _buildStatItem("Wallet", "₹450", Icons.wallet_rounded),
          _buildVerticalDivider(),
          _buildStatItem("Points", "850", Icons.auto_awesome_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Constant.instance.primary, size: 26),
        const SizedBox(height: 12),
        Text(value, style: AppTextStyle.bold.copyWith(fontSize: 20, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyle.medium.copyWith(color: const Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFF1F5F9));
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))],
      ),
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
        decoration: BoxDecoration(color: (iconColor ?? Constant.instance.primary).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: iconColor ?? Constant.instance.primary, size: 22),
      ),
      title: Text(title, style: AppTextStyle.semiBold.copyWith(fontSize: 16, color: textColor ?? const Color(0xFF334155))),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle, style: AppTextStyle.medium.copyWith(fontSize: 13, color: const Color(0xFF94A3B8))),
            )
          : null,
      trailing: trailing ?? (showChevron ? const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFFCBD5E1)) : null),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFF8FAFC), indent: 76, endIndent: 24);
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
            child: Text("OnTrip v1.0.0", style: AppTextStyle.bold.copyWith(color: const Color(0xFF64748B), fontSize: 12)),
          ),
          const SizedBox(height: 24),
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     _buildSocialIcon(Icons.language_rounded),
          //     const SizedBox(width: 24),
          //     _buildSocialIcon(Icons.camera_alt_outlined),
          //     const SizedBox(width: 24),
          //     _buildSocialIcon(Icons.alternate_email_rounded),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(icon, color: const Color(0xFFCBD5E1), size: 22);
  }
}

Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(title, style: AppTextStyle.bold.copyWith(fontSize: 11, color: const Color(0xFF64748B), letterSpacing: 1.5)),
  );
}

Widget _buildQuickStats(SettingsCtrl controller) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Rides", "24", Icons.local_taxi_rounded),
        _buildVerticalDivider(),
        _buildStatItem("Wallet", "₹450", Icons.wallet_rounded),
        _buildVerticalDivider(),
        _buildStatItem("Points", "850", Icons.auto_awesome_rounded),
      ],
    ),
  );
}

Widget _buildStatItem(String label, String value, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: Constant.instance.primary, size: 26),
      const SizedBox(height: 12),
      Text(value, style: AppTextStyle.bold.copyWith(fontSize: 20, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyle.medium.copyWith(color: const Color(0xFF94A3B8), fontSize: 12)),
    ],
  );
}

Widget _buildVerticalDivider() {
  return Container(height: 40, width: 1, color: const Color(0xFFF1F5F9));
}

Widget _buildMenuCard(List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))],
    ),
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
      decoration: BoxDecoration(color: (iconColor ?? Constant.instance.primary).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: iconColor ?? Constant.instance.primary, size: 22),
    ),
    title: Text(title, style: AppTextStyle.semiBold.copyWith(fontSize: 16, color: textColor ?? const Color(0xFF334155))),
    subtitle: subtitle != null
        ? Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle, style: AppTextStyle.medium.copyWith(fontSize: 13, color: const Color(0xFF94A3B8))),
          )
        : null,
    trailing: trailing ?? (showChevron ? const Icon(Icons.chevron_right_rounded, size: 24, color: Color(0xFFCBD5E1)) : null),
  );
}

Widget _buildDivider() {
  return const Divider(height: 1, color: Color(0xFFF8FAFC), indent: 76, endIndent: 24);
}

Widget _buildFooter() {
  return Center(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
          child: Text("OnTrip v1.0.0 (Gold Member)", style: AppTextStyle.bold.copyWith(color: const Color(0xFF64748B), fontSize: 12)),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSocialIcon(Icons.language_rounded),
            const SizedBox(width: 24),
            _buildSocialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 24),
            _buildSocialIcon(Icons.alternate_email_rounded),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSocialIcon(IconData icon) {
  return Icon(icon, color: const Color(0xFFCBD5E1), size: 22);
}
