import '../../../../app_export.dart';
import 'vendor_home_ctrl.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // Trigger fetch if packages are empty (covers hot restart where onInit
    // already ran but the screen wasn't mounted yet to observe the result).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Get.find<VendorHomeCtrl>();
      if (ctrl.packages.isEmpty && !ctrl.isLoading.value) {
        ctrl.fetchPackages();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoo11n';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VendorHomeCtrl>();
    final authCtrl = Get.find<AuthenticationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting, style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                            const SizedBox(height: 4),
                            Obx(
                              () => Text(
                                authCtrl.userAuthData['name'] ?? 'Vendor',
                                style: AppTextStyle.bold.copyWith(fontSize: 22, color: Colors.white, letterSpacing: -0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: Obx(
                                () => Text(
                                  (authCtrl.userAuthData['type'] ?? 'vendor').toString().toUpperCase(),
                                  style: AppTextStyle.bold.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Icon with Badge
                      Builder(
                        builder: (context) {
                          // Initialize notification controller if not already registered
                          if (!Get.isRegistered<NotificationCtrl>()) {
                            Get.put(NotificationCtrl());
                          }
                          final notificationCtrl = Get.find<NotificationCtrl>();
                          
                          return GestureDetector(
                            onTap: () => Get.toNamed(RouteNames.notifications),
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                                  Obx(() {
                                    if (notificationCtrl.unreadCount.value > 0) {
                                      return Positioned(
                                        right: -4,
                                        top: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Constant.instance.primary, width: 2),
                                          ),
                                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                          child: Center(
                                            child: Text(
                                              notificationCtrl.unreadCount.value > 99 ? '99+' : '${notificationCtrl.unreadCount.value}',
                                              style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 9),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.store_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Package list ─────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.packages.isEmpty) {
                  return const Center(child: CustomLoadingIndicator());
                }
                if (ctrl.packages.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: ctrl.fetchPackages,
                  color: Constant.instance.primary,
                  backgroundColor: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: ctrl.packages.length,
                    itemBuilder: (context, index) => _buildPackageCard(ctrl.packages[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(VendorPackage pkg) {
    final imageUrl = pkg.coverImage.isNotEmpty ? '${AppNetworkConstants.baseURL}${pkg.coverImage}' : '';

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
          // Cover image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                CustomNetworkImage(imageUrl: imageUrl, height: 200, width: double.infinity),
                // Status badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _statusColor(pkg.status), borderRadius: BorderRadius.circular(10)),
                    child: Text(pkg.status.toUpperCase(), style: AppTextStyle.bold.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
                // Days badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '${pkg.totalDays} ${pkg.totalDays == 1 ? "Day" : "Days"}',
                      style: AppTextStyle.bold.copyWith(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.title, style: AppTextStyle.bold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: Constant.instance.primary),
                    const SizedBox(width: 4),
                    Text(pkg.destination, style: AppTextStyle.medium.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(Icons.currency_rupee_rounded, '${pkg.currency} ${pkg.basePrice.toStringAsFixed(0)}', Constant.instance.primary),
                    const SizedBox(width: 10),
                    _buildInfoChip(Icons.people_outline_rounded, 'Max ${pkg.maxCapacity}', Constant.instance.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyle.bold.copyWith(fontSize: 12, color: color)),
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
              decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.inventory_2_outlined, size: 56, color: Constant.instance.primary),
            ),
            const SizedBox(height: 24),
            Text('No Packages Yet', style: AppTextStyle.bold.copyWith(fontSize: 22, color: const Color(0xFF1E293B))),
            const SizedBox(height: 10),
            Text(
              'Your packages will appear here once they are created.',
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}
