import '../../../../../app_export.dart';
import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';

class GroupMembersScreen extends StatelessWidget {
  const GroupMembersScreen({super.key});

  static final Color _bgCream = AppThemeColors.bgCream;
  static const Color _teal = Color(0xFF0E736A);
  static const Color _lightTeal = Color(0xFFE1F2EF);
  static final Color _orangeText = AppThemeColors.primaryOrange;
  static final Color _orangeBg = AppThemeColors.primaryOrange.withValues(alpha: 0.1);
  static const Color _purpleText = Color(0xFF7E4CCB);
  static const Color _purpleBg = Color(0xFFF0E7FA);
  static const Color _travelerText = Color(0xFFA6927C);
  static const Color _travelerBg = Color(0xFFF4EDE3);
  static final Color _greyText = AppThemeColors.greyText;
  // static const Color _borderColor = Color(0xFFE5E7EB);
  static final Color _borderColor = AppThemeColors.borderLight; // show border lines
  static final Color kBgColor = AppThemeColors.bgCream;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupMembersCtrl>(
      init: GroupMembersCtrl(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: _bgCream,
          // backgroundColor: const Color.fromARGB(255, 187, 132, 49),
          // backgroundColor: Color(0xFFFDF7F0),
          backgroundColor: kBgColor,
          appBar: _buildAppBar(controller),
          body: SafeArea(
            bottom: true,

            child: Column(
              children: [
                _buildSearchBar(controller),
                _buildInfoBanner(),
                Expanded(
                  child: Obx(() {
                    // ignore: unused_local_variable
                    final _ = controller.searchQuery.value;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                      children: [
                        _buildAgentsSection(controller),
                        const SizedBox(height: 24),
                        _buildVendorsSection(controller),
                        const SizedBox(height: 24),
                        _buildTravelersSection(controller),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(GroupMembersCtrl controller) {
    return AppBar(
      // backgroundColor: _bgCream,
      // backgroundColor: const Color.fromARGB(255, 180, 154, 49),
      //  backgroundColor: Color(0xFFFDF7F0),
      backgroundColor: kBgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 72,
      leading: Center(
        child: InkWell(
          onTap: () => Get.back(),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppThemeColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemeColors.borderLight),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppThemeColors.blackText),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Group Members", style: AppTextStyle.bold.copyWith(fontSize: 18, color: AppThemeColors.blackText)),
          Obx(() {
            final totalMembers = controller.filteredAgents.length + controller.filteredVendors.length + controller.filteredCustomers.length;
            return Text("$totalMembers people on this journey", style: AppTextStyle.medium.copyWith(fontSize: 12, color: _greyText));
          }),
        ],
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 16),
      //     child: Container(
      //       height: 40,
      //       width: 40,
      //       decoration: BoxDecoration(
      //         color: _teal,
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //       child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _buildSearchBar(GroupMembersCtrl controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppThemeStyles.cardDecoration(
        color: AppThemeColors.white,
        radius: AppThemeStyles.radiusMedium,
        shadows: AppThemeStyles.shadowLight,
      ).copyWith(border: Border.all(color: AppThemeColors.borderLight)),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.searchQuery.value = value,
        style: AppTextStyle.medium.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: "Search members...",
          hintStyle: AppTextStyle.regular.copyWith(color: AppThemeColors.greyText, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: AppThemeColors.greyText, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _orangeBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(color: _orangeText, shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your agents manage who can send messages in this group.",
              style: TextStyle(fontSize: 13, color: _orangeText, fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsSection(GroupMembersCtrl controller) {
    if (controller.filteredAgents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Agents", controller.filteredAgents.length),
        const SizedBox(height: 12),
        Container(
          decoration: AppThemeStyles.cardDecoration(
            color: AppThemeColors.white,
            radius: AppThemeStyles.radiusXLarge,
            shadows: AppThemeStyles.shadowLight,
          ).copyWith(border: Border.all(color: AppThemeColors.borderLight)),
          child: Column(
            children: List.generate(controller.filteredAgents.length, (index) {
              final agent = controller.filteredAgents[index];
              return Column(
                children: [
                  _buildAgentTile(agent),
                  if (index != controller.filteredAgents.length - 1) Divider(height: 1, color: _borderColor.withValues(alpha: 0.3), indent: 70),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorsSection(GroupMembersCtrl controller) {
    if (controller.filteredVendors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Vendors", controller.filteredVendors.length),
        const SizedBox(height: 12),
        Container(
          decoration: AppThemeStyles.cardDecoration(
            color: AppThemeColors.white,
            radius: AppThemeStyles.radiusXLarge,
            shadows: AppThemeStyles.shadowLight,
          ).copyWith(border: Border.all(color: AppThemeColors.borderLight)),
          child: Column(
            children: List.generate(controller.filteredVendors.length, (index) {
              final vendor = controller.filteredVendors[index];
              return Column(
                children: [
                  _buildVendorTile(vendor),
                  if (index != controller.filteredVendors.length - 1) Divider(height: 1, color: _borderColor.withValues(alpha: 0.3), indent: 70),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelersSection(GroupMembersCtrl controller) {
    if (controller.filteredCustomers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Travelers", controller.filteredCustomers.length),
        const SizedBox(height: 12),
        Container(
          decoration: AppThemeStyles.cardDecoration(
            color: AppThemeColors.white,
            radius: AppThemeStyles.radiusXLarge,
            shadows: AppThemeStyles.shadowLight,
          ).copyWith(border: Border.all(color: AppThemeColors.borderLight)),
          child: Column(
            children: List.generate(controller.filteredCustomers.length, (index) {
              final member = controller.filteredCustomers[index];
              return Column(
                children: [
                  _buildTravelerTile(member),
                  if (index != controller.filteredCustomers.length - 1) Divider(height: 1, color: _borderColor.withValues(alpha: 0.3), indent: 70),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.blackText)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(color: _orangeBg, borderRadius: BorderRadius.circular(10)),
          child: Text("$count", style: AppTextStyle.bold.copyWith(fontSize: 14, color: _orangeText)),
        ),
      ],
    );
  }

  Widget _buildAgentTile(AgentMember agent) {
    final roleInfo = _getRoleInfo(agent.role);
    final avatarColor = _getAvatarColor(agent.name);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(agent.name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name ?? "Unknown", style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                Text(agent.email ?? "", maxLines: 1, style: AppTextStyle.medium.copyWith(fontSize: 13, color: _greyText)),
              ],
            ),
          ),
          _buildRoleLabel(roleInfo['label'] as String, roleInfo['bg'] as Color, roleInfo['text'] as Color),
        ],
      ),
    );
  }

  Widget _buildVendorTile(VendorMember vendor) {
    final typeInfo = _getVendorTypeInfo(vendor.type);
    final subtitle = vendor.email?.isNotEmpty == true ? vendor.email! : (vendor.phone ?? "");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(vendor.name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendor.name ?? "Unknown", style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                Text(subtitle, maxLines: 1, style: AppTextStyle.medium.copyWith(fontSize: 13, color: _greyText)),
                if (vendor.contactPerson?.isNotEmpty == true)
                  Text(vendor.contactPerson!, style: AppTextStyle.medium.copyWith(fontSize: 12, color: _greyText.withValues(alpha: 0.8))),
              ],
            ),
          ),
          _buildRoleLabel(typeInfo['label'] as String, typeInfo['bg'] as Color, typeInfo['text'] as Color),
        ],
      ),
    );
  }

  Widget _buildTravelerTile(CustomerMember member) {
    final avatarColor = _getAvatarColor(member.name);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(member.name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name ?? "Unknown", style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                Text(member.email ?? "", style: AppTextStyle.medium.copyWith(fontSize: 13, color: _greyText)),
              ],
            ),
          ),
          _buildRoleLabel("Traveler", _travelerBg, _travelerText),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? name) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : "?";
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(color: _orangeText.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Center(
        child: Text(initial, style: AppTextStyle.bold.copyWith(fontSize: 18, color: _orangeText)),
      ),
    );
  }

  Widget _buildRoleLabel(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyle.bold.copyWith(fontSize: 11, color: text)),
    );
  }

  Map<String, dynamic> _getVendorTypeInfo(String? type) {
    switch (type) {
      case 'hotel':
        return {'label': 'Hotel', 'bg': _lightTeal, 'text': _teal};
      case 'activity_provider':
        return {'label': 'Activity', 'bg': _purpleBg, 'text': _purpleText};
      case 'transport':
        return {'label': 'Transport', 'bg': _orangeBg, 'text': _orangeText};
      default:
        return {'label': 'Vendor', 'bg': _lightTeal, 'text': _teal};
    }
  }

  Map<String, dynamic> _getRoleInfo(String? role) {
    switch (role) {
      case 'parent_agent':
        return {'label': 'Parent Agent', 'bg': _orangeBg, 'text': _orangeText};
      case 'child_agent':
      case 'sub_child_agent':
        return {'label': 'Child Agent', 'bg': _lightTeal, 'text': _teal};
      case 'admin':
        return {'label': 'Admin', 'bg': _purpleBg, 'text': _purpleText};
      default:
        return {'label': 'Member', 'bg': Colors.grey.shade100, 'text': Colors.grey.shade600};
    }
  }

  Color _getAvatarColor(String? name) {
    if (name == null || name.isEmpty) return Colors.grey;
    final colors = [
      _orangeText,
      _teal,
      _purpleText,
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
