import 'dart:io';

import '../../../../../app_export.dart';
import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import '../common/media_display_screen.dart';

class CommunityChatScreen extends StatelessWidget {
  const CommunityChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityChatCtrl>(
      init: CommunityChatCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemeColors.bgCream,
          appBar: _buildAppBar(controller),
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.messages.isEmpty) {
                    return const Center(child: CustomLoadingIndicator());
                  }
                  if (controller.community.value == null) {
                    return const Center(child: NoDataComponent(text: "No community found for your current trip"));
                  }
                  if (controller.messages.isEmpty) {
                    return const Center(child: Text("Start the conversation!"));
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                }),
              ),
              _buildInputArea(controller),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(CommunityChatCtrl controller) {
    return AppBar(
      backgroundColor: AppThemeColors.primaryOrange,
      elevation: 0,
      // surfaceTintColor: AppThemeColors.primaryOrange,
      shadowColor: AppThemeColors.shadowMedium,
      scrolledUnderElevation: 8,
      leadingWidth: 100,
      leading: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeColors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppThemeColors.white),
            ),
          ),
          // Container(
          //   // height: 44,
          //   // width: 44,
          //   decoration: BoxDecoration(
          //     // gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)]),
          //     borderRadius: BorderRadius.circular(14),
          //     // boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
          //   ),
          //   child: Obx(() {
          //     final img = controller.coverImage.value;
          //     return Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(color: AppThemeColors.greyText.withValues(alpha: 0.5)),
          //         // boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
          //       ),
          //       child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$img", height: 45, width: 45, fit: BoxFit.cover),
          //     );

          //     // ClipRRect(
          //     //   borderRadius: BorderRadius.circular(14),
          //     //   child: img != null && img.isNotEmpty
          //     //       ? CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}$img", height: 44, width: 44, fit: BoxFit.cover)
          //     //       : const Icon(Icons.forum_rounded, color: Colors.white, size: 20),
          //     // );
          //   }),
          // ),
          Obx(() {
            final img = controller.coverImage.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomNetworkImage(height: 46, width: 45, imageUrl: "${AppNetworkConstants.baseURL}$img", fit: BoxFit.fill),
            );
          }),
        ],
      ),
      title: Obx(() {
        final title = controller.community.value?.package?.title ?? "Community";
        final participants =
            (controller.community.value?.agentMembers?.length ?? 0) +
            (controller.community.value?.vendorMembers?.length ?? 0) +
            (controller.community.value?.customerMembers?.length ?? 0);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.bold.copyWith(fontSize: 18, color: AppThemeColors.blackText, height: 1.2)),
                  const SizedBox(height: 2),
                  Text("$participants participants", style: AppTextStyle.medium.copyWith(fontSize: 12, color: AppThemeColors.blackText)),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        Obx(
          () => GestureDetector(
            onTap: () {
              if (controller.community.value != null) {
                controller.toggleNotificationPreference();
              } else {
                warningToast("Community not loaded yet");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              // decoration: BoxDecoration(
              //   color: controller.notificationEnabled.value ? AppThemeColors.white.withValues(alpha: 0.3) : AppThemeColors.greyText,
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(color: AppThemeColors.white),
              //   boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
              // ),
              // borderRadius: BorderRadius.circular(12),
              // border: Border.all(color: controller.notificationEnabled.value ? AppThemeColors.borderOrange : AppThemeColors.borderLight),
              // ),
              child: Icon(
                controller.notificationEnabled.value ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                color: controller.notificationEnabled.value ? AppThemeColors.primaryOrange : AppThemeColors.greyText,
                size: 18,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            final community = controller.community.value;
            if (community != null) {
              Get.toNamed(RouteNames.groupMembers, arguments: community);
            } else {
              warningToast("Community not loaded yet");
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.group_rounded, color: AppThemeColors.info, size: 18),
          ),
        ),
        GestureDetector(
          onTap: () {
            final community = controller.community.value;
            if (community != null) {
              Get.toNamed(RouteNames.communityMedia, arguments: community.id);
            } else {
              warningToast("Community not loaded yet");
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.image_rounded, color: AppThemeColors.success, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(CommunityMessage message) {
    final authCtrl = Get.find<AuthenticationController>();
    final myId = authCtrl.userAuthData["_id"]?.toString();
    final isMe = myId != null && message.senderId == myId;
    final time = message.createdAt != null ? AppDateFormat.hhmma(message.createdAt!) : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 52, bottom: 6),
              child: Text(message.senderName, style: AppTextStyle.semiBold.copyWith(fontSize: 12, color: AppThemeColors.primaryOrange)),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[_buildAvatar(message.senderName, isMe: false), const SizedBox(width: 12)],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)])
                        : null,
                    color: isMe ? null : AppThemeColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe ? AppThemeColors.primaryOrange.withValues(alpha: 0.2) : AppThemeColors.shadowLight,
                        blurRadius: isMe ? 12 : 8,
                        offset: Offset(0, isMe ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMessageContent(message, isMe),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time, style: AppTextStyle.medium.copyWith(fontSize: 11, color: isMe ? AppThemeColors.subWhite : AppThemeColors.greyText)),
                          if (isMe) ...[const SizedBox(width: 6), Icon(Icons.done_all_rounded, size: 14, color: AppThemeColors.white.withValues(alpha: 0.8))],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // if (isMe) const SizedBox(width: 40),
              // if (!isMe) const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  void _showMediaPickerOptions(CommunityChatCtrl controller) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: AppThemeColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
              ),

              /// Camera Photo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppThemeColors.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: AppThemeColors.primaryOrange),
                ),
                title: const Text("Take Photo"),
                onTap: () async {
                  Get.back();
                  await controller.pickMediaFromCamera();
                },
              ),

              /// Camera Video
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.videocam_rounded, color: Colors.red),
                ),
                title: const Text("Record Video"),
                onTap: () async {
                  Get.back();
                  await controller.pickMediaFromCamera(isVideo: true);
                },
              ),

              /// Gallery
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppThemeColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: AppThemeColors.success),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Get.back();
                  await controller.pickMedia();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, {required bool isMe}) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isMe ? [AppThemeColors.primaryOrange, const Color(0xFFF28E65)] : [AppThemeColors.warning, const Color(0xFFFCD34D)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: (isMe ? AppThemeColors.primaryOrange : AppThemeColors.warning).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: AppTextStyle.bold.copyWith(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  // Widget _buildMessageContent(CommunityMessage message, bool isMe) {
  //   if (message.type == "image") {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(12),
  //           child: CustomNetworkImage(imageUrl: "${AppNetworkConstants.baseURL}${message.imageUrl}", width: 200),
  //         ),
  //         if (message.content?.isNotEmpty == true) ...[
  //           const SizedBox(height: 8),
  //           Text(message.content!, style: AppTextStyle.medium.copyWith(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF1E293B))),
  //         ],
  //       ],
  //     );
  //   }
  //   return Text(message.content ?? "", style: AppTextStyle.medium.copyWith(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF1E293B)));
  // }

  Widget _buildMessageContent(CommunityMessage message, bool isMe) {
    final mediaUrl = message.imageUrl ?? message.imageUrl ?? message.imageUrl;

    if (message.type == "image" || (mediaUrl != null && !_isVideoFile(mediaUrl))) {
      return _buildImageContent(message, isMe);
    } else if (message.type == "video" || _isVideoFile(mediaUrl ?? "")) {
      return _buildVideoContent(message, isMe);
    }

    // Default: Text message
    return Text(
      message.content ?? "",
      style: AppTextStyle.medium.copyWith(fontSize: 15, color: isMe ? AppThemeColors.white : AppThemeColors.blackText, height: 1.4),
    );
  }

  bool _isVideoFile(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv') || lower.endsWith('.webm');
  }

  Widget _buildImageContent(CommunityMessage message, bool isMe) {
    final imageUrl = _resolveMediaUrl(message.imageUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl == null) return;
            Get.to(() => MediaDisplayScreen(url: imageUrl, isVideo: false));
          },
          onLongPress: () => _showMediaActions(message: message, mediaUrl: imageUrl, isVideo: false, isMe: isMe),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomNetworkImage(imageUrl: imageUrl, width: 240, height: 240, fit: BoxFit.cover),
            ),
          ),
        ),
        if (message.content?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(message.content!, style: AppTextStyle.medium.copyWith(fontSize: 15, color: isMe ? AppThemeColors.white : AppThemeColors.blackText, height: 1.4)),
        ],
      ],
    );
  }

  Widget _buildVideoContent(CommunityMessage message, bool isMe) {
    final videoUrl = _resolveMediaUrl(message.videoUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.6)],
                    ),
                  ),
                  child: message.videoUrl != null
                      ? CustomNetworkImage(imageUrl: videoUrl, width: 240, height: 240, fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.video_library_rounded, size: 60, color: Colors.white70)),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "My Video",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  if (videoUrl == null) return;
                  Get.to(() => MediaDisplayScreen(url: videoUrl, isVideo: true));
                },
                onLongPress: () => _showMediaActions(message: message, mediaUrl: videoUrl, isVideo: true, isMe: isMe),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppThemeColors.primaryOrange, size: 32),
                ),
              ),
            ],
          ),
        ),
        if (message.content?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(message.content!, style: AppTextStyle.medium.copyWith(fontSize: 15, color: isMe ? AppThemeColors.white : AppThemeColors.blackText, height: 1.4)),
        ],
      ],
    );
  }

  Widget _buildInputArea(CommunityChatCtrl controller) {
    return Obx(() {
      final hasImages = controller.selectedImages.isNotEmpty;
      final hasMedia = controller.selectedImages.isNotEmpty || controller.selectedVideos.isNotEmpty;
      return Container(
        decoration: BoxDecoration(
          color: AppThemeColors.white,
          boxShadow: [BoxShadow(color: AppThemeColors.shadowMedium, blurRadius: 24, offset: const Offset(0, -8))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasMedia)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(top: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.selectedImages.length + controller.selectedVideos.length,
                    itemBuilder: (context, index) {
                      final bool isImage = index < controller.selectedImages.length;
                      final file = isImage ? controller.selectedImages[index] : controller.selectedVideos[index - controller.selectedImages.length];

                      final bool isVideo = !isImage;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: isVideo
                                    ? Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [AppThemeColors.primaryOrange.withValues(alpha: 0.8), AppThemeColors.primaryOrange],
                                          ),
                                        ),
                                        child: const Icon(Icons.play_circle_filled_rounded, color: AppThemeColors.white, size: 32),
                                      )
                                    : Image.file(File(file.path), height: 80, width: 80, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => isVideo ? controller.removeVideo(index - controller.selectedImages.length) : controller.removeImage(index),
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showMediaPickerOptions(controller),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: hasImages
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)],
                                )
                              : null,
                          color: hasImages ? null : AppThemeColors.bgCream,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: hasImages ? Colors.transparent : AppThemeColors.borderLight),
                          boxShadow: hasImages
                              ? [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Icon(Icons.camera_alt_rounded, color: hasImages ? AppThemeColors.white : AppThemeColors.greyText, size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppThemeColors.bgCream,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppThemeColors.borderLight),
                        ),
                        child: TextField(
                          controller: controller.messageController,
                          style: AppTextStyle.medium.copyWith(fontSize: 15, color: AppThemeColors.blackText),
                          decoration: InputDecoration(
                            hintText: hasImages ? "Add a caption..." : "Type your message...",
                            hintStyle: AppTextStyle.medium.copyWith(color: AppThemeColors.greyText, fontSize: 15),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: controller.isSending.value
                          ? null
                          : () {
                              if (controller.selectedImages.isNotEmpty || controller.selectedVideos.isNotEmpty) {
                                controller.sendMedia();
                              } else {
                                controller.sendMessage();
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppThemeColors.primaryOrange, Color(0xFFF28E65)],
                          ),
                          shape: BoxShape.circle,
                          // boxShadow: [BoxShadow(color: AppThemeColors.primaryOrange.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: controller.isSending.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String? _resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return "${AppNetworkConstants.baseURL}$url";
  }

  void _showMediaActions({required CommunityMessage message, required String? mediaUrl, required bool isVideo, required bool isMe}) {
    if (mediaUrl == null || mediaUrl.isEmpty) return;
    final ctrl = Get.find<CommunityChatCtrl>();
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppThemeColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text("Download"),
                onTap: () {
                  Get.back();
                  ctrl.downloadMediaFromUrl(url: mediaUrl, isVideo: isVideo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Get.back();
                  if (!isMe) {
                    warningToast("You can delete only your images/videos");
                    return;
                  }
                  if ((message.id ?? '').isEmpty) {
                    warningToast("Media id not found");
                    return;
                  }
                  ctrl.deleteMediaByIds([message.id!]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
