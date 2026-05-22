import 'dart:async';
import 'dart:developer';
import '../../../../../app_export.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  String token = "";

  final RxList<Booking> bookings = <Booking>[].obs;
  final RxInt carouselIndex = 0.obs;

  // Booking Details Integration
  final Rxn<Booking> selectedBooking = Rxn<Booking>();
  final RxInt selectedTab = 0.obs;
  final RxInt selectedDay = 0.obs;
  final Rxn<ReviewResponse> reviewResponse = Rxn<ReviewResponse>();
  final Rxn<Review> userReview = Rxn<Review>();

  // Review Submission State
  final RxDouble userRating = 0.0.obs;
  final TextEditingController reviewCommentCtrl = TextEditingController();
  final RxBool isReviewLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Only auto-fetch if a token already exists (returning user / app restart).
    // On fresh login, initialize() is called explicitly from verify_otp_ctrl.
    final token = getStorage(AppSession.token);
    if (token != null && token.toString().isNotEmpty) {
      initialize();
    }
  }

  Future<void> initialize() async {
    try {
      isLoading = true;
      update();
      token = getStorage(AppSession.token) ?? "";
      await Future.wait([
        fetchBookings(),
        Get.find<AuthenticationController>().fetchProfile(),
      ]);
      _loadLastViewedBooking();
    } finally {
      isLoading = false;
      update();
    }
  }

  void _loadLastViewedBooking() {
    final lastId = GetStorage().read('last_viewed_booking_id');
    if (lastId != null) {
      final lastBooking = bookings.firstWhereOrNull(
        (b) => b.bookingId == lastId,
      );
      if (lastBooking != null) {
        setBooking(lastBooking);
        return;
      }
    }
    if (bookings.isNotEmpty) {
      setBooking(bookings.first);
    }
  }

  void setBooking(Booking booking) async {
    selectedBooking.value = booking;
    await GetStorage().write('last_viewed_booking_id', booking.bookingId);
    await fetchReviews(booking.package?.id);
    await fetchUserReview(booking.bookingId);
    update();
  }

  Future<void> fetchUserReview(String? bookingId) async {
    if (bookingId == null) return;
    try {
      final response = await ApiManager.call(
        endPoint: BACKEND.bookingReview(bookingId),
        type: ApiType.get,
      );

      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        if (response.data["review"] != null) {
          userReview.value = Review.fromJson(response.data["review"]);
          userRating.value = userReview.value?.packageRating ?? 0.0;
          reviewCommentCtrl.text = userReview.value?.comment ?? "";
        } else {
          userReview.value = null;
          userRating.value = 0.0;
          reviewCommentCtrl.text = "";
        }
      }
    } catch (e) {
      debugPrint("Error fetching user review: $e");
    } finally {
      update();
    }
  }

  Future<void> submitReview() async {
    final bookingId = selectedBooking.value?.bookingId;
    if (bookingId == null) return;

    if (userRating.value == 0) {
      warningToast("Please select a rating");
      return;
    }

    try {
      isReviewLoading.value = true;
      update();
      final response = await ApiManager.call(
        endPoint: BACKEND.bookingReview(bookingId),
        type: ApiType.post,
        body: {
          "packageRating": userRating.value,
          "overallRating": userRating.value,
          "comment": reviewCommentCtrl.text.trim(),
        },
      );

      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        successToast("Review submitted successfully");
        fetchUserReview(bookingId);
        fetchReviews(selectedBooking.value?.package?.id);
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
    } finally {
      reviewCommentCtrl.clear();
      userRating.value = 0.0;
      isReviewLoading.value = false;
      update();
    }
  }

  Future<void> fetchBookings() async {
    try {
      final response = await ApiManager.call(
        endPoint: BACKEND.bookings,
        type: ApiType.get,
      );
      log('=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
      log(response.status.toString());
      log(response.data.toString());
      if ((response.status == 1 || response.status == 200) &&
          response.success == true &&
          response.data != null) {
        final bookingData = BookingResponseData.fromJson(response.data);
        log('=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=');
        log(bookingData.bookings.toString());
        bookings.assignAll(bookingData.bookings ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
    }
  }

  void onDayChange(int index) {
    selectedDay.value = index;
    update();
  }

  Future<void> fetchReviews(String? packageId) async {
    if (packageId == null) return;
    try {
      final response = await ApiManager.call(
        endPoint: "${BACKEND.packageReviews(packageId)}?page=1&limit=5",
        type: ApiType.get,
      );
      if ((response.status == 1 || response.status == 200) &&
          response.success == true) {
        reviewResponse.value = ReviewResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    }
  }

  void callVendor(String? phone) {
    if (phone != null && phone.isNotEmpty) {
      AppUrl.call("tel:$phone", mobile: phone);
    } else {
      warningToast("Contact number not available");
    }
  }
}
