import 'dart:io';
import '../../../../../app_export.dart';
import '../../source/selfie_ui.dart';
import '../common/media_display_screen.dart';

class CommunityMediaScreen extends GetView<CommunityMediaCtrl> {
  const CommunityMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Obx(
        () => PopScope(
          canPop: !controller.selectionMode.value,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && controller.selectionMode.value) {
              controller.toggleSelectionMode(false);
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(
                controller.selectionMode.value 
                    ? "${controller.selectedMediaIds.length} selected" 
                    : "Community Gallery",
                style: AppTextStyle.bold.copyWith(
                  color: const Color(0xFF1E293B),
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (controller.selectionMode.value) {
                    controller.toggleSelectionMode(false);
                    return;
                  }
                  Get.back();
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  // decoration: BoxDecoration(
                  //   color: const Color(0xFFF1F5F9),
                  //   // borderRadius: BorderRadius.circular(12),
                  // ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              actions: [_buildAppBarActions(context)],
              elevation: 0,
              surfaceTintColor: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              scrolledUnderElevation: 8,
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TabBar(
                    onTap: (index) => controller.switchTab(index),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constant.instance.primary,
                          Constant.instance.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.semiBold.copyWith(fontSize: 14),
                    unselectedLabelStyle: AppTextStyle.medium.copyWith(fontSize: 14),
                    tabs: const [
                      Tab(text: "All Photos"),
                      Tab(text: "My Photos"),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _buildAllPhotosTab(),
                _buildMyPhotosTab(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllPhotosTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.images.isEmpty) {
        return const Center(child: CustomLoadingIndicator());
      }

      if (controller.images.isEmpty) {
        return _buildEmptyState();
      }

      return NotificationListener<ScrollNotification>( 
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () => controller.fetchImages(refresh: true),
          color: Constant.instance.primary,
          backgroundColor: Colors.white,
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: controller.images.length + (controller.isLoading.value ? 3 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.images.length) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CustomLoadingIndicator()),
                );
              }

              final image = controller.images[index];
              return Obx(() {
                final isSelected = controller.isSelected(image.id);
                final isSelectionMode = controller.selectionMode.value;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isSelectionMode) {
                      controller.toggleMediaSelection(image);
                    } else {
                      _openMedia(image);
                    }
                  },
                  onLongPress: () {
                    controller.toggleSelectionMode(true);
                    controller.toggleMediaSelection(image);
                  },
                  child: _buildMediaTile(
                    media: image,
                    isSelected: isSelected,
                    showSelectionUi: isSelectionMode,
                    showOwnerTag: controller.isOwnMedia(image),
                  ),
                );
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildMyPhotosTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Constant.instance.primary,
                        Constant.instance.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.face_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Photos",
                        style: AppTextStyle.bold.copyWith(
                          fontSize: 20,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.faceStatus.value == FaceStatus.hasMatches) {
                          return Text(
                            "Found your photos in the gallery",
                            style: AppTextStyle.medium.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          );
                        }
                        return Text(
                          "Find yourself in the collection",
                          style: AppTextStyle.medium.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                _buildRefreshButton(context),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => _buildMyPhotosContent(context)),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Constant.instance.primary.withValues(alpha: 0.1),
            Constant.instance.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Constant.instance.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRefreshDialog(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Constant.instance.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Refresh",
                  style: AppTextStyle.semiBold.copyWith(
                    fontSize: 14,
                    color: Constant.instance.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRefreshDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Refresh Photos",
                      style: AppTextStyle.bold.copyWith(
                        fontSize: 22,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildRefreshOption(
                  icon: Icons.refresh_rounded,
                  title: "Use Existing Image",
                  subtitle: "Re-scan using your current selfie",
                  color: Constant.instance.primary,
                  onTap: () {
                    Navigator.pop(context);
                    controller.checkFaceMatches();
                  },
                ),
                const SizedBox(height: 16),
                _buildRefreshOption(
                  icon: Icons.camera_alt_rounded,
                  title: "Take New Selfie",
                  subtitle: "Use a different photo for search",
                  color: Constant.instance.green2,
                  onTap: () {
                    Navigator.pop(context);
                    _openSelfieUI(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefreshOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.bold.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyle.medium.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPhotosContent(BuildContext context) {
    if (controller.faceStatus.value == FaceStatus.loading) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(child: CustomLoadingIndicator()),
      );
    }

    if (controller.faceStatus.value == FaceStatus.hasMatches && controller.matchedImages.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.matchedImages.length,
          itemBuilder: (context, index) {
            final image = controller.matchedImages[index];
            return Obx(() {
              final isSelected = controller.isSelected(image.id);
              final isSelectionMode = controller.selectionMode.value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isSelectionMode) {
                    controller.toggleMediaSelection(image);
                  } else {
                    _openMedia(image);
                  }
                },
                onLongPress: () {
                  controller.toggleSelectionMode(true);
                  controller.toggleMediaSelection(image);
                },
                child: _buildMediaTile(
                  media: image,
                  isSelected: isSelected,
                  showSelectionUi: isSelectionMode,
                  showOwnerTag: controller.isOwnMedia(image),
                ),
              );
            });
          },
        ),
      );
    }

    return _buildNoPhotosFoundState(context);
  }

  void _openSelfieUI(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelfieUI(distributorName: '', isProfile: false, communityId: controller.communityId),
      ),
    );

    if (result != null && result is File) {
      controller.findMyPhotos(selfie: result);
    } else {
      warningToast('Please capture a selfie to proceed');
    }
  }

