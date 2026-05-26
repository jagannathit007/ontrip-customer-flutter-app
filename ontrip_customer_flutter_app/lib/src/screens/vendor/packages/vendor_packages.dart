// Updated VendorPackagesScreen with corrected Notification Builder
import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../../../../app_export.dart';
import '../home/vendor_home_ctrl.dart';

/// Vendor "Packages" tab — same data as home but in a searchable list layout,
/// mirroring the customer History screen pattern.
class VendorPackagesScreen extends StatefulWidget {
  const VendorPackagesScreen({super.key});

  @override
  State<VendorPackagesScreen> createState() => _VendorPackagesScreenState();
}

class _VendorPackagesScreenState extends State<VendorPackagesScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _query = ''.obs;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    _searchCtrl.addListener(() => _query.value = _searchCtrl.text.toLowerCase());
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VendorHomeCtrl>();
    final authCtrl = Get.find<AuthenticationController>();
    return Scaffold(
      backgroundColor: AppThemeColors.bgCream,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: [AppThemeColors.primaryOrange, AppThemeColors.primaryOrange.withValues(alpha: 0.8)],
                // ),
                color: AppThemeColors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: AppThemeColors.white, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(2),

                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppThemeColors.primaryOrange, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              (authCtrl.userAuthData['name']?.toString().isNotEmpty ?? false) ? authCtrl.userAuthData['name'][0].toUpperCase() : 'V',
                              style: AppTextStyle.bold.copyWith(color: AppThemeColors.white, fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting, style: AppTextStyle.medium.copyWith(fontSize: 16, color: AppThemeColors.blackText.withValues(alpha: 0.8))),
                            const SizedBox(height: 4),
                            Obx(
                              () => Text(
                                authCtrl.userAuthData['name'] ?? 'Vendor',
                                style: AppTextStyle.bold.copyWith(fontSize: 24, color: AppThemeColors.blackText, letterSpacing: -0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                              child: Obx(
                                () => Text(
                                  (authCtrl.userAuthData['type'] ?? 'vendor').toString().toUpperCase(),
                                  style: AppTextStyle.bold.copyWith(fontSize: 10, color: AppThemeColors.white, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Icon with Badge
                      Builder(
                        builder: (context) {
                          if (!Get.isRegistered<NotificationCtrl>()) {
                            Get.put(NotificationCtrl());
                          }
                          final notificationCtrl = Get.find<NotificationCtrl>();

                          return GestureDetector(
                            onTap: () => Get.toNamed(RouteNames.notifications),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_rounded, color: AppThemeColors.primaryOrange, size: 30),
                                  Obx(() {
                                    if (notificationCtrl.unreadCount.value > 0) {
                                      return Positioned(
                                        right: -5,
                                        top: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppThemeColors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppThemeColors.primaryOrange, width: 2),
                                          ),
                                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                          child: Center(
                                            child: Text(
                                              notificationCtrl.unreadCount.value > 9 ? '9+' : '${notificationCtrl.unreadCount.value}',
                                              style: AppTextStyle.bold.copyWith(color: AppThemeColors.primaryOrange, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Search ───────────────────────────────────────────

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.packages.isEmpty) {
                  return const Center(child: CustomLoadingIndicator());
                }

                final filtered = ctrl.packages.where((p) {
                  final q = _query.value;
                  if (q.isEmpty) return true;
                  return p.title.toLowerCase().contains(q) || p.destination.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: ctrl.fetchPackages,
                  color: AppThemeColors.primaryOrange,
                  backgroundColor: AppThemeColors.bgCream,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          // color: AppThemeColors.bgCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppThemeColors.borderLight),
                          // boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText),
                          decoration: InputDecoration(
                            fillColor: AppThemeColors.white,
                            hintText: 'Search by title or destination...',
                            hintStyle: AppTextStyle.medium.copyWith(color: AppThemeColors.greyText, fontSize: 15),
                            prefixIcon: Icon(Icons.search_rounded, color: AppThemeColors.primaryOrange.withValues(alpha: 0.7), size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _buildCard(filtered[index]),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(VendorPackage pkg) {
    final imageUrl = pkg.coverImage.isNotEmpty ? '${AppNetworkConstants.baseURL}${pkg.coverImage}' : '';

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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppThemeStyles.radiusXLarge)),
            child: Stack(
              children: [
                CustomNetworkImage(imageUrl: imageUrl, height: 180, width: double.infinity),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: _statusColor(pkg.status), borderRadius: BorderRadius.circular(8)),
                    child: Text(pkg.status.toUpperCase(), style: AppTextStyle.bold.copyWith(fontSize: 10, color: AppThemeColors.white, letterSpacing: 0.5)),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(8)),
                    child: Text('${pkg.totalDays}D', style: AppTextStyle.bold.copyWith(fontSize: 11, color: AppThemeColors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(pkg.title, style: AppTextStyle.bold.copyWith(fontSize: 18, color: AppThemeColors.blackText)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.location_on_rounded, pkg.destination, AppThemeColors.warning)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoItem(Icons.currency_rupee_rounded, '${pkg.currency} ${pkg.basePrice.toStringAsFixed(0)}', AppThemeColors.primaryOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteNames.vendorPackageDetails, arguments: pkg);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              margin: EdgeInsets.all(12),
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
    );
  }

  Widget _buildInfoItem(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.greyText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
              child: Icon(Icons.inventory_2_outlined, size: 56, color: AppThemeColors.primaryOrange),
            ),
            const SizedBox(height: 24),
            Text('No Packages Found', style: AppTextStyle.bold.copyWith(fontSize: 22, color: AppThemeColors.blackText)),
            const SizedBox(height: 10),
            Text(
              'No packages match your search.',
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.greyText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppThemeColors.success;
      case 'pending':
        return AppThemeColors.warning;
      case 'rejected':
        return AppThemeColors.error;
      default:
        return AppThemeColors.greyText;
    }
  }
}
