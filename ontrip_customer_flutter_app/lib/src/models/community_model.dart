class CommunityResponse {
  final Community? community;
  final bool? canSendMessages;

  CommunityResponse({this.community, this.canSendMessages});

  factory CommunityResponse.fromJson(Map<String, dynamic> json) =>
      CommunityResponse(community: json["community"] == null ? null : Community.fromJson(json["community"]), canSendMessages: json["canSendMessages"]);
}

class Community {
  final String? id;
  final CommunityPackage? package;
  final List<AgentMember>? agentMembers;
  final List<CustomerMember>? customerMembers;
  final List<VendorMember>? vendorMembers;
  final bool? travelerCanSendGlobally;
  final List<String>? travelerSendDenyList;
  final List<String>? travelerSendAllowList;
  final bool? isActive;
  final DateTime? createdAt;

  Community({
    this.id,
    this.package,
    this.agentMembers,
    this.customerMembers,
    this.vendorMembers,
    this.travelerCanSendGlobally,
    this.travelerSendDenyList,
    this.travelerSendAllowList,
    this.isActive,
    this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) => Community(
    id: json["_id"],
    package: json["package"] == null ? null : CommunityPackage.fromJson(json["package"]),
    agentMembers: json["agentMembers"] == null ? null : List<AgentMember>.from(json["agentMembers"].map((x) => AgentMember.fromJson(x))),
    customerMembers: json["customerMembers"] == null ? null : List<CustomerMember>.from(json["customerMembers"].map((x) => CustomerMember.fromJson(x))),
    vendorMembers: json["vendorMembers"] == null ? null : List<VendorMember>.from(json["vendorMembers"].map((x) => VendorMember.fromJson(x))),
    travelerCanSendGlobally: json["travelersCanSendGlobally"] ?? json["travelerCanSendGlobally"],
    travelerSendDenyList: json["travelerSendDenyList"] == null ? null : List<String>.from(json["travelerSendDenyList"].map((x) => x)),
    travelerSendAllowList: json["travelerSendAllowList"] == null ? null : List<String>.from(json["travelerSendAllowList"].map((x) => x)),
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );
}

class CommunityPackage {
  final String? id;
  final String? title;
  final String? destination;
  final String? coverImage;

  CommunityPackage({this.id, this.title, this.destination, this.coverImage});

  factory CommunityPackage.fromJson(Map<String, dynamic> json) =>
      CommunityPackage(id: json["_id"], title: json["title"], destination: json["destination"], coverImage: json["coverImage"]);
}

class AgentMember {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final String? phone;

  AgentMember({this.id, this.name, this.email, this.role, this.phone});

  factory AgentMember.fromJson(Map<String, dynamic> json) =>
      AgentMember(id: json["_id"], name: json["name"], email: json["email"], role: json["role"], phone: json["phone"]);
}

class CustomerMember {
  final String? id;
  final String? phone;
  final String? name;
  final String? email;

  CustomerMember({this.id, this.phone, this.name, this.email});

  factory CustomerMember.fromJson(Map<String, dynamic> json) => CustomerMember(id: json["_id"], phone: json["phone"], name: json["name"], email: json["email"]);
}

class VendorMember {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? contactPerson;
  final String? type;

  VendorMember({this.id, this.name, this.email, this.phone, this.contactPerson, this.type});

  factory VendorMember.fromJson(Map<String, dynamic> json) => VendorMember(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    contactPerson: json["contactPerson"],
    type: json["type"],
  );
}

class MessagesResponse {
  final List<CommunityMessage>? messages;

  MessagesResponse({this.messages});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      MessagesResponse(messages: json["messages"] == null ? null : List<CommunityMessage>.from(json["messages"].map((x) => CommunityMessage.fromJson(x))));
}

class CommunityMessage {
  final String? id;
  final String? community;
  final String? senderType;
  final dynamic sender;
  final String? type;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime? createdAt;

  CommunityMessage({this.id, this.community, this.senderType, this.sender, this.type, this.content, this.imageUrl, this.videoUrl, this.createdAt});

  factory CommunityMessage.fromJson(Map<String, dynamic> json) {
    final booking = json["booking"];
    final communityId = json["community"]?.toString() ?? (booking is Map ? booking["_id"]?.toString() : booking?.toString());

    dynamic sender = json["sender"];
    final senderType = json["senderType"]?.toString();
    if (sender == null) {
      if (senderType == "Vendor" && json["vendor"] is Map) {
        sender = json["vendor"];
      } else if (json["customer"] is Map) {
        sender = json["customer"];
      } else if (json["senderId"] != null) {
        sender = {"_id": json["senderId"].toString(), "name": senderType ?? "User"};
      }
    }

    return CommunityMessage(
      id: json["_id"],
      community: communityId,
      senderType: senderType,
      sender: sender,
      type: json["type"] ?? "text",
      content: json["content"] ?? json["message"],
      imageUrl: json["imageUrl"] ?? json["image"],
      videoUrl: json["videoUrl"] ?? json["video"],
      createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );
  }

  String get senderName {
    if (sender is Map) {
      return sender["name"]?.toString() ?? "Unknown";
    }
    return "Unknown";
  }

  String? get senderId {
    if (sender is Map) return sender["_id"]?.toString();
    return sender?.toString();
  }
}

class CommunityMediaResponse {
  final List<CommunityImage>? images;
  final CommunityPagination? pagination;

  CommunityMediaResponse({this.images, this.pagination});

  factory CommunityMediaResponse.fromJson(Map<String, dynamic> json) => CommunityMediaResponse(
    images: json["images"] == null ? null : List<CommunityImage>.from(json["images"].map((x) => CommunityImage.fromJson(x))),
    pagination: json["pagination"] == null ? null : CommunityPagination.fromJson(json["pagination"]),
  );
}

class CommunityImage {
  final String? id;
  final String? community;
  final String? package;
  final String? uploaderType;
  final Uploader? uploader;
  final String? customer;
  final String? imageUrl;
  final String? videoUrl;
  final String? caption;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommunityImage({
    this.id,
    this.community,
    this.package,
    this.uploaderType,
    this.uploader,
    this.customer,
    this.imageUrl,
    this.videoUrl,
    this.caption,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory CommunityImage.fromJson(Map<String, dynamic> json) => CommunityImage(
    id: json["_id"],
    community: json["community"],
    package: json["package"],
    uploaderType: json["uploaderType"],
    uploader: json["uploader"] == null ? null : Uploader.fromJson(json["uploader"]),
    customer: json["customer"],
    imageUrl: json["imageUrl"],
    videoUrl: json["videoUrl"],
    caption: json["caption"],
    message: json["message"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );
}

class Uploader {
  final String? id;
  final String? phone;
  final String? name;

  Uploader({this.id, this.phone, this.name});

  factory Uploader.fromJson(Map<String, dynamic> json) => Uploader(id: json["_id"], phone: json["phone"], name: json["name"]);
}

class CommunityPagination {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  CommunityPagination({this.page, this.limit, this.total, this.totalPages});

  factory CommunityPagination.fromJson(Map<String, dynamic> json) =>
      CommunityPagination(page: json["page"], limit: json["limit"], total: json["total"], totalPages: json["totalPages"]);
}