  void _openMedia(CommunityImage media) {
    final url = controller.resolveMediaUrl(media);
    if (url == null) return;
    Get.to(() => MediaDisplayScreen(url: url, isVideo: controller.isVideoMedia(media)));
  }

  Widget _buildMediaTile({
    required CommunityImage media,
    required bool isSelected,
    required bool showSelectionUi,
    bool showOwnerTag = false,
  }) {
    final resolved = controller.resolveMediaUrl(media);
    final isVideo = controller.isVideoMedia(media);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(imageUrl: resolved, fit: BoxFit.cover),
            if (isVideo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            if (showSelectionUi)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Constant.instance.primary 
                        : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Constant.instance.primary 
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : null,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            if (showOwnerTag)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Constant.instance.primary,
                        Constant.instance.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Constant.instance.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVideo ? Icons.video_library_rounded : Icons.person_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVideo ? "My Video" : "My Photo",
                        style: AppTextStyle.bold.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
              decoration: BoxDecoration(
                color: Constant.instance.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_rounded,
                size: 64,
                color: Constant.instance.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Photos Found",
              style: AppTextStyle.bold.copyWith(
                fontSize: 24,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "No images found in this community gallery yet.",
              textAlign: TextAlign.center,
              style: AppTextStyle.medium.copyWith(
                fontSize: 16,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPhotosFoundState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constant.instance.primary.withValues(alpha: 0.1),
                  Constant.instance.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.face_rounded,
              size: 48,
              color: Constant.instance.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Photos Found",
            style: AppTextStyle.bold.copyWith(
              fontSize: 22,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Take a selfie to find your photos from this collection automatically.",
            textAlign: TextAlign.center,
            style: AppTextStyle.medium.copyWith(
              fontSize: 15,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constant.instance.primary,
                    Constant.instance.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Constant.instance.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openSelfieUI(context),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(
                  "Take a Selfie",
                  style: AppTextStyle.semiBold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    if (controller.selectionMode.value) {
      final selectableIds = _selectableMediaIds();
      final allSelected = selectableIds.isNotEmpty && controller.selectedMediaIds.length == selectableIds.length;
      return Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: selectableIds.isEmpty
                ? null
                : () {
                    if (allSelected) {
                      controller.selectedMediaIds.clear();
                    } else {
                      controller.selectedMediaIds.assignAll(selectableIds);
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  Icon(allSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: const Color(0xFF1E293B)),
                  const SizedBox(width: 4),
                  Text(allSelected ? "Unselect all" : "Select all", style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: controller.selectedMediaIds.isEmpty ? null : () => controller.downloadSelectedMedia(),
            icon: const Icon(Icons.download_rounded, color: Color(0xFF1E293B)),
          ),
          IconButton(
            onPressed: controller.selectedMediaIds.isEmpty ? null : () => _confirmDeleteSelected(context),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
        ],
      );
    }
    return IconButton(
      onPressed: () => controller.fetchImages(refresh: true),
      icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
    );
  }

  List<String> _selectableMediaIds() {
    final ids = <String>{};
    for (final item in controller.images) {
      if ((item.id ?? '').isNotEmpty) ids.add(item.id!);
    }
    for (final item in controller.matchedImages) {
      if ((item.id ?? '').isNotEmpty) ids.add(item.id!);
    }
    return ids.toList();
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete selected media?"),
        content: Text("This will remove ${controller.selectedMediaIds.length} item(s)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteSelectedMedia();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
