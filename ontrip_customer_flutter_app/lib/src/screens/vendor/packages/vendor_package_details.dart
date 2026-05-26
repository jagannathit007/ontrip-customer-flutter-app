import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';

import '../../../../app_export.dart';
import '../home/vendor_home_ctrl.dart';

class VendorPackageDetailsScreen extends GetView<VendorPackageDetailsCtrl> {
  const VendorPackageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppThemeColors.white,
        elevation: 0,
        surfaceTintColor: AppThemeColors.white,
        shadowColor: AppThemeColors.shadowLight.withValues(alpha: 0.1),
        scrolledUnderElevation: 8,
        title: Text("Package Details", style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.blackText)),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new, color: AppThemeColors.greyText, size: 16),
          ),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppThemeColors.bgCream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemeColors.borderLight),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: AppThemeColors.greyText,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyle.semiBold.copyWith(fontSize: 14),
                  unselectedLabelStyle: AppTextStyle.medium.copyWith(fontSize: 14),
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Customers'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernHeader(controller.package),
                          _buildItinerarySection(controller.package),
                          _buildInclusions(controller.package),
                          _buildExclusions(controller.package),
                          _buildSupportCard(controller.package),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    _buildCustomersTab(controller.package),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppThemeColors.borderMedium),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyle.medium.copyWith(fontSize: 14, color: AppThemeColors.greyText)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(VendorPackage package) {
    final coverImage = package.coverImage;

    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppThemeStyles.radiusXLarge), boxShadow: AppThemeStyles.shadowMedium),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppThemeStyles.radiusXLarge),
              child: CustomNetworkImage(imageUrl: coverImage.startsWith("http") ? coverImage : "${AppNetworkConstants.baseURL}$coverImage", fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppThemeStyles.radiusXLarge),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_getStatusColor(package.status.toUpperCase()), _getStatusColor(package.status.toUpperCase()).withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: _getStatusColor(package.status.toUpperCase()).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(package.status.toUpperCase(), style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 12, letterSpacing: 0.5)),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: AppTextStyle.bold.copyWith(
                    color: AppThemeColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppThemeColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, color: AppThemeColors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(package.destination, style: AppTextStyle.medium.copyWith(color: AppThemeColors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'active':
        return AppThemeColors.success;
      case 'pending':
        return AppThemeColors.warning;
      case 'rejected':
      case 'cancelled':
        return AppThemeColors.error;
      default:
        return AppThemeColors.greyText;
    }
  }

  Widget _buildInclusions(VendorPackage package) {
    final inclusions = package.inclusions ?? [];
    if (inclusions.isEmpty) return _buildEmptyState(Icons.check_circle_rounded, "No inclusions listed for this package");

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeColors.white,
        borderRadius: BorderRadius.circular(AppThemeStyles.radiusLarge),
        boxShadow: AppThemeStyles.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.check_circle_rounded, color: AppThemeColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Text("PACKAGE INCLUSIONS", style: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.success, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          ...inclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemeColors.success.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppThemeColors.success, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusions(VendorPackage package) {
    final exclusions = package.exclusions ?? [];
    if (exclusions.isEmpty) return _buildEmptyState(Icons.cancel_rounded, "No exclusions listed for this package");

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeColors.white,
        borderRadius: BorderRadius.circular(AppThemeStyles.radiusLarge),
        boxShadow: AppThemeStyles.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.cancel_rounded, color: AppThemeColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text("PACKAGE EXCLUSIONS", style: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.error, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          ...exclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemeColors.error.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: AppThemeColors.error, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.toString(), style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(VendorPackage package) {
    // Placeholder support details
    const supportName = "Vendor Support";
    const supportPhone = "+91 1234567890";
    const supportEmail = "support@vendor.com";
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppThemeColors.white,
        borderRadius: BorderRadius.circular(AppThemeStyles.radiusLarge),
        boxShadow: AppThemeStyles.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.headset_mic_rounded, color: AppThemeColors.primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text("SUPPORT & ASSISTANCE", style: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.primaryOrange, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Center(
                  child: Text(supportName[0], style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supportName, style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                    const SizedBox(height: 4),
                    Text("Contact your vendor support", style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.greyText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppThemeColors.borderLight, height: 1),
          const SizedBox(height: 20),
          // Phone Row
          GestureDetector(
            onTap: () => AppUrl.call("tel:$supportPhone", mobile: supportPhone),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemeColors.success.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(color: AppThemeColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.call_rounded, color: AppThemeColors.success, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(supportPhone, style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText)),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppThemeColors.success, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Email Row
          GestureDetector(
            onTap: () => AppUrl.mail(email: supportEmail, subject: "Vendor Support"),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeColors.primaryOrange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.mail_rounded, color: AppThemeColors.primaryOrange, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(supportEmail, style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText)),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppThemeColors.primaryOrange, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerarySection(VendorPackage package) {
    final itinerary = package.itinerary ?? [];
    if (itinerary.isEmpty) return _buildEmptyState(Icons.map_outlined, "No itinerary available for this trip");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.route, color: AppThemeColors.primaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text("TRIP ITINERARY", style: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.primaryOrange, letterSpacing: 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Day Selector
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itinerary.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final isSelected = controller.selectedDay.value == index;
                return GestureDetector(
                  onTap: () => controller.onDayChange(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                            )
                          : null,
                      color: isSelected ? null : AppThemeColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? AppThemeColors.primaryOrange.withValues(alpha: 0.3) : AppThemeColors.shadowDark,
                          blurRadius: isSelected ? 8 : 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "DAY",
                          style: AppTextStyle.bold.copyWith(
                            fontSize: 10,
                            color: isSelected ? AppThemeColors.white.withValues(alpha: 0.8) : AppThemeColors.greyText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${index + 1}",
                          style: AppTextStyle.bold.copyWith(fontSize: 18, color: isSelected ? AppThemeColors.white : AppThemeColors.blackText),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        // Day Content
        Obx(() {
          final dayData = itinerary[controller.selectedDay.value];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppThemeStyles.shadowMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dayData.title ?? "Day ${dayData.day}",
                              style: AppTextStyle.bold.copyWith(fontSize: 24, color: AppThemeColors.blackText),
                            ),
                          ),
                          if (dayData.date != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppThemeColors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "${dayData.date!.day}/${dayData.date!.month}/${dayData.date!.year}",
                                style: AppTextStyle.semiBold.copyWith(fontSize: 12, color: AppThemeColors.info),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(dayData.description ?? "", style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.greyText, height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...(dayData.experiences ?? []).map((exp) => _buildExperienceCard(exp)),
              ],
            ),
          );
        }),
        const SizedBox(height: 16), // Section spacing
      ],
    );
  }

  Widget _buildExperienceCard(Experience exp) {
    final image = exp.images?.isNotEmpty == true ? exp.images![0] : "";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppThemeStyles.shadowMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  CustomNetworkImage(imageUrl: image.startsWith("http") ? image : "${AppNetworkConstants.baseURL}$image", height: 180, width: double.infinity),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Text(
                        exp.category?.toUpperCase() ?? "ACTIVITY",
                        style: AppTextStyle.bold.copyWith(fontSize: 10, color: AppThemeColors.white, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(exp.name ?? "Experience", style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.blackText, height: 1.2)),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppThemeColors.info.withValues(alpha: 0.1), AppThemeColors.info.withValues(alpha: 0.05)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppThemeColors.info.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 16, color: AppThemeColors.info),
                          const SizedBox(width: 6),
                          Text(
                            "${exp.startTime}${exp.endTime != null && exp.endTime!.isNotEmpty ? ' — ${exp.endTime}' : ''}",
                            style: AppTextStyle.bold.copyWith(color: AppThemeColors.info, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(exp.description!.trim(), style: AppTextStyle.bold.copyWith(color: AppThemeColors.greyText, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTab(VendorPackage package) {
    final bookings = package.bookings ?? [];
    if (bookings.isEmpty) {
      return _buildEmptyState(Icons.group, "No customers have booked this package yet");
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final customer = booking.customer;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppThemeStyles.shadowMedium),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppThemeColors.greyText.withValues(alpha: 0.3),
                child: Text(style: TextStyle(color: AppThemeColors.blackText, fontSize: 18), customer?.name?.isNotEmpty == true ? customer!.name![0] : "?"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer?.name ?? "Unknown", style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        final phone = customer?.phone;
                        if (phone != null && phone.isNotEmpty) {
                          AppUrl.call("tel:$phone", mobile: phone);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.call_rounded, color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              customer?.phone ?? "",
                              style: AppTextStyle.medium.copyWith(fontSize: 14, color: AppThemeColors.greyText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Text(booking.bookingStatus ?? "", style: AppTextStyle.medium.copyWith(color: AppThemeColors.greyText)),
            ],
          ),
        );
      },
    );
  }
}
