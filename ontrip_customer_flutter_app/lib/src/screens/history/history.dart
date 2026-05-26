import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../../../app_export.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // Initialize HistoryCtrl
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HistoryCtrl>();
      if (controller.bookings.isEmpty) {
        controller.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryCtrl>();
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
              _buildHeader(controller),
              // _buildStatsSection(controller),
              const SizedBox(height: 20),
              _buildSearchAndFilters(controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.bookings.isEmpty) {
                    return const Center(child: CustomLoadingIndicator());
                  }
                  if (controller.bookings.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: controller.fetchHistory,
                    color: AppThemeColors.primaryOrange,
                    backgroundColor: AppThemeColors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: controller.bookings.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          child: _buildBookingCard(controller.bookings[index], controller, index),
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

  Widget _buildHeader(HistoryCtrl controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.white,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
        // ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppThemeColors.blackText.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppThemeColors.primaryOrange, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.travel_explore_rounded, color: AppThemeColors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Journeys", style: AppTextStyle.bold.copyWith(fontSize: 25, color: AppThemeColors.blackText, letterSpacing: -0.8, height: 1.1)),
                      const SizedBox(height: 4),
                      Text(
                        "Relive your memories and plan for the next one",
                        style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.blackText.withValues(alpha: 0.9), height: 1.3),
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

  Widget _buildSearchAndStats(HistoryCtrl controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppThemeStyles.shadowLight),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search by Booking ID, Destination",
                  hintStyle: AppTextStyle.medium.copyWith(color: AppThemeColors.greyText.withValues(alpha: 0.5), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: AppThemeColors.greyText.withValues(alpha: 0.5), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppThemeColors.primaryOrange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  "${controller.totalTrips.value} TOTAL TRIPS",
                  style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 10, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, HistoryCtrl controller, int index) {
    final package = booking.package;
    final coverImage = package?.coverImage ?? "";
    final title = booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details";
    final destination = package?.destination ?? "Unknown Location";
    final bookingId = booking.bookingId ?? "N/A";
    final travelDate = booking.travelDate != null ? AppDateFormat.monthDayYear(booking.travelDate!) : "N/A Date";
    final status = booking.bookingStatus ?? "pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppThemeColors.white,
        borderRadius: BorderRadius.circular(AppThemeStyles.radiusXLarge),
        boxShadow: AppThemeStyles.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              Hero(
                tag: 'history_image_$index',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppThemeStyles.radiusXLarge)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
                      ),
                    ),
                    child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$coverImage", fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_getStatusColor(status), _getStatusColor(status).withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: _getStatusColor(status).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Text(status.toUpperCase(), style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 11, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.confirmation_number_rounded, size: 14, color: AppThemeColors.primaryOrange),
                          const SizedBox(width: 4),
                          Text(bookingId, style: AppTextStyle.bold.copyWith(fontSize: 12, color: AppThemeColors.primaryOrange)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTextStyle.bold.copyWith(fontSize: 20, color: AppThemeColors.blackText, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.calendar_today_rounded, travelDate, AppThemeColors.primaryOrange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInfoItem(Icons.location_on_rounded, destination, AppThemeColors.warning)),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => controller.navigateToDetails(booking.bookingId!),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("View Trip Details", style: AppTextStyle.bold.copyWith(fontSize: 16, color: AppThemeColors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: AppThemeColors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.medium.copyWith(fontSize: 13, color: AppThemeColors.greyText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HistoryCtrl controller) {
    return Obx(() {
      final totalTrips = controller.totalTrips.value;
      final completedTrips = controller.bookings.where((booking) => booking.bookingStatus?.toLowerCase() == 'completed').length;
      final upcomingTrips = controller.bookings.where((booking) => booking.bookingStatus?.toLowerCase() == 'confirmed').length;

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppThemeColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppThemeStyles.shadowLight),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.flight_takeoff_rounded,
                label: "Total Trips",
                value: totalTrips.toString(),
                color: AppThemeColors.primaryOrange,
              ),
            ),
            Container(width: 1, height: 40, color: AppThemeColors.borderLight),
            Expanded(
              child: _buildStatItem(icon: Icons.check_circle_rounded, label: "Completed", value: completedTrips.toString(), color: AppThemeColors.success),
            ),
            Container(width: 1, height: 40, color: AppThemeColors.borderLight),
            Expanded(
              child: _buildStatItem(icon: Icons.schedule_rounded, label: "Upcoming", value: upcomingTrips.toString(), color: AppThemeColors.warning),
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

  Widget _buildSearchAndFilters(HistoryCtrl controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppThemeColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText),
          decoration: InputDecoration(
            hintText: "Search by Booking ID or Destination...",
            hintStyle: AppTextStyle.medium.copyWith(color: AppThemeColors.greyText, fontSize: 15),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.search_rounded, color: AppThemeColors.primaryOrange.withValues(alpha: 0.7), size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ),
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
              child: Icon(Icons.luggage_rounded, size: 64, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            Text("No Journeys Yet", style: AppTextStyle.bold.copyWith(fontSize: 24, color: AppThemeColors.blackText)),
            const SizedBox(height: 12),
            Text(
              "Your travel history will appear here once you start booking trips with us.",
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.greyText, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //   decoration: BoxDecoration(
            //     color: AppThemeColors.primaryOrange,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            //   ),
            //   child: Text("Start Your Journey", style: AppTextStyle.semiBold.copyWith(fontSize: 16, color: AppThemeColors.white)),
            // ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppThemeColors.info;
      case 'completed':
        return AppThemeColors.success;
      case 'pending':
        return AppThemeColors.warning;
      case 'cancelled':
        return AppThemeColors.error;
      default:
        return AppThemeColors.greyText;
    }
  }
}
