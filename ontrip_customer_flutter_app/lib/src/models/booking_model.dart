class BookingResponseData {
  final List<Booking>? bookings;
  final Pagination? pagination;

  BookingResponseData({this.bookings, this.pagination});

  factory BookingResponseData.fromJson(dynamic json) {
    if (json is! Map) return BookingResponseData();
    final map = Map<String, dynamic>.from(json);
    return BookingResponseData(
      bookings: map["bookings"] == null
          ? null
          : List<Booking>.from(
              (map["bookings"] as List).map(
                (x) => Booking.fromJson(x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{}),
              ),
            ),
      pagination: map["pagination"] == null
          ? null
          : Pagination.fromJson(
              map["pagination"] is Map ? Map<String, dynamic>.from(map["pagination"]) : <String, dynamic>{},
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "bookings": bookings == null ? null : List<dynamic>.from(bookings!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Booking {
  final String? id;
  final String? bookingId;
  final Package? package;
  final WhitelabelPackage? whitelabelPackage;
  final dynamic bookedBy;
  final Customer? customer;
  final AgencyCustomer? agencyCustomer;
  final List<Traveler>? travelers;
  final int? travelerCount;
  final DateTime? travelDate;
  final int? totalAmount;
  final String? paymentStatus;
  final String? bookingStatus;
  final int? currentDay;
  final List<Ticket>? tickets;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    this.bookingId,
    this.package,
    this.whitelabelPackage,
    this.bookedBy,
    this.customer,
    this.agencyCustomer,
    this.travelers,
    this.travelerCount,
    this.travelDate,
    this.totalAmount,
    this.paymentStatus,
    this.bookingStatus,
    this.currentDay,
    this.tickets,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json["_id"],
    bookingId: json["bookingId"],
    package: json["package"] == null
        ? null
        : json["package"] is Map
            ? Package.fromJson(Map<String, dynamic>.from(json["package"]))
            : Package(id: json["package"].toString()),
    whitelabelPackage: json["whitelabelPackage"] == null
        ? null
        : json["whitelabelPackage"] is Map
            ? WhitelabelPackage.fromJson(Map<String, dynamic>.from(json["whitelabelPackage"]))
            : WhitelabelPackage(id: json["whitelabelPackage"].toString()),
    bookedBy: json["bookedBy"],
    customer: json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    agencyCustomer: json["agencyCustomer"] == null ? null : AgencyCustomer.fromJson(json["agencyCustomer"]),
    travelers: json["travelers"] == null
        ? null
        : List<Traveler>.from(
            (json["travelers"] as List).map(
              (x) => Traveler.fromJson(x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{}),
            ),
          ),
    travelerCount: json["travelerCount"] is int ? json["travelerCount"] : (json["travelerCount"] as double?)?.toInt(),
    travelDate: json["travelDate"] == null ? null : DateTime.parse(json["travelDate"]),
    totalAmount: json["totalAmount"] is int ? json["totalAmount"] : (json["totalAmount"] as double?)?.toInt(),
    paymentStatus: json["paymentStatus"],
    bookingStatus: json["bookingStatus"],
    currentDay: json["currentDay"] is int ? json["currentDay"] : (json["currentDay"] as double?)?.toInt(),
    tickets: json["tickets"] == null ? null : List<Ticket>.from(json["tickets"].map((x) => Ticket.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "bookingId": bookingId,
    "package": package?.toJson(),
    "whitelabelPackage": whitelabelPackage?.toJson(),
    "bookedBy": bookedBy,
    "customer": customer?.toJson(),
    "agencyCustomer": agencyCustomer?.toJson(),
    "travelers": travelers == null ? null : List<dynamic>.from(travelers!.map((x) => x.toJson())),
    "travelerCount": travelerCount,
    "travelDate": travelDate?.toIso8601String(),
    "totalAmount": totalAmount,
    "paymentStatus": paymentStatus,
    "bookingStatus": bookingStatus,
    "currentDay": currentDay,
    "tickets": tickets == null ? null : List<dynamic>.from(tickets!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class AgencyCustomer {
  final AgencyCustomerDocs? docs;
  final String? id;
  final String? customer;
  final String? managedBy;
  final String? name;
  final String? email;
  final String? phone;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgencyCustomer({this.docs, this.id, this.customer, this.managedBy, this.name, this.email, this.phone, this.isActive, this.createdAt, this.updatedAt});

  factory AgencyCustomer.fromJson(Map<String, dynamic> json) => AgencyCustomer(
    docs: json["docs"] == null ? null : AgencyCustomerDocs.fromJson(json["docs"]),
    id: json["_id"],
    customer: json["customer"],
    managedBy: json["managedBy"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "docs": docs?.toJson(),
    "_id": id,
    "customer": customer,
    "managedBy": managedBy,
    "name": name,
    "email": email,
    "phone": phone,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class AgencyCustomerDocs {
  final List<String>? otherDocs;
  final String? aadharFront;
  final String? aadharBack;
  final String? panCard;
  final String? passport;
  final String? visaDoc;

  AgencyCustomerDocs({this.otherDocs, this.aadharFront, this.aadharBack, this.panCard, this.passport, this.visaDoc});

  factory AgencyCustomerDocs.fromJson(Map<String, dynamic> json) => AgencyCustomerDocs(
    otherDocs: json["otherDocs"] == null ? null : List<String>.from(json["otherDocs"].map((x) => x)),
    aadharFront: json["aadharFront"],
    aadharBack: json["aadharBack"],
    panCard: json["panCard"],
    passport: json["passport"],
    visaDoc: json["visaDoc"],
  );

  Map<String, dynamic> toJson() => {
    "otherDocs": otherDocs,
    "aadharFront": aadharFront,
    "aadharBack": aadharBack,
    "panCard": panCard,
    "passport": passport,
    "visaDoc": visaDoc,
  };
}

class Customer {
  final String? id;
  final String? phone;
  final String? name;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({this.id, this.phone, this.name, this.email, this.createdAt, this.updatedAt});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"],
    phone: json["phone"],
    name: json["name"],
    email: json["email"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone": phone,
    "name": name,
    "email": email,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Package {
  final String? id;
  final String? createdBy;
  final String? title;
  final String? description;
  final String? destination;
  final List<String>? images;
  final int? totalDays;
  final int? basePrice;
  final String? currency;
  final int? maxCapacity;
  final List<Itinerary>? itinerary;
  final List<String>? inclusions;
  final List<dynamic>? exclusions;
  final List<dynamic>? importantNotes;
  final String? status;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? coverImage;

  Package({
    this.id,
    this.createdBy,
    this.title,
    this.description,
    this.destination,
    this.images,
    this.totalDays,
    this.basePrice,
    this.currency,
    this.maxCapacity,
    this.itinerary,
    this.inclusions,
    this.exclusions,
    this.importantNotes,
    this.status,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.coverImage,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["_id"],
    createdBy: json["createdBy"],
    title: json["title"],
    description: json["description"],
    destination: json["destination"],
    images: json["images"] == null ? null : List<String>.from(json["images"].map((x) => x)),
    totalDays: json["totalDays"] is int ? json["totalDays"] : (json["totalDays"] as double?)?.toInt(),
    basePrice: json["basePrice"] is int ? json["basePrice"] : (json["basePrice"] as double?)?.toInt(),
    currency: json["currency"],
    maxCapacity: json["maxCapacity"] is int ? json["maxCapacity"] : (json["maxCapacity"] as double?)?.toInt(),
    itinerary: json["itinerary"] == null ? null : List<Itinerary>.from(json["itinerary"].map((x) => Itinerary.fromJson(x))),
    inclusions: json["inclusions"] == null ? null : List<String>.from(json["inclusions"].map((x) => x)),
    exclusions: json["exclusions"] == null ? null : List<dynamic>.from(json["exclusions"].map((x) => x)),
    importantNotes: json["importantNotes"] == null ? null : List<dynamic>.from(json["importantNotes"].map((x) => x)),
    status: json["status"],
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    coverImage: json["coverImage"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "createdBy": createdBy,
    "title": title,
    "description": description,
    "destination": destination,
    "images": images,
    "totalDays": totalDays,
    "basePrice": basePrice,
    "currency": currency,
    "maxCapacity": maxCapacity,
    "itinerary": itinerary == null ? null : List<dynamic>.from(itinerary!.map((x) => x.toJson())),
    "inclusions": inclusions,
    "exclusions": exclusions,
    "importantNotes": importantNotes,
    "status": status,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "coverImage": coverImage,
  };
}

class Itinerary {
  final Meals? meals;
  final int? day;
  final DateTime? date;
  final String? title;
  final String? description;
  final List<Experience>? experiences;
  final String? notes;
  final String? id;

  Itinerary({this.meals, this.day, this.date, this.title, this.description, this.experiences, this.notes, this.id});

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
    meals: json["meals"] == null ? null : Meals.fromJson(json["meals"]),
    day: json["day"] is int ? json["day"] : (json["day"] as double?)?.toInt(),
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    title: json["title"],
    description: json["description"],
    experiences: json["experiences"] == null ? null : List<Experience>.from(json["experiences"].map((x) => Experience.fromJson(x))),
    notes: json["notes"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "meals": meals?.toJson(),
    "day": day,
    "date": date?.toIso8601String(),
    "title": title,
    "description": description,
    "experiences": experiences == null ? null : List<dynamic>.from(experiences!.map((x) => x.toJson())),
    "notes": notes,
    "_id": id,
  };
}

class Experience {
  final String? name;
  final String? category;
  final String? description;
  final String? location;
  final String? mapsLink;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final bool? isOptional;
  final bool? isHighlight;
  final List<String>? images;
  final String? videoUrl;
  final Vendor? vendor;
  final String? vendorNotes;
  final List<dynamic>? whatToBring;
  final String? difficulty;
  final bool? includedInPrice;
  final int? extraCost;
  final String? id;

  Experience({
    this.name,
    this.category,
    this.description,
    this.location,
    this.mapsLink,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.isOptional,
    this.isHighlight,
    this.images,
    this.videoUrl,
    this.vendor,
    this.vendorNotes,
    this.whatToBring,
    this.difficulty,
    this.includedInPrice,
    this.extraCost,
    this.id,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    name: json["name"],
    category: json["category"],
    description: json["description"],
    location: json["location"],
    mapsLink: json["mapsLink"],
    startTime: json["startTime"],
    endTime: json["endTime"],
    durationMinutes: json["durationMinutes"] is int ? json["durationMinutes"] : (json["durationMinutes"] as double?)?.toInt(),
    isOptional: json["isOptional"],
    isHighlight: json["isHighlight"],
    images: json["images"] == null ? null : List<String>.from(json["images"].map((x) => x)),
    videoUrl: json["videoUrl"],
    vendor: json["vendor"] == null ? null : (json["vendor"] is Map ? Vendor.fromJson(json["vendor"]) : Vendor(id: json["vendor"].toString())),
    vendorNotes: json["vendorNotes"],
    whatToBring: json["whatToBring"] == null ? null : List<dynamic>.from(json["whatToBring"].map((x) => x)),
    difficulty: json["difficulty"],
    includedInPrice: json["includedInPrice"],
    extraCost: json["extraCost"] is int ? json["extraCost"] : (json["extraCost"] as double?)?.toInt(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "category": category,
    "description": description,
    "location": location,
    "mapsLink": mapsLink,
    "startTime": startTime,
    "endTime": endTime,
    "durationMinutes": durationMinutes,
    "isOptional": isOptional,
    "isHighlight": isHighlight,
    "images": images,
    "videoUrl": videoUrl,
    "vendor": vendor?.toJson(),
    "vendorNotes": vendorNotes,
    "whatToBring": whatToBring,
    "difficulty": difficulty,
    "includedInPrice": includedInPrice,
    "extraCost": extraCost,
    "_id": id,
  };
}

class Vendor {
  final String? id;
  final String? createdBy;
  final String? email;
  final String? passwordHash;
  final String? name;
  final String? contactPerson;
  final String? phone;
  final String? type;
  final String? city;
  final String? country;
  final List<dynamic>? docs;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    this.id,
    this.createdBy,
    this.email,
    this.passwordHash,
    this.name,
    this.contactPerson,
    this.phone,
    this.type,
    this.city,
    this.country,
    this.docs,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json["_id"],
    createdBy: json["createdBy"],
    email: json["email"],
    passwordHash: json["passwordHash"],
    name: json["name"],
    contactPerson: json["contactPerson"],
    phone: json["phone"],
    type: json["type"],
    city: json["city"],
    country: json["country"],
    docs: json["docs"] == null ? null : List<dynamic>.from(json["docs"].map((x) => x)),
    isActive: json["isActive"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "createdBy": createdBy,
    "email": email,
    "passwordHash": passwordHash,
    "name": name,
    "contactPerson": contactPerson,
    "phone": phone,
    "type": type,
    "city": city,
    "country": country,
    "docs": docs,
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Meals {
  final bool? breakfast;
  final bool? lunch;
  final bool? dinner;
  final dynamic breakfastVendor;
  final dynamic lunchVendor;
  final dynamic dinnerVendor;

  Meals({this.breakfast, this.lunch, this.dinner, this.breakfastVendor, this.lunchVendor, this.dinnerVendor});

  factory Meals.fromJson(Map<String, dynamic> json) => Meals(
    breakfast: json["breakfast"],
    lunch: json["lunch"],
    dinner: json["dinner"],
    breakfastVendor: json["breakfastVendor"],
    lunchVendor: json["lunchVendor"],
    dinnerVendor: json["dinnerVendor"],
  );

  Map<String, dynamic> toJson() => {
    "breakfast": breakfast,
    "lunch": lunch,
    "dinner": dinner,
    "breakfastVendor": breakfastVendor,
    "lunchVendor": lunchVendor,
    "dinnerVendor": dinnerVendor,
  };
}

class Ticket {
  final String? name;
  final String? fileUrl;
  final DateTime? uploadedAt;
  final String? uploadedBy;
  final String? id;

  Ticket({this.name, this.fileUrl, this.uploadedAt, this.uploadedBy, this.id});

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    name: json["name"],
    fileUrl: json["fileUrl"],
    uploadedAt: json["uploadedAt"] == null ? null : DateTime.parse(json["uploadedAt"]),
    uploadedBy: json["uploadedBy"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {"name": name, "fileUrl": fileUrl, "uploadedAt": uploadedAt?.toIso8601String(), "uploadedBy": uploadedBy, "_id": id};
}

class Traveler {
  final TravelerDocs? docs;
  final String? name;
  final int? age;
  final String? id;

  Traveler({this.docs, this.name, this.age, this.id});

  factory Traveler.fromJson(Map<String, dynamic> json) => Traveler(
    docs: json["docs"] == null ? null : TravelerDocs.fromJson(json["docs"]),
    name: json["name"],
    age: json["age"] is int ? json["age"] : (json["age"] as double?)?.toInt(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {"docs": docs?.toJson(), "name": name, "age": age, "_id": id};
}

class TravelerDocs {
  final String? aadharFront;
  final String? aadharBack;
  final List<dynamic>? otherDocs;

  TravelerDocs({this.aadharFront, this.aadharBack, this.otherDocs});

  factory TravelerDocs.fromJson(Map<String, dynamic> json) => TravelerDocs(
    aadharFront: json["aadharFront"],
    aadharBack: json["aadharBack"],
    otherDocs: json["otherDocs"] == null ? null : List<dynamic>.from(json["otherDocs"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {"aadharFront": aadharFront, "aadharBack": aadharBack, "otherDocs": otherDocs};
}

class WhitelabelPackage {
  final String? id;
  final String? originalPackage;
  final String? createdBy;
  final String? ownedByParent;
  final String? customTitle;
  final String? customDescription;
  final List<dynamic>? customImages;
  final String? commissionType;
  final int? commissionValue;
  final int? finalPrice;
  final bool? isActive;
  final bool? autoDisabledByParent;
  final bool? manuallyDisabledByOwner;
  final bool? visibleToSubChildren;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WhitelabelPackage({
    this.id,
    this.originalPackage,
    this.createdBy,
    this.ownedByParent,
    this.customTitle,
    this.customDescription,
    this.customImages,
    this.commissionType,
    this.commissionValue,
    this.finalPrice,
    this.isActive,
    this.autoDisabledByParent,
    this.manuallyDisabledByOwner,
    this.visibleToSubChildren,
    this.createdAt,
    this.updatedAt,
  });

  factory WhitelabelPackage.fromJson(Map<String, dynamic> json) => WhitelabelPackage(
    id: json["_id"],
    originalPackage: json["originalPackage"],
    createdBy: json["createdBy"],
    ownedByParent: json["ownedByParent"],
    customTitle: json["customTitle"],
    customDescription: json["customDescription"],
    customImages: json["customImages"] == null ? null : List<dynamic>.from(json["customImages"].map((x) => x)),
    commissionType: json["commissionType"],
    commissionValue: json["commissionValue"] is int ? json["commissionValue"] : (json["commissionValue"] as double?)?.toInt(),
    finalPrice: json["finalPrice"] is int ? json["finalPrice"] : (json["finalPrice"] as double?)?.toInt(),
    isActive: json["isActive"],
    autoDisabledByParent: json["autoDisabledByParent"],
    manuallyDisabledByOwner: json["manuallyDisabledByOwner"],
    visibleToSubChildren: json["visibleToSubChildren"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "originalPackage": originalPackage,
    "createdBy": createdBy,
    "ownedByParent": ownedByParent,
    "customTitle": customTitle,
    "customDescription": customDescription,
    "customImages": customImages,
    "commissionType": commissionType,
    "commissionValue": commissionValue,
    "finalPrice": finalPrice,
    "isActive": isActive,
    "autoDisabledByParent": autoDisabledByParent,
    "manuallyDisabledByOwner": manuallyDisabledByOwner,
    "visibleToSubChildren": visibleToSubChildren,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Pagination {
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  Pagination({this.total, this.page, this.limit, this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"] is int ? json["total"] : (json["total"] as double?)?.toInt(),
    page: json["page"] is int ? json["page"] : (json["page"] as double?)?.toInt(),
    limit: json["limit"] is int ? json["limit"] : (json["limit"] as double?)?.toInt(),
    totalPages: json["totalPages"] is int ? json["totalPages"] : (json["totalPages"] as double?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {"total": total, "page": page, "limit": limit, "totalPages": totalPages};
}
