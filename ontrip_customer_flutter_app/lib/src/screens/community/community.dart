import '../../../../../app_export.dart';
import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import 'community_ctrl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // Always re-fetch when screen mounts to ensure correct role-based endpoint is used
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CommunityCtrl>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityCtrl>();
    final isVendor = getStorage(AppSession.userRole) == 'vendor';

    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      body: SafeArea(
        bottom: false,
        top: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (!isVendor) _buildStatsSection(controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  if (isVendor) {
                    if (controller.vendorGroups.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      onRefresh: controller.fetchBookings,
                      color: AppThemeColors.primaryOrange,
                      backgroundColor: AppThemeColors.white,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: controller.vendorGroups.length,
                        itemBuilder: (context, index) => _buildVendorGroup(controller.vendorGroups[index], controller),
                      ),
                    );
                  }

                  if (controller.bookings.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: controller.fetchBookings,
                    color: AppThemeColors.primaryOrange,
                    backgroundColor: AppThemeColors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: controller.bookings.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          child: _buildBookingTile(controller.bookings[index], controller, index),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vendor grouped card ──────────────────────────────────────────────────

  Widget _buildVendorGroup(VendorPackageGroup group, CommunityCtrl ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppThemeStyles.cardDecoration(color: AppThemeColors.white, radius: AppThemeStyles.radiusLarge, shadows: AppThemeStyles.shadowMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${group.title} — ${group.destination}', style: AppTextStyle.bold.copyWith(fontSize: 15, color: AppThemeColors.blackText)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => Get.toNamed(RouteNames.communityChat, arguments: {"packageId": group.packageId, "coverImage": group.coverImage}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppThemeColors.borderOrange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: AppThemeColors.primaryOrange),
                        const SizedBox(width: 5),
                        Text('Community', style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.primaryOrange)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 1),
          Divider(height: 5, color: AppThemeColors.borderLight),

          // ── Booking rows ──────────────────────────────────────
          ...group.bookings.map((booking) => _buildVendorBookingRow(booking, group, ctrl)),
        ],
      ),
    );
  }

  Widget _buildVendorBookingRow(Booking booking, VendorPackageGroup group, CommunityCtrl ctrl) {
    final travelDate = booking.travelDate != null ? '${booking.travelDate!.day} ${_monthName(booking.travelDate!.month)}' : '';
    final customerName = booking.customer?.name ?? booking.agencyCustomer?.name ?? '';
    final bookingId = booking.bookingId ?? '';
    final day = booking.currentDay ?? 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.blackText)),
                    const SizedBox(width: 8),
                    Text(bookingId, style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.greyText)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => ctrl.navigateToChat(group.packageId, group.coverImage, booking: booking),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemeColors.bgCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppThemeColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppThemeColors.greyText),
                      const SizedBox(width: 4),
                      Text('Chat', style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.greyText)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppThemeColors.borderLight, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppThemeColors.bgCream, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.greyText)),
    );
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppThemeColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.groups_rounded, color: AppThemeColors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Community", style: AppTextStyle.bold.copyWith(fontSize: 27, color: AppThemeColors.white, letterSpacing: -0.8, height: 1.1)),
                      const SizedBox(height: 4),
                      Text(
                        "Connect with fellow travelers and experts",
                        style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.white.withValues(alpha: 0.9), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(Booking booking, CommunityCtrl controller, int index) {
    final package = booking.package;
    final title = booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details";
    final destination = package?.destination ?? "Unknown Location";
    final coverImage = package?.coverImage ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppThemeStyles.cardDecoration(color: AppThemeColors.white, radius: AppThemeStyles.radiusXLarge, shadows: AppThemeStyles.shadowMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToChat(package?.id, coverImage, booking: booking),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'community_image_$index',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$coverImage", height: 64, width: 64, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bold.copyWith(fontSize: 17, color: AppThemeColors.blackText, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: AppThemeColors.primaryOrange.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(destination, style: AppTextStyle.medium.copyWith(fontSize: 14, color: AppThemeColors.greyText)),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12,
                      //     vertical: 6,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Constant.instance.primary.withValues(alpha: 0.1),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     // children: [
                      //     //   Icon(
                      //     //     Icons.chat_bubble_rounded,
                      //     //     size: 14,
                      //     //     color: Constant.instance.primary,
                      //     //   ),
                      //     //   const SizedBox(width: 6),
                      //     //   // Text(
                      //     //   //   "Join Chat",
                      //     //   //   style: AppTextStyle.semiBold.copyWith(
                      //     //   //     fontSize: 12,
                      //     //   //     color: Constant.instance.primary,
                      //     //   //   ),
                      //     //   // ),
                      //     // ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppThemeColors.bgCream, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: AppThemeColors.primaryOrange, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(CommunityCtrl controller) {
    return Obx(() {
      final activeTrips = controller.bookings.length;
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        padding: const EdgeInsets.all(20),
        decoration: AppThemeStyles.cardDecoration(color: AppThemeColors.white, radius: AppThemeStyles.radiusLarge, shadows: AppThemeStyles.shadowLight),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(icon: Icons.groups_rounded, label: "Active Trips", value: activeTrips.toString(), color: AppThemeColors.primaryOrange),
            ),
            Container(width: 1, height: 40, color: AppThemeColors.borderLight),
            Expanded(
              child: _buildStatItem(icon: Icons.chat_bubble_rounded, label: "Conversations", value: activeTrips.toString(), color: AppThemeColors.success),
            ),
            Container(width: 1, height: 40, color: AppThemeColors.borderLight),
            Expanded(
              child: _buildStatItem(icon: Icons.people_rounded, label: "Members", value: "${activeTrips * 8}+", color: AppThemeColors.warning),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyle.bold.copyWith(fontSize: 18, color: AppThemeColors.blackText)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.greyText)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.groups_rounded, size: 64, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            Text("No Active Trips", style: AppTextStyle.bold.copyWith(fontSize: 24, color: AppThemeColors.blackText)),
            const SizedBox(height: 12),
            Text(
              "Start your journey and connect with fellow travelers in our community chats.",
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.greyText, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppThemeColors.primaryOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Text("Explore Trips", style: AppTextStyle.semiBold.copyWith(fontSize: 16, color: AppThemeColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
