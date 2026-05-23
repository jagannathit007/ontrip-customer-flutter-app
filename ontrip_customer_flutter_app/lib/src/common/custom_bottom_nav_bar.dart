import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';

import '../../app_export.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTabChange});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;

  // Determine user role
  final bool isVendor = getStorage(AppSession.userRole) == 'vendor';
  late final List<NavItem> _navItems = isVendor
      ? [
          NavItem(iconAsset: Graphics.instance.iconHistory, activeIconAsset: Graphics.instance.iconHistory, label: 'Trip', iconType: NavIconType.icon),
          NavItem(iconAsset: Graphics.instance.iconCommunity, activeIconAsset: Graphics.instance.iconCommunity, label: 'Community', iconType: NavIconType.icon),
          NavItem(iconAsset: Graphics.instance.iconProfile, activeIconAsset: Graphics.instance.iconProfile, label: 'Profile', iconType: NavIconType.icon),
        ]
      : [
          NavItem(iconAsset: Graphics.instance.iconHome, activeIconAsset: Graphics.instance.iconHistory, label: 'Trip', iconType: NavIconType.icon),
          NavItem(iconAsset: Graphics.instance.iconHistory, activeIconAsset: Graphics.instance.iconHistory, label: 'History', iconType: NavIconType.icon),

          NavItem(iconAsset: Graphics.instance.iconCommunity, activeIconAsset: Graphics.instance.iconCommunity, label: 'Community', iconType: NavIconType.icon),
          NavItem(iconAsset: Graphics.instance.iconProfile, activeIconAsset: Graphics.instance.iconProfile, label: 'Profile', iconType: NavIconType.icon),
        ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationControllers = List.generate(_navItems.length, (index) => AnimationController(duration: const Duration(milliseconds: 300), vsync: this));
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Container(
  //       padding: const EdgeInsets.only(bottom: 10),
  //       alignment: Alignment.bottomCenter,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //         decoration: BoxDecoration(
  //           color: Colors.white70, // Dark capsule background
  //           borderRadius: BorderRadius.circular(100),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.3),
  //               blurRadius: 20,
  //               offset: const Offset(0, 10),
  //             ),
  //           ],
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min, // Essential to keep the "pill" look
  //           children: List.generate(_navItems.length, (index) {
  //             return _buildPillNavItem(index);
  //           }),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPillNavItem(int index) {
  //   final isActive = widget.currentIndex == index;
  //   final item = _navItems[index];

  //   return GestureDetector(
  //     onTap: () => widget.onTabChange(index),
  //     behavior: HitTestBehavior.opaque,
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //       margin: const EdgeInsets.symmetric(horizontal: 4),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //       decoration: BoxDecoration(
  //         // Active item gets the green pill background
  //         color: isActive ? item.activeColor : Colors.transparent,
  //         borderRadius: BorderRadius.circular(100),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           SvgPicture.asset(
  //             isActive ? item.activeIconAsset! : item.iconAsset!,
  //             width: 20,
  //             height: 20,
  //             // Icon is black on green background, white on black background
  //             colorFilter: ColorFilter.mode(
  //               isActive ? Colors.white : Colors.black,
  //               BlendMode.srcIn,
  //             ),
  //           ),

  //           // This handles the sliding text expansion
  //           AnimatedSize(
  //             duration: const Duration(milliseconds: 300),
  //             curve: Curves.easeInOut,
  //             child: SizedBox(
  //               width: isActive ? null : 0,
  //               child: isActive
  //                   ? Padding(
  //                       padding: const EdgeInsets.only(left: 8.0),
  //                       child: Text(
  //                         item.label,
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                     )
  //                   : const SizedBox.shrink(),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //=======

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white70, // Dark capsule background
          borderRadius: BorderRadius.circular(100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    // final isActive = widget.currentIndex == index;
    // final item = _navItems[index];
    // return Expanded(
    //   child: GestureDetector(
    //     onTap: () => widget.onTabChange(index),
    //     behavior: HitTestBehavior.opaque,
    //     child: AnimatedBuilder(
    //       animation: _animationControllers[index],
    //       builder: (context, child) {
    //         return Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    //           decoration: BoxDecoration(
    //             color: isActive
    //                 ? item.activeColor.withValues(alpha: 0.1)
    //                 : Colors.transparent,
    //             borderRadius: BorderRadius.circular(20),
    //           ),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               AnimatedContainer(
    //                 duration: const Duration(milliseconds: 250),
    //                 curve: Curves.easeOutCubic,
    //                 width: 35,
    //                 height: 35,
    //                 decoration: BoxDecoration(shape: BoxShape.rectangle),
    //                 child: _buildIcon(item, isActive),
    //               ),
    //               const SizedBox(height: 4),
    //               AnimatedDefaultTextStyle(
    //                 duration: const Duration(milliseconds: 200),
    //                 style: TextStyle(
    //                   fontSize: isActive ? 11 : 10,
    //                   fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
    //                   color: isActive ? item.activeColor : Colors.grey.shade600,
    //                 ),
    //                 child: AnimatedOpacity(
    //                   opacity: isActive ? 1.0 : 0.7,
    //                   duration: const Duration(milliseconds: 200),
    //                   child: Text(
    //                     item.label,
    //                     maxLines: 1,
    //                     overflow: TextOverflow.ellipsis,
    //                     textAlign: TextAlign.center,
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         );
    //       },
    //     ),
    //   ),
    // );

    final isActive = widget.currentIndex == index;
    final item = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTabChange(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            // Active item gets the green pill background
            color: isActive ? AppThemeColors.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isActive ? item.activeIconAsset! : item.iconAsset!,
                width: 20,
                height: 20,
                // Icon is black on green background, white on black background
                colorFilter: ColorFilter.mode(isActive ? Colors.white : Colors.black, BlendMode.srcIn),
              ),

              if (isActive)
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        // overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(NavItem item, bool isActive) {
    final iconSize = isActive ? 25.0 : 20.0;
    return AnimatedScale(
      scale: isActive ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SvgPicture.asset(
        isActive ? item.activeIconAsset! : item.iconAsset!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(isActive ? AppThemeColors.primaryOrange : Colors.grey.shade400, BlendMode.srcIn),
      ),
    );
  }
}

