import '../../../../app_export.dart';

class EditProfileCtrl extends GetxController {
  final AuthenticationController authService = Get.find();

  late TextEditingController nameController;
  late TextEditingController emailController;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    await authService.fetchProfile();
    final userData = authService.userAuthData;
    nameController.text = userData['name'] ?? "";
    emailController.text = userData['email'] ?? "";
    isLoading.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void discardChanges() {
    Get.back();
  }

  Future<void> saveChanges() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      warningToast("Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;
      final body = {"name": nameController.text.trim(), "email": emailController.text.trim()};

      final response = await ApiManager.call(endPoint: BACKEND.profileUpdate, type: ApiType.put, body: body);

      if ((response.status == 1 || response.status == 200) && response.success == true) {
        // Update local data
        if (response.data != null && response.data['customer'] != null) {
          authService.userAuthData.assignAll(response.data['customer']);
        } else {
          authService.userAuthData.addAll(body);
        }
        successToast("Profile updated successfully");
        Get.back();
      } else {
        errorToast(response.message);
      }
    } catch (e) {
      errorToast("Unable to process your request right now, Please try again later.");
    } finally {
      isLoading.value = false;
    }
  }
}
