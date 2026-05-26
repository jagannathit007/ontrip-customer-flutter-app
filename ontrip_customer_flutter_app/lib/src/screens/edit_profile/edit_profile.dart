import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';

import '../../../../app_export.dart';

class EditProfileScreen extends GetView<EditProfileCtrl> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   title: Text("Edit Profile", style: AppTextStyle.bold.copyWith(fontSize: 20, color: const Color(0xFF1E293B))),
      //   centerTitle: true,
      //   leading: const CustomBackBtn(),
      // ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppThemeColors.primaryOrange,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppThemeColors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppThemeColors.white),
          ),
        ),
        title: Text('Edit Profile', style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.white)),
      ),
      body: Obx(() {
        final userData = controller.authService.userAuthData;
        if (controller.isLoading.value && userData.isEmpty) {
          return const Center(child: CustomLoadingIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildAvatarSection(userData),
              const SizedBox(height: 20),
              _buildFormSection(),
              const SizedBox(height: 30),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAvatarSection(Map<String, dynamic> userData) {
    final name = userData['name'] ?? "";
    final profileUrl = userData['profile_pic'] ?? "";

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: profileUrl.isNotEmpty
                  ? CustomNetworkImage(imageUrl: profileUrl)
                  : Container(
                      color: AppThemeColors.primaryOrange.withValues(alpha: 0.2),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "U",
                          style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 48),
                        ),
                      ),
                    ),
            ),
          ),
          // GestureDetector(
          //   onTap: () {},
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Constant.instance.primary,
          //       shape: BoxShape.circle,
          //       border: Border.all(color: Colors.white, width: 2),
          //     ),
          //     child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.person_outline_rounded, color: AppThemeColors.primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text("Personal Information", style: AppTextStyle.bold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(label: "FULL NAME", controller: controller.nameController, icon: Icons.person_outline_rounded, hint: "Enter your name"),
          const SizedBox(height: 20),
          _buildTextField(
            label: "EMAIL ADDRESS",
            controller: controller.emailController,
            icon: Icons.email_outlined,
            hint: "Enter your email",
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: AppTextStyle.bold.copyWith(fontSize: 11, color: AppThemeColors.greyText, letterSpacing: 1.1)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppThemeColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeColors.greyText.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyle.semiBold.copyWith(fontSize: 15, color: const Color(0xFF334155)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyle.medium.copyWith(fontSize: 15, color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: AppThemeColors.primaryOrange.withValues(alpha: 0.6), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: CustomBtn(
              radius: AppThemeStyles.radiusMedium,
              bgColor: Colors.white,
              borderColor: AppThemeColors.greyText,
              borderWidth: 1,
              style: TextStyle(color: AppThemeColors.greyText, fontWeight: FontWeight.w700),
              height: 50,
              text: "CANCEL",
              onTap: controller.discardChanges,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() {
              return CustomBtn(
                radius: AppThemeStyles.radiusMedium,
                bgColor: AppThemeColors.primaryOrange,
                borderColor: AppThemeColors.primaryOrange,
                height: 50,
                text: "SAVE CHANGES",
                onTap: controller.saveChanges,
                isLoading: controller.isLoading.value,
                prefix: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
              );
            }),
          ),
        ],
      ),
    );
  }
}
