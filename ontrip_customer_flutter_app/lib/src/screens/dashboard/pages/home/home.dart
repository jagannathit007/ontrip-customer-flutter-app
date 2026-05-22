
import '../../../../../app_export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    // Initialize HomeController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HomeController>();
      if (controller.bookings.isEmpty) {
        controller.initialize();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoo22n";
    return "Good Evening";
  }

  String getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 6) return "🌙";
    if (hour < 12) return "☀️";
    if (hour < 17) return "🌤️";
    if (hour < 20) return "🌅";
    return "🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: GetBuilder<HomeController>(
        builder: (ctrl) {
          return SafeArea(
            bottom: true,
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Enhanced Header with gradient background
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
                    child: _buildAppBar(ctrl),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => await ctrl.initialize(),
                      color: Constant.instance.primary,
                      backgroundColor: Colors.white,
                      child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: _buildSelectedBookingDetails(ctrl)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedBookingDetails(HomeController ctrl) {
    return Obx(() {
      final booking = ctrl.selectedBooking.value;
      if (booking == null) {
        return _buildEmptyBookingState();
      }

      return Column(children: [_buildTripHeader(booking), _buildTripTabSection(booking, ctrl)]);
    });
  }

  Widget _buildEmptyBookingState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.luggage_outlined, size: 48, color: Constant.instance.primary),
          ),
          const SizedBox(height: 24),
          Text("No Active Trips", style: AppTextStyle.bold.copyWith(fontSize: 20, color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Text(
            "Start planning your next adventure!",
            textAlign: TextAlign.center,
            style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHeader(Booking booking) {
    final package = booking.package;
    final coverImage = package?.coverImage ?? "";

    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$coverImage")),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.8)],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Text(
                      booking.bookingStatus?.toUpperCase() ?? "BOOKED",
                      style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details",
                    style: AppTextStyle.bold.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.2,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(package?.destination ?? "Exploring", style: AppTextStyle.medium.copyWith(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTabSection(Booking booking, HomeController ctrl) {
    final tabs = [
      {"label": "Itinerary", "icon": Icons.map_outlined},
      {"label": "Includes", "icon": Icons.check_circle_outline},
      {"label": "Excludes", "icon": Icons.cancel_outlined},
      {"label": "Support", "icon": Icons.headset_mic_outlined},
      {"label": "Feedback", "icon": Icons.star_outline},
    ];

    final contents = [
      _buildTripItinerary(booking, ctrl),
      _buildTripInclusions(booking),
      _buildTripExclusions(booking),
      _buildTripSupport(booking),
      _buildTripReviews(booking, ctrl),
    ];

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = ctrl.selectedTab.value == index;
                return GestureDetector(
                  onTap: () => ctrl.selectedTab.value = index,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]) : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Constant.instance.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 15 : 10,
                          offset: Offset(0, isSelected ? 6 : 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tabs[index]["icon"] as IconData, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          tabs[index]["label"] as String,
                          style: AppTextStyle.bold.copyWith(fontSize: 14, color: isSelected ? Colors.white : Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IndexedStack(key: ValueKey(ctrl.selectedTab.value), index: ctrl.selectedTab.value, children: contents),
          ),
        ],
      ),
    );
  }

  Widget _buildTripItinerary(Booking booking, HomeController ctrl) {
    final itinerary = booking.package?.itinerary ?? [];
    if (itinerary.isEmpty) return _buildTripEmptyState(Icons.map_outlined, "No itinerary available");

    return Column(
      children: [
        Container(
          height: 100, // Increased height to accommodate content
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itinerary.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final isSelected = ctrl.selectedDay.value == index;
                return GestureDetector(
                  onTap: () => ctrl.onDayChange(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12, // Reduced vertical margin
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]) : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Constant.instance.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isSelected ? 15 : 8,
                          offset: Offset(0, isSelected ? 6 : 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                      children: [
                        Text(
                          "DAY",
                          style: AppTextStyle.bold.copyWith(
                            fontSize: 10, // Slightly reduced font size
                            color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey.shade500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2), // Reduced spacing
                        Text(
                          "${index + 1}",
                          style: AppTextStyle.bold.copyWith(
                            fontSize: 18, // Slightly reduced font size
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        Obx(() {
          final dayData = itinerary[ctrl.selectedDay.value];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "DAY ${dayData.day}",
                          style: AppTextStyle.bold.copyWith(fontSize: 12, color: Constant.instance.primary, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(dayData.title ?? "Day ${dayData.day}", style: AppTextStyle.bold.copyWith(fontSize: 22, color: Colors.grey.shade800)),
                      const SizedBox(height: 12),
                      Text(
                        dayData.description ?? "",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.medium.copyWith(fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...(dayData.experiences ?? []).map((exp) => _buildTripExperience(exp, ctrl)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTripExperience(Experience exp, HomeController ctrl) {
    final image = exp.images?.isNotEmpty == true ? exp.images![0] : "";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  CustomNetworkImage(imageUrl: image.startsWith("http") ? image : "${AppNetworkConstants.baseURL}$image", height: 180, width: double.infinity),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("${exp.startTime} - ${exp.endTime ?? ""}", style: AppTextStyle.bold.copyWith(fontSize: 12, color: Constant.instance.primary)),
                    ),
                    if (exp.vendor?.phone?.isNotEmpty == true)
                      GestureDetector(
                        onTap: () => ctrl.callVendor(exp.vendor?.phone),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.call, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(exp.name ?? "", style: AppTextStyle.bold.copyWith(fontSize: 18, color: Colors.grey.shade800)),
                const SizedBox(height: 8),
                Text(exp.description ?? "", style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade600, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInclusions(Booking booking) {
    final inclusions = booking.package?.inclusions ?? [];
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text("INCLUSIONS", style: AppTextStyle.bold.copyWith(color: Colors.green, fontSize: 12, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...inclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripExclusions(Booking booking) {
    final exclusions = booking.package?.exclusions ?? [];
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text("EXCLUSIONS", style: AppTextStyle.bold.copyWith(color: Colors.red, fontSize: 12, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...exclusions.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.toString(), style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSupport(Booking booking) {
    final agency = booking.agencyCustomer;
    if (agency == null) return _buildTripEmptyState(Icons.headset_mic, "No support contact");
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Constant.instance.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.headset_mic_outlined, color: Constant.instance.primary, size: 16),
                const SizedBox(width: 8),
                Text("SUPPORT CONTACT", style: AppTextStyle.bold.copyWith(color: Constant.instance.primary, fontSize: 12, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: Text(agency.name?[0].toUpperCase() ?? "S", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agency.name ?? "Support", style: AppTextStyle.bold.copyWith(fontSize: 18, color: Colors.grey.shade800)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text("Travel Agent", style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (agency.phone?.isNotEmpty == true)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.phone, color: Colors.green, size: 20),
                ),
                title: Text(agency.phone!, style: AppTextStyle.medium.copyWith(fontSize: 16, color: Colors.grey.shade800)),
                subtitle: Text("Tap to call", style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade500)),
                onTap: () => AppUrl.call("tel:${agency.phone}", mobile: agency.phone!),
              ),
            ),
          if (agency.email?.isNotEmpty == true)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.email, color: Colors.blue, size: 20),
                ),
                title: Text(agency.email!, style: AppTextStyle.medium.copyWith(fontSize: 16, color: Colors.grey.shade800)),
                subtitle: Text("Tap to email", style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade500)),
                onTap: () => AppUrl.mail(email: agency.email!, subject: "Trip Enquiry"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripReviews(Booking booking, HomeController ctrl) {
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
            Text("YOUR EXPERIENCE", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Colors.grey.shade400, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildManageUserReview(ctrl),
            const SizedBox(height: 32),
            Text("GUEST FEEDBACK", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Colors.grey.shade400, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            if (reviews.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Constant.instance.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Constant.instance.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    _buildRatingSummaryItem("Package", avgPackage),
                    Container(height: 40, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildRatingSummaryItem("Overall", avgOverall),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$total", style: AppTextStyle.bold.copyWith(fontSize: 18, color: Constant.instance.primary)),
                        Text("Reviews", style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade500)),
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

  Widget _buildManageUserReview(HomeController ctrl) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey.shade50]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctrl.userReview.value == null ? "How was your trip?" : "Your Review",
                    style: AppTextStyle.bold.copyWith(fontSize: 18, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.userReview.value == null ? "Share your experience with others" : "Thank you for your feedback!",
                    style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (ctrl.userReview.value != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green, Colors.green.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text("SUBMITTED", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 0.5)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => ctrl.userReview.value == null ? ctrl.userRating.value = index + 1.0 : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.star_rounded, size: 40, color: index < ctrl.userRating.value ? Colors.amber : Colors.grey.shade300),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: ctrl.reviewCommentCtrl,
              maxLines: 4,
              readOnly: ctrl.userReview.value != null,
              decoration: InputDecoration(
                hintText: "Share your experience with others...",
                hintStyle: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade400),
                filled: false,
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
              ),
              style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          if (ctrl.userReview.value == null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: ctrl.isReviewLoading.value ? null : () => ctrl.submitReview(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ).copyWith(backgroundColor: WidgetStateProperty.all(Colors.transparent)),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: ctrl.isReviewLoading.value
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Submit Review", style: AppTextStyle.bold.copyWith(fontSize: 16, color: Colors.white)),
                  ),
                ),
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(review.customerName?[0].toUpperCase() ?? "U", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName ?? "Guest User", style: AppTextStyle.bold.copyWith(fontSize: 16, color: Colors.grey.shade800)),
                    const SizedBox(height: 4),
                    if (review.createdAt != null)
                      Text(AppDateFormat.monthDayYear(review.createdAt!), style: AppTextStyle.medium.copyWith(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber, Colors.amber.withValues(alpha: 0.8)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${(review.packageRating ?? review.overallRating ?? 0.0).toInt()}",
                      style: AppTextStyle.bold.copyWith(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(review.comment!, style: AppTextStyle.medium.copyWith(fontSize: 14, color: Colors.grey.shade700, height: 1.6)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripEmptyState(IconData icon, String msg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookingsCarousel(HomeController ctrl) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (ctrl.bookings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("On-Going Trips", style: AppTextStyle.bold.copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                onPageChanged: (index) => ctrl.carouselIndex.value = index,
                itemCount: ctrl.bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(ctrl.bookings[index], ctrl);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBookingCard(Booking booking, HomeController ctrl) {
    final package = booking.package;
    final coverImage = package?.coverImage ?? "";
    final title = booking.whitelabelPackage?.customTitle ?? package?.title ?? "Trip Details";
    final destination = package?.destination ?? "Unknown Location";

    return GestureDetector(
      onTap: () {
        ctrl.setBooking(booking);
        Get.toNamed(RouteNames.bookingDetails, arguments: booking.bookingId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$coverImage")),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.8)],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.bold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: -0.2,
                        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationBadge(destination),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBadge(String destination) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(destination.toUpperCase(), style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(width: 12),
          _buildPaginationDots(),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(ctrl.bookings.length, (index) {
            return Obx(() {
              final active = ctrl.carouselIndex.value == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                height: 6,
                width: active ? 20 : 6,
                decoration: BoxDecoration(color: active ? Colors.white : Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
              );
            });
          }),
        );
      },
    );
  }

  // Widget _buildModernHeader(HomeController ctrl) {
  //   return SliverToBoxAdapter(
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 30),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.9), Constant.instance.primary.withValues(alpha: 0.7)],
  //         ),
  //         borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
  //         boxShadow: [BoxShadow(color: Constant.instance.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "${getGreetingText()} ${getGreetingEmoji()}",
  //                     style: AppTextStyle.medium.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text("Welcome to OnTrip", style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
  //                 ],
  //               ),
  //               GestureDetector(
  //                 onTap: () => Get.toNamed(RouteNames.settings),
  //                 child: Container(
  //                   padding: const EdgeInsets.all(10),
  //                   decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
  //                   child: const Icon(Icons.person_outline, color: Colors.white),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 30),
  //           _buildStatCard(ctrl),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildAppBar(HomeController ctrl) {
  //   return SliverToBoxAdapter(
  //     child: Obx(() {
  //       final authCtrl = Get.find<AuthenticationController>();
  //       final name = authCtrl.userAuthData['name'] ?? "User";

  //       return Container(
  //         width: double.infinity,
  //         // padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 30),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [
  //               Constant.instance.primary,
  //               Constant.instance.primary.withValues(alpha: 0.9),
  //               Constant.instance.primary.withValues(alpha: 0.7),
  //             ],
  //           ),
  //           borderRadius: const BorderRadius.only(
  //             bottomLeft: Radius.circular(40),
  //             bottomRight: Radius.circular(40),
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Constant.instance.primary.withValues(alpha: 0.3),
  //               blurRadius: 20,
  //               offset: const Offset(0, 10),
  //             ),
  //           ],
  //         ),
  //         padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
  //         child: Row(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Constant.instance.white,
  //                 shape: BoxShape.circle,
  //                 border: Border.all(
  //                   color: Constant.instance.primary,
  //                   width: 2,
  //                 ),
  //               ),
  //               padding: const EdgeInsets.all(12),
  //               child: Center(
  //                 child: Text(
  //                   name.substring(0, 1).toUpperCase(),
  //                   style: AppTextStyle.bold.copyWith(
  //                     color: Constant.instance.primary,
  //                     fontSize: 35,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "$name’s Trips",
  //                     style: AppTextStyle.bold.copyWith(
  //                       color: Constant.instance.white,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   Text(
  //                     AppDateFormat.monthDayYear(DateTime.now()),
  //                     style: AppTextStyle.medium.copyWith(
  //                       color: Constant.instance.white.withValues(alpha: 0.8),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             // IconButton(
  //             //   onPressed: () {},
  //             //   icon: Icon(Icons.notifications_none_rounded, color: Constant.instance.white, size: 28),
  //             // ),
  //           ],
  //         ),
  //       );
  //     }),
  //   );
  // }

  Widget _buildAppBar(HomeController ctrl) {
    return Obx(() {
      final authCtrl = Get.find<AuthenticationController>();
      final name = authCtrl.userAuthData['name'] ?? "User";

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with emoji
                  Row(
                    children: [
                      Text("${getGreetingText()}, ", style: AppTextStyle.bold.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 17, height: 1.2)),
                      Text(getGreetingEmoji(), style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // User name
                  Text(
                    name,
                    style: AppTextStyle.bold.copyWith(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // // Subtitle
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withValues(alpha: 0.2),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Text(
                  //     "Your Travel Dashboard",
                  //     style: AppTextStyle.medium.copyWith(
                  //       color: Colors.white.withValues(alpha: 0.9),
                  //       fontSize: 12,
                  //       letterSpacing: 0.5,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // Enhanced Profile Avatar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Constant.instance.primary, Constant.instance.primary.withValues(alpha: 0.8)]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(name.substring(0, 1).toUpperCase(), style: AppTextStyle.bold.copyWith(color: Colors.white, fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
