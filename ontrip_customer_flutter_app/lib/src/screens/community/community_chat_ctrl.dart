import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:gal/gal.dart';
import '../../../../../app_export.dart';

class CommunityChatCtrl extends GetxController {
  final Rxn<Community> community = Rxn<Community>();
  final RxList<CommunityMessage> messages = <CommunityMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<XFile> selectedVideos = <XFile>[].obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxnString coverImage = RxnString();
  final RxBool notificationEnabled = true.obs;
  var communityId;

  bool isVendorMode = false;
  String? currentBookingId;
  String? currentCustomerId;

  Timer? _messageTimer;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() async {
    super.onInit();
    await initCommunity();
    await listenForNewMessages();
    await connectToCommunity();
  }

  @override
  void onClose() {
    _messageTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> initCommunity() async {
    try {
      isLoading.value = true;

      final dynamic args = Get.arguments;
      String? packageId;
      bool isVendor = false;
      String? bookingId;
      String? customerId;

      if (args is Map) {
        isVendorMode = args["isVendor"] == true;
        if (isVendorMode) {
          currentBookingId = args["bookingId"];
          currentCustomerId = args["customerId"] ?? "";
          packageId = args["packageId"];
          coverImage.value = args["coverImage"];
        } else {
          packageId = args["packageId"];
          coverImage.value = args["coverImage"];
        }
      } else if (args is String) {
        packageId = args;
      }

      if (isVendorMode) {
        if (currentBookingId != null && currentBookingId!.isNotEmpty && currentCustomerId != null && currentCustomerId!.isNotEmpty) {
          await loadVendorChat();
          if (coverImage.value == null || coverImage.value!.isEmpty) {
            coverImage.value = community.value?.package?.coverImage;
          }
        } else {
          debugPrint('Vendor chat: missing bookingId or customerId');
        }
      } else {
        // Customer: existing flow
        if (packageId == null) {
          final homeCtrl = Get.find<HomeController>();
          if (homeCtrl.bookings.isEmpty) {
            await homeCtrl.fetchBookings();
          }
          if (homeCtrl.bookings.isNotEmpty) {
            final firstBooking = homeCtrl.bookings.first;
            packageId = firstBooking.package?.id;
            coverImage.value = firstBooking.package?.coverImage;
          }
        }
        if (packageId != null) {
          await fetchCommunityInfo(packageId);
          if (community.value != null) {
            await fetchNotificationPreference();
            await fetchMessages();
          }
        }
      }
    } catch (e) {
      debugPrint("Error initializing community: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// GET vendors/chat/{bookingId}?customerId= — loads community + messages
  Future<void> loadVendorChat({bool showLoading = true}) async {
    if (currentBookingId == null || currentCustomerId == null) return;

    try {
      if (showLoading) isLoading.value = true;
      final response = await ApiManager.call(endPoint: BACKEND.vendorChatGet(currentBookingId!, currentCustomerId!), type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);

        if (data['community'] != null) {
          final communityData = CommunityResponse.fromJson(data);
          community.value = communityData.community;
          communityId = community.value?.id;
        } else {
          _applyVendorChatContext(data);
        }

        _assignMessagesFromData(data);
      }
    } catch (e) {
      debugPrint("Error loading vendor chat: $e");
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void _applyVendorChatContext(Map<String, dynamic> data) {
    final bookingRaw = data['booking'];
    String? bookingRef;
    String? bookingLabel;
    if (bookingRaw is Map) {
      bookingRef = bookingRaw['_id']?.toString();
      bookingLabel = bookingRaw['bookingId']?.toString();
    } else {
      bookingRef = currentBookingId;
    }

    Map? customerRaw;
    final rawMessages = data['messages'];
    if (rawMessages is List && rawMessages.isNotEmpty && rawMessages.first is Map) {
      customerRaw = (rawMessages.first as Map)['customer'] as Map?;
    }
    final customerName = customerRaw is Map ? customerRaw['name']?.toString() : null;

    communityId = bookingRef ?? currentBookingId;
    community.value = Community(
      id: communityId,
      package: CommunityPackage(
        id: bookingRef,
        title: bookingLabel ?? customerName ?? 'Vendor Chat',
        destination: customerName,
      ),
      customerMembers: customerName != null
          ? [CustomerMember(id: currentCustomerId, name: customerName)]
          : null,
    );
  }

  void _assignMessagesFromData(Map<String, dynamic> data) {
    final raw = data['messages'];
    if (raw is! List) return;

    var newMsgs = raw
        .map((x) {
          if (x is! Map) return null;
          return CommunityMessage.fromJson(Map<String, dynamic>.from(x));
        })
        .whereType<CommunityMessage>()
        .toList();

    if (newMsgs.isNotEmpty && newMsgs.length > 1) {
      final firstTime = newMsgs.first.createdAt;
      final lastTime = newMsgs.last.createdAt;
      if (firstTime != null && lastTime != null && firstTime.isBefore(lastTime)) {
        newMsgs = newMsgs.reversed.toList();
      }
    }

    messages.assignAll(newMsgs);
    _scrollToBottom();
  }

  Future<void> listenForNewMessages() async {
    socketService.onNewMessage.listen((data) {
      log('--------------------socket data-------------------------');
      log(data.toString());

      // Handle both wrapped and unwrapped data
      final messageJson = data["data"] ?? data;

      try {
        final newMessage = CommunityMessage.fromJson(messageJson);

        final belongsToChat = isVendorMode
            ? newMessage.community == currentBookingId || newMessage.community == communityId
            : newMessage.community == community.value?.id;

        if (belongsToChat) {
          // Check for deduplication
          final alreadyExists = messages.any((msg) => msg.id == newMessage.id);

          if (!alreadyExists) {
            // Insert at 0 because we use reverse: true in ListView
            messages.insert(0, newMessage);
            _scrollToBottom();
          }
        }
      } catch (e) {
        debugPrint("Error parsing socket message: $e");
      }
    });
  }

  Future<void> connectToCommunity() async {
    final roomId = communityId?.toString() ?? (isVendorMode ? currentBookingId : null);
    if (roomId == null || roomId.isEmpty) return;
    socketService.emitEvent(roomId);
    // socketService.e((data) {
    //   data = data["data"];
    //   log('--------------------socket data-------------------------');
    //   log(data.toString());
    //   // if (data['orderId'] == order!.id) {
    //   //   int index = messages.indexWhere((e) => e.id == data["_id"]);
    //   //   if (index == -1) {
    //   //     messages.add(_ChatMessage(id: data["_id"], text: data['message'], isMe: false));
    //   //     log(messages.toJson().toString());
    //   //   }
    //   // }
    // });
  }
  // Future<void> initCommunity() async {
  //   try { 6a0fe6168dcf6ff188be0a9b
  //     isLoading.value = true;

  //     String? packageId = Get.arguments;

  //     if (packageId == null) {
  //       // Fallback: Get the latest booking to find the packageId
  //       final homeCtrl = Get.find<HomeController>();
  //       if (homeCtrl.bookings.isEmpty) {
  //         await homeCtrl.fetchBookings();
  //       }
  //       if (homeCtrl.bookings.isNotEmpty) {
  //         packageId = homeCtrl.bookings.first.package?.id;
  //       }
  //     }

  //     if (packageId != null) {
  //       await fetchCommunityInfo(packageId);
  //         if (community.value != null) {
  //           await fetchMessages();
  //           // Start polling for new messages every 5 seconds
  //           _messageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  //             fetchMessages(showLoading: false);
  //           });
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error initializing community: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }

  Future<void> fetchCommunityInfo(String packageId) async {
    try {
      final response = await ApiManager.call(endPoint: "${BACKEND.communityInfo}$packageId", type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        final communityData = CommunityResponse.fromJson(response.data);
        community.value = communityData.community;
      }
    } catch (e) {
      debugPrint("Error fetching community info: $e");
    }
  }

  Future<void> fetchMessages({bool showLoading = true}) async {
    if (isVendorMode) {
      await loadVendorChat(showLoading: showLoading);
      return;
    }

    if (community.value == null) return;

    try {
      if (showLoading) isLoading.value = true;
      communityId = community.value!.id;
      final response = await ApiManager.call(endPoint: "${BACKEND.communityMessages}${community.value!.id}/messages?limit=50&page=1", type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        final messagesData = MessagesResponse.fromJson(response.data);
        var newMsgs = messagesData.messages ?? [];

        // For a WhatsApp-like experience (reverse: true), we need the newest message at index 0
        // If the API returns chronological order (oldest first), we reverse it
        if (newMsgs.isNotEmpty && newMsgs.length > 1) {
          final firstTime = newMsgs.first.createdAt;
          final lastTime = newMsgs.last.createdAt;
          if (firstTime != null && lastTime != null && firstTime.isBefore(lastTime)) {
            newMsgs = newMsgs.reversed.toList();
          }
        }

        if (newMsgs.length != messages.length) {
          messages.assignAll(newMsgs);
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint("Error fetching messages: $e");
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> fetchNotificationPreference() async {
    if (community.value == null) return;
    try {
      final response = await ApiManager.call(endPoint: BACKEND.communityNotificationPreference(community.value!.id!), type: ApiType.get);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        notificationEnabled.value = response.data["notificationsEnabled"] ?? true;
      }
    } catch (e) {
      debugPrint("Error fetching notification preference: $e");
    }
  }

  Future<void> toggleNotificationPreference() async {
    if (community.value == null) return;
    try {
      final newValue = !notificationEnabled.value;
      final response = await ApiManager.call(
        endPoint: BACKEND.communityNotificationPreference(community.value!.id!),
        type: ApiType.patch,
        body: {"enabled": newValue},
      );

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        notificationEnabled.value = newValue;
        successToast("Notifications ${newValue ? 'enabled' : 'disabled'}");
      } else {
        errorToast("Failed to update notification preference");
      }
    } catch (e) {
      debugPrint("Error toggling notification preference: $e");
      errorToast("Something went wrong");
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    // if (content.isEmpty || community.value == null) return;
    if (content.isEmpty) return;
    if (isVendorMode) {
      if (currentBookingId == null || currentCustomerId == null) {
        warningToast('No booking chat found!');
        return;
      }
    } else if (community.value == null) {
      warningToast('No community chat found!');
      return;
    }
    try {
      isSending.value = true;
      communityId = community.value?.id;
      messageController.clear();

      dynamic response;
      if (isVendorMode) {
        final formData = dio.FormData.fromMap({'message': content, 'customerId': currentCustomerId});
        response = await ApiManager.call(endPoint: BACKEND.vendorChatPost(currentBookingId!), type: ApiType.post, body: formData);
      } else {
        response = await ApiManager.call(
          endPoint: "${BACKEND.communityMessages}${community.value!.id}/messages",
          type: ApiType.post,
          body: {"content": content},
        );
      }

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        await fetchMessages(showLoading: false);
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
      errorToast("Something went wrong");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickImages() async {
    final List<XFile> picked = await _picker.pickMultipleMedia(maxHeight: 80, maxWidth: 80, imageQuality: 80);
    if (picked.isEmpty) return;
    selectedImages.addAll(picked);
  }

  Future<void> pickMedia() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.media, allowMultiple: true, withData: true);

      if (result == null) return;

      for (final file in result.files) {
        if (file.path == null) continue;

        final xfile = XFile(file.path!);
        final ext = file.extension?.toLowerCase().trim();

        final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);

        if (isVideo) {
          selectedVideos.add(xfile);
        } else {
          selectedImages.add(xfile);
        }
      }

      if (selectedImages.isNotEmpty || selectedVideos.isNotEmpty) {
        // Optional: Show a small toast
        // successToast("${selectedImages.length} image(s) and ${selectedVideos.length} video(s) selected");
      }
    } catch (e) {
      debugPrint("Media pick error: $e");
      errorToast("Couldn't pick media. Please try again.");
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void removeVideo(int index) {
    if (index >= 0 && index < selectedVideos.length) {
      selectedVideos.removeAt(index);
    }
  }

  // Future<void> sendImages() async {

  //   if (selectedImages.isEmpty || community.value == null) return;
  //   final caption = messageController.text.trim();
  //   try {
  //     isSending.value = true;
  //     communityId = community.value!.id;
  //     messageController.clear();

  //     for (final xfile in List<XFile>.from(selectedImages)) {
  //       final formData = dio.FormData.fromMap({
  //         'media': await dio.MultipartFile.fromFile(xfile.path, filename: xfile.name),
  //         if (caption.isNotEmpty) 'caption': caption,
  //       });

  //       final response = await ApiManager.call(
  //         endPoint: "${BACKEND.communityMessages}${community.value!.id}/messages/image",
  //         type: ApiType.post,
  //         body: formData,
  //       );

  //       if (response.status != 200 && response.status != 1) {
  //         errorToast(response.message);
  //       }
  //     }

  //     selectedImages.clear();
  //     await fetchMessages(showLoading: false);
  //   } catch (e) {
  //     debugPrint("Error sending images: $e");
  //     errorToast("Failed to send image");
  //   } finally {
  //     isSending.value = false;
  //   }
  // }
  Future<void> sendMedia() async {
    if (selectedImages.isEmpty && selectedVideos.isEmpty) return;
    if (isVendorMode) {
      if (currentBookingId == null || currentCustomerId == null) {
        warningToast('No booking chat found!');
        return;
      }
    } else if (community.value == null) {
      warningToast('No community chat found!');
      return;
    }

    final caption = messageController.text.trim();

    try {
      isSending.value = true;
      messageController.clear();

      // Send all selected Images

      for (final xfile in List<XFile>.from(selectedImages)) {
        dynamic response;
        if (isVendorMode) {
          if (currentBookingId == null || currentCustomerId == null) return;
          final formData = dio.FormData.fromMap({
            'image': await dio.MultipartFile.fromFile(xfile.path, filename: xfile.name),
            'customerId': currentCustomerId,
            if (caption.isNotEmpty) 'message': caption,
          });
          response = await ApiManager.call(endPoint: BACKEND.vendorChatPost(currentBookingId!), type: ApiType.post, body: formData);
        } else {
          final formData = dio.FormData.fromMap({
            'media': await dio.MultipartFile.fromFile(xfile.path, filename: xfile.name),
            if (caption.isNotEmpty) 'caption': caption,
          });
          response = await ApiManager.call(endPoint: "${BACKEND.communityMessages}${community.value!.id}/messages/image", type: ApiType.post, body: formData);
        }

        if (response.status != 1 && response.status != 200) {
          errorToast(response.message);
        }
      }

      // Send all selected Videos

      for (final xfile in List<XFile>.from(selectedVideos)) {
        dynamic response;
        if (isVendorMode) {
          if (currentBookingId == null || currentCustomerId == null) return;
          final formData = dio.FormData.fromMap({
            'image': await dio.MultipartFile.fromFile(xfile.path, filename: xfile.name), // Videos sent as 'image' for vendor
            'customerId': currentCustomerId,
            if (caption.isNotEmpty) 'message': caption,
          });
          response = await ApiManager.call(endPoint: BACKEND.vendorChatPost(currentBookingId!), type: ApiType.post, body: formData);
        } else {
          final formData = dio.FormData.fromMap({
            'media': await dio.MultipartFile.fromFile(xfile.path, filename: xfile.name),
            if (caption.isNotEmpty) 'caption': caption,
          });
          response = await ApiManager.call(endPoint: "${BACKEND.communityMessages}${community.value!.id}/messages/image", type: ApiType.post, body: formData);
        }

        if (response.status != 1 && response.status != 200) {
          errorToast(response.message);
        }
      }

      // Clear selections after successful upload
      selectedImages.clear();
      selectedVideos.clear();

      await fetchMessages(showLoading: false);
      successToast("Media sent successfully");
    } catch (e) {
      debugPrint("Error sending media: $e");
      errorToast("Failed to send media");
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          0, // With reverse: true, 0 is the bottom (latest message)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String? _resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    return "${AppNetworkConstants.baseURL}$trimmed";
  }

  Future<void> downloadMediaFromUrl({required String? url, required bool isVideo}) async {
    final resolved = _resolveMediaUrl(url);
    if (resolved == null) {
      warningToast("Media URL not available");
      return;
    }

    final granted = await _ensureMediaPermissions();
    if (!granted) {
      warningToast("Storage permission denied");
      return;
    }

    final downloader = dio.Dio();
    try {
      if (isVideo) {
        final ext = _videoExtension(resolved);
        final tempFile = File("${Directory.systemTemp.path}/ontrip_${DateTime.now().microsecondsSinceEpoch}.$ext");
        await downloader.download(resolved, tempFile.path);
        await Gal.putVideo(tempFile.path, album: "OnTrip");
        if (await tempFile.exists()) await tempFile.delete();
      } else {
        final response = await downloader.get<List<int>>(resolved, options: dio.Options(responseType: dio.ResponseType.bytes));
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          errorToast("Failed to download image");
          return;
        }
        await Gal.putImageBytes(Uint8List.fromList(bytes), album: "OnTrip");
      }
      successToast("Downloaded successfully");
    } catch (e) {
      debugPrint("Download media failed: $e");
      errorToast("Failed to download media");
    }
  }

  Future<void> deleteMediaByIds(List<String> imageIds) async {
    final communityIdValue = community.value?.id;
    if (communityIdValue == null) return;

    final ids = imageIds.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) return;

    try {
      final response = await ApiManager.call(endPoint: BACKEND.communityBulkDeleteImages(communityIdValue), type: ApiType.delete, body: {"imageIds": ids});

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        messages.removeWhere((m) => ids.contains(m.id));
        successToast("Deleted successfully");
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      debugPrint("Delete media failed: $e");
      errorToast("Failed to delete media");
    }
  }

  String _videoExtension(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    if (path.endsWith('.mov')) return 'mov';
    if (path.endsWith('.avi')) return 'avi';
    if (path.endsWith('.mkv')) return 'mkv';
    if (path.endsWith('.webm')) return 'webm';
    return 'mp4';
  }

  Future<bool> _ensureMediaPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        return photos.isGranted || videos.isGranted;
      }
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    if (Platform.isIOS) {
      final photos = await Permission.photosAddOnly.request();
      return photos.isGranted || photos.isLimited;
    }
    return true;
  }
}
