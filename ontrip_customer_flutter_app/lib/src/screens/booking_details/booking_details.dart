import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../../../../app_export.dart';

class BookingDetailsScreen extends GetView<BookingDetailsCtrl> {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      appBar: AppBar(
        backgroundColor: AppThemeColors.white,
        elevation: 0,
        surfaceTintColor: AppThemeColors.white,
        shadowColor: AppThemeColors.shadowLight,
        scrolledUnderElevation: 8,
        title: Text("Trip Details", style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.blackText)),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new, color: AppThemeColors.greyText, size: 16),
            ),
          ),
        ),
        actions: [
          Container(
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppThemeColors.primaryOrange.withValues(alpha: 0.1), AppThemeColors.primaryOrange.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(Icons.chat_bubble_rounded, color: AppThemeColors.primaryOrange, size: 20),
              ),
              onPressed: () {
                final packageId = controller.booking.value?.package?.id;
                final coverImage = controller.booking.value?.package?.coverImage;
                if (packageId != null) {
                  Get.toNamed(RouteNames.communityChat, arguments: {"packageId": packageId, "coverImage": coverImage});
                } else {
                  warningToast("Community not available for this trip");
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoadingIndicator());
        }

        final booking = controller.booking.value;
        if (booking == null) {
          return _buildEmptyBookingState();
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(booking),
                _buildItinerarySection(booking),
                _buildInclusions(booking),
                _buildExclusions(booking),
                _buildSupportCard(booking),
                _buildReviewSection(booking, controller),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyBookingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded, size: 64, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            Text("No Details Found", style: AppTextStyle.bold.copyWith(fontSize: 24, color: AppThemeColors.blackText)),
            const SizedBox(height: 12),
            Text(
              "Unable to load booking details at this time.",
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.greyText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method inside BookingDetailsScreen:

  Widget _buildActionBtn(IconData icon, Color iconColor, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppThemeStyles.shadowMedium),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildModernHeader(Booking booking) {
    final package = booking.package;
    final coverImage = package?.coverImage ?? "";

    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppThemeStyles.radiusXLarge), boxShadow: AppThemeStyles.shadowLarge),
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
                  colors: [Colors.transparent, AppThemeColors.blackText.withValues(alpha: 0.7)],
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
                  colors: [
                    _getStatusColor(booking.bookingStatus?.toUpperCase() ?? "BOOKED"),
                    _getStatusColor(booking.bookingStatus?.toUpperCase() ?? "BOOKED").withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(booking.bookingStatus?.toUpperCase() ?? "BOOKED").withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                booking.bookingStatus?.toUpperCase() ?? "BOOKED",
                style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 12, letterSpacing: 0.5),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppThemeColors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppThemeStyles.shadowMedium,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.confirmation_number_rounded, size: 16, color: AppThemeColors.primaryOrange),
                  const SizedBox(width: 6),
                  Text(booking.bookingId ?? "N/A", style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 12)),
                ],
              ),
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
                  booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details",
                  style: AppTextStyle.bold.copyWith(
                    color: AppThemeColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: AppThemeColors.blackText.withValues(alpha: 0.5), blurRadius: 8)],
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
                          Text(package?.destination ?? "Unknown Location", style: AppTextStyle.medium.copyWith(color: AppThemeColors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (booking.travelDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppThemeColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, color: AppThemeColors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              AppDateFormat.monthDayYear(booking.travelDate!),
                              style: AppTextStyle.medium.copyWith(color: AppThemeColors.white, fontSize: 14),
                            ),
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
      case 'confirmed':
      case 'booked':
        return AppThemeColors.success;
      case 'pending':
        return AppThemeColors.warning;
      case 'cancelled':
        return AppThemeColors.error;
      case 'completed':
        return AppThemeColors.info;
      default:
        return AppThemeColors.greyText;
    }
  }

  Widget _buildHeader(Booking booking) {
    final package = booking.package;
    final coverImage = package?.coverImage ?? "";

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        child: Stack(
          children: [
            Positioned.fill(child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$coverImage")),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Constant.instance.primary, borderRadius: BorderRadius.circular(6)),
                    child: Text(booking.bookingStatus?.toUpperCase() ?? "BOOKED", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 10)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details",
                    style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text(package?.destination ?? "Exploring", style: AppTextStyle.medium.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
            Icon(icon, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(Booking booking) {
    final agencyCustomer = booking.agencyCustomer;
    final agencyName = agencyCustomer?.name ?? "Support Team";
    final agencyEmail = agencyCustomer?.email;
    final agencyPhone = agencyCustomer?.phone;
    final hasPhone = agencyPhone != null && agencyPhone.isNotEmpty;
    final hasEmail = agencyEmail != null && agencyEmail.isNotEmpty;
    if (agencyCustomer == null) return _buildEmptyState(Icons.headset_mic_rounded, "No support contact available");

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
                  child: Text(agencyName.isNotEmpty ? agencyName[0].toUpperCase() : "S", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agencyName, style: AppTextStyle.bold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text("Your Travel Agent", style: AppTextStyle.medium.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 20),
          // Phone Row
          if (hasPhone)
            GestureDetector(
              onTap: () => AppUrl.call("tel:$agencyPhone", mobile: agencyPhone),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Constant.instance.green2.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Constant.instance.green2.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(color: Constant.instance.green2.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.call_rounded, color: Constant.instance.green2, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(agencyPhone, style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Constant.instance.green2, size: 16),
                  ],
                ),
              ),
            ),
          if (hasPhone && hasEmail) const SizedBox(height: 12),
          // Email Row
          if (hasEmail)
            GestureDetector(
              onTap: () => AppUrl.mail(email: agencyEmail, subject: "Trip Enquiry"),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Constant.instance.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Constant.instance.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.mail_rounded, color: Constant.instance.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(agencyEmail, style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Constant.instance.primary, size: 16),
                  ],
                ),
              ),
            ),
          if (!hasPhone && !hasEmail)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: const Color(0xFF64748B), size: 20),
                  const SizedBox(width: 12),
                  Text("Contact details not available", style: AppTextStyle.medium.copyWith(fontSize: 14, color: const Color(0xFF64748B))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInclusions(Booking booking) {
    final inclusions = booking.package?.inclusions ?? [];
    if (inclusions.isEmpty) return _buildEmptyState(Icons.check_circle_rounded, "No inclusions listed for this package");

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Constant.instance.green2.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.check_circle_rounded, color: Constant.instance.green2, size: 20),
              ),
              const SizedBox(width: 12),
              Text("PACKAGE INCLUSIONS", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Constant.instance.green2, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          ...inclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Constant.instance.green2.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Constant.instance.green2.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Constant.instance.green2, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF1E293B), height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusions(Booking booking) {
    final exclusions = booking.package?.exclusions ?? [];
    if (exclusions.isEmpty) return _buildEmptyState(Icons.cancel_rounded, "No exclusions listed for this package");

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Constant.instance.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.cancel_rounded, color: Constant.instance.red, size: 20),
              ),
              const SizedBox(width: 12),
              Text("PACKAGE EXCLUSIONS", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Constant.instance.red, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          ...exclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Constant.instance.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Constant.instance.red.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: Constant.instance.red, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.toString(), style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF1E293B), height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerarySection(Booking booking) {
    final itinerary = booking.package?.itinerary ?? [];
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
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Constant.instance.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 4 : 5,
                          offset: const Offset(2, 2),
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
                            color: isSelected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text("${index + 1}", style: AppTextStyle.bold.copyWith(fontSize: 18, color: isSelected ? Colors.white : const Color(0xFF1E293B))),
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
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayData.title ?? "Day ${dayData.day}",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bold.copyWith(fontSize: 24, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dayData.description ?? "",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF64748B), height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...(dayData.experiences ?? []).map((exp) => _buildExperienceCard(exp)),
              ],
            ),
          );
        }),
        const SizedBox(height: 32), // Section spacing
      ],
    );
  }

  Widget _buildExperienceCard(Experience exp) {
    final image = exp.images?.isNotEmpty == true ? exp.images![0] : "";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
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
                        // boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Text(
                        exp.category?.toUpperCase() ?? "ACTIVITY",
                        style: AppTextStyle.bold.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 0.5),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp.name ?? "Event", style: AppTextStyle.bold.copyWith(fontSize: 20, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    if ((exp.description ?? "").trim().isNotEmpty)
                      CustomReadMoreText(
                        exp.description!.trim(),
                        trimMode: TrimMode.line,
                        trimLines: 2,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        style: AppTextStyle.medium.copyWith(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
                        moreStyle: AppTextStyle.semiBold.copyWith(fontSize: 14, color: Constant.instance.primary),
                        lessStyle: AppTextStyle.semiBold.copyWith(fontSize: 14, color: Constant.instance.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0xFF3B82F6).withValues(alpha: 0.1), const Color(0xFF1D4ED8).withValues(alpha: 0.05)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 16, color: const Color(0xFF3B82F6)),
                              const SizedBox(width: 4),
                              Text(
                                "Time",
                                style: AppTextStyle.bold.copyWith(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF3B82F6)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${exp.startTime}${exp.endTime != null && exp.endTime!.isNotEmpty ? ' — ${exp.endTime}' : ''}",
                            style: AppTextStyle.bold.copyWith(fontSize: 14, color: const Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => controller.callVendor(exp.vendor?.phone),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                          ),
                          shape: BoxShape.circle,
                          // boxShadow: [BoxShadow(color: Constant.instance.green2.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                // Row(
                //   children: [
                //     const SizedBox(width: 16),
                // GestureDetector(
                //   onTap: () => controller.callVendor(exp.vendor?.phone),
                //   child: Container(
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //         colors: [Constant.instance.green2, Constant.instance.green2.withValues(alpha: 0.8)],
                //       ),
                //       shape: BoxShape.circle,
                //       boxShadow: [BoxShadow(color: Constant.instance.green2.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                //     ),
                //     child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                //   ),
                // ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(Booking booking, BookingDetailsCtrl ctrl) {
    return Obx(() {
      final reviews = ctrl.reviewResponse.value?.reviews ?? [];
      final avgPackage = ctrl.reviewResponse.value?.avgPackageRating ?? "0.0";
      final avgOverall = ctrl.reviewResponse.value?.avgOverallRating ?? "0.0";
      final total = ctrl.reviewResponse.value?.total ?? 0;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.star_rounded, color: AppThemeColors.primaryOrange, size: 20),
                ),
                const SizedBox(width: 12),
                Text("YOUR EXPERIENCE", style: AppTextStyle.bold.copyWith(fontSize: 14, color: AppThemeColors.primaryOrange, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 20),
            _buildManageUserReview(ctrl),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.reviews_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Text("GUEST FEEDBACK", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Colors.amber.shade700, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 20),
            if (reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppThemeColors.primaryOrange.withValues(alpha: 0.05), AppThemeColors.primaryOrange.withValues(alpha: 0.02)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    _buildRatingSummaryItem("Package", avgPackage),
                    Container(height: 40, width: 1, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildRatingSummaryItem("Overall", avgOverall),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$total", style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.primaryOrange)),
                        Text("Reviews", style: AppTextStyle.medium.copyWith(fontSize: 12, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ),
            if (reviews.isEmpty) _buildTripEmptyState(Icons.star_outline, "No reviews yet") else ...reviews.map((r) => _buildTripReviewCard(r)),
          ],
        ),
      );
    });
  }

  Widget _buildManageUserReview(BookingDetailsCtrl ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ctrl.userReview.value == null ? "How was your trip?" : "Your Review",
                style: AppTextStyle.bold.copyWith(fontSize: 18, color: const Color(0xFF1E293B)),
              ),
              if (ctrl.userReview.value != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Constant.instance.green2, Constant.instance.green2.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Constant.instance.green2.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Text("SUBMITTED", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 10, letterSpacing: 0.5)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => ctrl.userReview.value == null ? ctrl.userRating.value = index + 1.0 : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star_rounded, size: 36, color: index < ctrl.userRating.value ? Colors.amber : const Color(0xFFE2E8F0)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: ctrl.reviewCommentCtrl,
              maxLines: 3,
              readOnly: ctrl.userReview.value != null,
              decoration: InputDecoration(
                hintText: "Share your experience with others...",
                hintStyle: AppTextStyle.medium.copyWith(fontSize: 14, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),
          if (ctrl.userReview.value == null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: ctrl.isReviewLoading.value ? null : () => ctrl.submitReview(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: AppThemeColors.primaryOrange.withValues(alpha: 0.3),
                ),
                child: ctrl.isReviewLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Submit Review", style: AppTextStyle.bold.copyWith(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummaryItem(String label, String rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(rating, style: AppTextStyle.bold.copyWith(fontSize: 20)),
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildTripReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(review.customerName?[0].toUpperCase() ?? "U", style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName ?? "Guest User", style: AppTextStyle.bold.copyWith(fontSize: 15)),
                    if (review.createdAt != null)
                      Text(AppDateFormat.monthDayYear(review.createdAt!), style: AppTextStyle.medium.copyWith(fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${(review.packageRating ?? review.overallRating ?? 0.0).toInt()}",
                      style: AppTextStyle.bold.copyWith(fontSize: 13, color: Colors.amber.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)),
              child: Text(review.comment!, style: AppTextStyle.medium.copyWith(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripEmptyState(IconData icon, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 16, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    review.customerName?.isNotEmpty == true ? review.customerName![0].toUpperCase() : "U",
                    style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName ?? "User", style: AppTextStyle.bold.copyWith(fontSize: 14, color: const Color(0xFF1E293B))),
                    Text(
                      AppDateFormat.notification3(review.createdAt ?? DateTime.now()),
                      // style: AppDateFormat.notification3(review.createdAt ?? DateTime.now()),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(index < (review.overallRating ?? 0) ? Icons.star : Icons.star_border, color: Colors.amber, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment ?? "", style: AppTextStyle.medium.copyWith(fontSize: 14, color: const Color(0xFF475569), height: 1.5)),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    controller.userRating.value = 0;
    controller.reviewCommentCtrl.clear();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Write a review", style: AppTextStyle.bold.copyWith(fontSize: 20, color: const Color(0xFF1E293B))),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text("How was your experience?", style: AppTextStyle.bold.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 16),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => controller.userRating.value = index + 1.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  index < controller.userRating.value ? Icons.star : Icons.star_border,
                                  color: index < controller.userRating.value ? Colors.amber : Colors.grey.shade300,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text("Comments (optional)", style: AppTextStyle.bold.copyWith(fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: controller.reviewCommentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tell us more about your experience (max 500 words)...",
                      hintStyle: AppTextStyle.medium.copyWith(fontSize: 14, color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text("Cancel", style: AppTextStyle.bold.copyWith(color: const Color(0xFF64748B))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.submitReview(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF312E81),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text("Submit", style: AppTextStyle.bold.copyWith(fontSize: 15, color: Constant.instance.white)),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () => controller.submitReview(),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFF312E81),
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(vertical: 16),
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    //       elevation: 0,
                    //     ),
                    //     child: Text("Submit", style: AppTextStyle.bold.copyWith(fontSize: 15)),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