enum NavIconType { icon, scanButton }

class NavItem {
  final String? iconAsset;
  final String? activeIconAsset;
  final String label;
  final NavIconType iconType;

  NavItem({this.iconAsset, this.activeIconAsset, required this.label, required this.iconType});
}

// import '../../app_export.dart';

// class CustomBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTabChange;

//   const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTabChange});

//   @override
//   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// }

// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   // Keeping your existing items list
 
 
 
//   final List<NavItem> _navItems = [
//     NavItem(
//       iconAsset: Graphics.instance.iconHome,
//       activeIconAsset: Graphics.instance.iconHomeFill,
//       label: 'Trip',
//       activeColor: const Color(0xFF99C14D), // The lime green from your image
//       iconType: NavIconType.icon,
//     ),
//     NavItem(
//       iconAsset: Graphics.instance.iconHistory,
//       activeIconAsset: Graphics.instance.iconHistory,
//       label: 'History',
//       activeColor: const Color(0xFF99C14D),
//       iconType: NavIconType.icon,
//     ),
//     NavItem(
//       iconAsset: Graphics.instance.iconCommunity,
//       activeIconAsset: Graphics.instance.iconCommunity,
//       label: 'Community',
//       activeColor: const Color(0xFF99C14D),
//       iconType: NavIconType.icon,
//     ),
//     NavItem(
//       iconAsset: Graphics.instance.iconProfile,
//       activeIconAsset: Graphics.instance.iconProfile,
//       label: 'Profile',
//       activeColor: const Color(0xFF99C14D),
//       iconType: NavIconType.icon,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.black, // Dark capsule background
//           borderRadius: BorderRadius.circular(100),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min, // Essential to keep the "pill" look
//           children: List.generate(_navItems.length, (index) {
//             return _buildPillNavItem(index);
//           }),
//         ),
//       ),
//     );
//   }

//   Widget _buildPillNavItem(int index) {
//     final isActive = widget.currentIndex == index;
//     final item = _navItems[index];

//     return GestureDetector(
//       onTap: () => widget.onTabChange(index),
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           // Active item gets the green pill background
//           color: isActive ? item.activeColor : Colors.transparent,
//           borderRadius: BorderRadius.circular(100),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(
//               isActive ? item.activeIconAsset! : item.iconAsset!,
//               width: 20,
//               height: 20,
//               // Icon is black on green background, white on black background
//               colorFilter: ColorFilter.mode(
//                 isActive ? Colors.black : Colors.white,
//                 BlendMode.srcIn,
//               ),
//             ),
            
//             // This handles the sliding text expansion
//             AnimatedSize(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               child: SizedBox(
//                 width: isActive ? null : 0,
//                 child: isActive
//                     ? Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Text(
//                           item.label,
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }