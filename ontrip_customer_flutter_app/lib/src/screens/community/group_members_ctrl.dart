import '../../../../../app_export.dart';

class GroupMembersCtrl extends GetxController {
  late Rxn<Community> community;
  final RxBool allTravelersCanSend = false.obs;
  final RxList<String> allowList = <String>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Receive Community object from arguments
    final Community? arg = Get.arguments;
    community = Rxn<Community>(arg);
    if (arg != null) {
      allTravelersCanSend.value = arg.travelerCanSendGlobally ?? false;
      allowList.assignAll(arg.travelerSendAllowList ?? []);
    }
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<AgentMember> get filteredAgents {
    final agents = community.value?.agentMembers ?? [];
    if (searchQuery.value.isEmpty) return agents;
    return agents
        .where(
          (a) =>
              (a.name?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (a.email?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (a.phone?.toLowerCase().contains(searchQuery.value) ?? false),
        )
        .toList();
  }

  List<CustomerMember> get filteredCustomers {
    final customers = community.value?.customerMembers ?? [];
    if (searchQuery.value.isEmpty) return customers;
    return customers
        .where(
          (c) =>
              (c.name?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (c.email?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (c.phone?.toLowerCase().contains(searchQuery.value) ?? false),
        )
        .toList();
  }

  List<VendorMember> get filteredVendors {
    final vendors = community.value?.vendorMembers ?? [];
    if (searchQuery.value.isEmpty) return vendors;
    return vendors
        .where(
          (v) =>
              (v.name?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (v.email?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (v.phone?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (v.contactPerson?.toLowerCase().contains(searchQuery.value) ?? false) ||
              (v.type?.toLowerCase().contains(searchQuery.value) ?? false),
        )
        .toList();
  }

  bool canTravelerSend(String? travelerId) {
    if (allTravelersCanSend.value) return true;
    return allowList.contains(travelerId);
  }

  Future<void> toggleGlobal(bool val) async {
    allTravelersCanSend.value = val;
    await _sendPatch(travelersCanSendGlobally: val, allowList: val ? [] : allowList.toList());
  }

  Future<void> toggleTraveler(CustomerMember member) async {
    final id = member.id;
    if (id == null) return;
    if (allowList.contains(id)) {
      allowList.remove(id);
    } else {
      allowList.add(id);
    }
    await _sendPatch(travelersCanSendGlobally: false, allowList: allowList.toList());
    // Keep global off since we're managing individual permissions
    allTravelersCanSend.value = false;
  }

  Future<void> _sendPatch({required bool travelersCanSendGlobally, required List<String> allowList}) async {
    final communityId = community.value?.id;
    if (communityId == null) return;
    try {
      isUpdating.value = true;
      final response = await ApiManager.call(
        endPoint: "${BACKEND.communityMessages}$communityId${BACKEND.communityMessaging}",
        type: ApiType.patch,
        body: {"travelersCanSendGlobally": travelersCanSendGlobally, "travelerSendDenyList": [], "travelerSendAllowList": allowList},
      );
      if (response.status != 1 && response.status != 200) {
        errorToast(response.message);
      }
    } catch (e) {
      debugPrint("Error updating traveler messaging: $e");
      errorToast("Unable to process your request right now, Please try again later.");
    } finally {
      isUpdating.value = false;
    }
  }
}
