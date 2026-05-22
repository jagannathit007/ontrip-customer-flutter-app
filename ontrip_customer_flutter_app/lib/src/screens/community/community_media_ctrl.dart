import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:gal/gal.dart';
import '../../../../../app_export.dart';

class CommunityMediaCtrl extends GetxController {
  static const String _communityMediaBaseUrl =
      'https://nh422t96-8000.inc1.devtunnels.ms';
  final RxList<CommunityImage> images = <CommunityImage>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  // Tab control
  final RxInt selectedTabIndex = 0.obs;

  // Face Matching State
  final Rx<FaceStatus> faceStatus = FaceStatus.initial.obs;
  final RxList<CommunityImage> matchedImages = <CommunityImage>[].obs;
  final RxBool selectionMode = false.obs;
  final RxList<String> selectedMediaIds = <String>[].obs;

  late String communityId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      communityId = args;
    } else {
      communityId = "";
    }

    if (communityId.isNotEmpty) {
      fetchImages();
    }
  }

  Future<void> fetchImages({bool refresh = false}) async {
    if (communityId.isEmpty) return;

    if (refresh) {
      currentPage.value = 1;
    }

    try {
      isLoading.value = true;
      final response = await ApiManager.call(
        endPoint:
            "${BACKEND.communityImages(communityId)}?page=${currentPage.value}&limit=30",
        type: ApiType.get,
      );

      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        final mediaData = CommunityMediaResponse.fromJson(response.data);
        if (mediaData.images != null) {
          if (refresh) {
            images.assignAll(mediaData.images!);
          } else {
            images.addAll(mediaData.images!);
          }
        }
        if (mediaData.pagination != null) {
          totalPages.value = mediaData.pagination!.totalPages ?? 1;
        }
      }
    } catch (e) {
      debugPrint("Error fetching community images: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      currentPage.value++;
      fetchImages();
    }
  }

  void switchTab(int index) {
    selectedTabIndex.value = index;
    if (index == 1 && faceStatus.value == FaceStatus.initial) {
      checkFaceMatches();
    }
  }

  Future<void> checkFaceMatches() async {
    // This is typically called API checking if faces are already matched.
    // If not, we set it to initial or noMatches so User can capture new selfie.
    try {
      faceStatus.value = FaceStatus.loading;
      // Mock API call or integrate real API if available
      await Future.delayed(const Duration(seconds: 1));

      // Since we don't have the real endpoint, let's mock it to 'noMatches' by default
      // to allow users to trigger the SelfieUI.
      // If there was an endpoint:
      // final res = await ApiManager.call(endPoint: '...', type: ApiType.get);

      faceStatus.value = FaceStatus.noMatches;
    } catch (e) {
      faceStatus.value = FaceStatus.error;
    }
  }

  Future<void> findMyPhotos({required File selfie}) async {
    try {
      faceStatus.value = FaceStatus.loading;
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          selfie.path,
          filename: selfie.path.split('/').last,
        ),
        'group_id': communityId,
        'threshold': '0.50',
      });

      final response = await ApiManager.call(
        endPoint: '$_communityMediaBaseUrl/guest/find-my-photos',
        type: ApiType.post,
        body: formData,
      );

      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        final List<CommunityImage> foundImages = _parseMatchedImages(
          response.data,
        );
        matchedImages.assignAll(foundImages);
        faceStatus.value = foundImages.isEmpty
            ? FaceStatus.noMatches
            : FaceStatus.hasMatches;
      } else {
        matchedImages.clear();
        faceStatus.value = FaceStatus.noMatches;
        errorToast(response.message);
      }
    } catch (e) {
      matchedImages.clear();
      faceStatus.value = FaceStatus.error;
      debugPrint("Error finding community photos: $e");
    }
  }

  void toggleSelectionMode([bool enabled = false]) {
    selectionMode.value = enabled;
    if (!enabled) {
      selectedMediaIds.clear();
    }
  }

  void toggleMediaSelection(CommunityImage media) {
    final id = media.id;
    if (id == null || id.isEmpty) return;
    if (selectedMediaIds.contains(id)) {
      selectedMediaIds.remove(id);
    } else {
      selectedMediaIds.add(id);
    }
    if (selectedMediaIds.isEmpty) {
      selectionMode.value = false;
    } else {
      selectionMode.value = true;
    }
  }

  bool isSelected(String? mediaId) =>
      mediaId != null && selectedMediaIds.contains(mediaId);

  List<CommunityImage> get _allMediaItems {
    final byId = <String, CommunityImage>{};
    for (final item in images) {
      if ((item.id ?? '').isNotEmpty) byId[item.id!] = item;
    }
    for (final item in matchedImages) {
      if ((item.id ?? '').isNotEmpty) byId[item.id!] = item;
    }
    return byId.values.toList();
  }

  List<CommunityImage> get selectedMediaItems =>
      _allMediaItems.where((e) => selectedMediaIds.contains(e.id)).toList();

  String? resolveMediaUrl(CommunityImage media) {
    final raw =
        (media.videoUrl?.trim().isNotEmpty == true
                ? media.videoUrl
                : media.imageUrl)
            ?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return "${AppNetworkConstants.baseURL}$raw";
  }

  bool isVideoMedia(CommunityImage media) {
    final url = resolveMediaUrl(media);
    if (url == null) return false;
    final normalized = url.toLowerCase();
    final path = Uri.tryParse(normalized)?.path.toLowerCase() ?? normalized;
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm') ||
        path.endsWith('.m4v');
  }

  Future<void> downloadMediaItems(List<CommunityImage> items) async {
    if (items.isEmpty) return;
    final granted = await _ensureMediaPermissions();
    if (!granted) {
      warningToast("Storage permission denied");
      return;
    }

    final downloader = dio.Dio();
    int success = 0;
    for (final media in items) {
      final url = resolveMediaUrl(media);
      if (url == null) continue;
      try {
        if (isVideoMedia(media)) {
          final tempFile = File(
            "${Directory.systemTemp.path}/ontrip_${DateTime.now().microsecondsSinceEpoch}.mp4",
          );
          await downloader.download(url, tempFile.path);
          await Gal.putVideo(tempFile.path, album: "OnTrip");
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } else {
          final response = await downloader.get<List<int>>(
            url,
            options: dio.Options(responseType: dio.ResponseType.bytes),
          );
          if (response.data == null) continue;
          await Gal.putImageBytes(
            Uint8List.fromList(response.data!),
            album: "OnTrip",
          );
        }
        success++;
      } catch (e) {
        debugPrint("Download failed for media ${media.id}: $e");
      }
    }

    if (success > 0) {
      successToast("$success media file(s) downloaded");
    } else {
      errorToast("Failed to download media");
    }
  }

  Future<void> downloadSelectedMedia() async {
    await downloadMediaItems(selectedMediaItems);
  }

  Future<void> deleteSelectedMedia() async {
    final selectedItems = selectedMediaItems;
    if (selectedItems.isEmpty) return;

    final ownIds = <String>[];
    final otherCount = <String>[];
    for (final item in selectedItems) {
      final id = item.id;
      if (id == null || id.isEmpty) continue;
      if (isOwnMedia(item)) {
        ownIds.add(id);
      } else {
        otherCount.add(id);
      }
    }

    if (ownIds.isEmpty) {
      warningToast("You can delete only your images/videos");
      return;
    }

    await deleteMediaByIds(ownIds);
    if (otherCount.isNotEmpty) {
      warningToast(
        "Some selected items were skipped. You can delete only your images/videos",
      );
    }
  }

  Future<void> deleteMediaByIds(List<String> ids) async {
    final cleaned = ids.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (cleaned.isEmpty || communityId.isEmpty) return;
    try {
      final response = await ApiManager.call(
        endPoint: BACKEND.communityBulkDeleteImages(communityId),
        type: ApiType.delete,
        body: {'imageIds': cleaned},
      );

      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        images.removeWhere((e) => cleaned.contains(e.id));
        matchedImages.removeWhere((e) => cleaned.contains(e.id));
        selectedMediaIds.removeWhere((e) => cleaned.contains(e));
        if (selectedMediaIds.isEmpty) selectionMode.value = false;
        successToast("Deleted successfully");
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      debugPrint("Bulk delete failed: $e");
      errorToast("Failed to delete selected media");
    }
  }

  bool isOwnMedia(CommunityImage media) {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return false;
    return media.customer == userId || media.uploader?.id == userId;
  }

  String? get _currentUserId {
    try {
      final authCtrl = Get.find<AuthenticationController>();
      final data = authCtrl.userAuthData;
      if (data["_id"] != null) {
        return data["_id"].toString();
      }
      return null;
    } catch (_) {
      return null;
    }
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

  List<CommunityImage> _parseMatchedImages(dynamic data) {
    final rawList = <dynamic>[];

    if (data is List) {
      rawList.addAll(data);
    } else if (data is Map<String, dynamic>) {
      final candidates = [
        data['images'],
        data['matchedImages'],
        data['photos'],
        data['results'],
        data['matches'],
        data['data'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          rawList.addAll(candidate);
          break;
        }
      }
    }

    return rawList
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          map['community'] ??= communityId;
          map['imageUrl'] ??=
              map['url'] ?? map['image'] ?? map['file'] ?? map['path'];
          return CommunityImage.fromJson(map);
        })
        .where((image) => (image.imageUrl ?? '').isNotEmpty)
        .toList();
  }
}

enum FaceStatus { initial, loading, hasMatches, noMatches, error }
