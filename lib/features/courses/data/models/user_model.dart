/// User Model
class UserModel {
  final int? id;
  final String? uuid;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? avatar;
  final String? cover;
  final String? headline;
  final String? bio;
  final String? about;
  final String? role;
  final String? roleName;
  final bool? verified;
  final bool? availableForMeetings;
  final int? studentsCount;
  final int? coursesCount;
  final int? meetingsCount;
  final int? reviewsCount;
  final String? rate;
  final int? followers;
  final bool? auth;
  final bool? followed;
  final bool? offline;
  final int? offlineStatus;
  final String? offlineMessage;
  final List<MeetingInfo>? meeting;
  final List<UserBadge>? badges;
  final List<Education>? educations;
  final List<Experience>? experiences;

  UserModel({
    this.id,
    this.uuid,
    this.fullName,
    this.email,
    this.mobile,
    this.avatar,
    this.cover,
    this.headline,
    this.bio,
    this.about,
    this.role,
    this.roleName,
    this.verified,
    this.availableForMeetings,
    this.studentsCount,
    this.coursesCount,
    this.meetingsCount,
    this.reviewsCount,
    this.rate,
    this.followers,
    this.auth,
    this.followed,
    this.offline,
    this.offlineStatus,
    this.offlineMessage,
    this.meeting,
    this.badges,
    this.educations,
    this.experiences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to convert int/bool/string to bool
    bool? toBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return null;
    }
    
    return UserModel(
      id: json['id'],
      uuid: json['uuid'],
      fullName: json['full_name'],
      email: json['email'],
      mobile: json['mobile'],
      avatar: json['avatar'],
      cover: json['cover'],
      headline: json['headline'],
      bio: json['bio'],
      about: json['about'],
      role: json['role'],
      roleName: json['role_name'],
      verified: toBool(json['verified']),
      availableForMeetings: toBool(json['available_for_meetings']),
      studentsCount: json['students_count'],
      coursesCount: json['courses_count'],
      meetingsCount: json['meetings_count'],
      reviewsCount: json['reviews_count'],
      rate: json['rate']?.toString(),
      followers: json['followers'],
      auth: toBool(json['auth']),
      followed: toBool(json['followed']),
      offline: toBool(json['offline']),
      offlineStatus: json['offline_status'],
      offlineMessage: json['offline_message'],
      meeting: json['meeting'] != null
          ? (json['meeting'] as List)
              .map((e) => MeetingInfo.fromJson(e))
              .toList()
          : null,
      badges: json['badges'] != null
          ? (json['badges'] as List)
              .map((e) => UserBadge.fromJson(e))
              .toList()
          : null,
      educations: json['educations'] != null
          ? (json['educations'] as List)
              .map((e) => Education.fromJson(e))
              .toList()
          : null,
      experiences: json['experiences'] != null
          ? (json['experiences'] as List)
              .map((e) => Experience.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'avatar': avatar,
      'cover': cover,
      'headline': headline,
      'bio': bio,
      'about': about,
      'role': role,
      'role_name': roleName,
      'verified': verified,
      'available_for_meetings': availableForMeetings,
      'students_count': studentsCount,
      'courses_count': coursesCount,
      'rate': rate,
      'followers': followers,
    };
  }

  /// Get identifier (id or uuid)
  dynamic get identifier => id ?? uuid;

  /// Get display name
  String get displayName => fullName ?? email ?? 'User';

  /// Check if user is instructor/teacher
  bool get isInstructor => role == 'teacher';

  /// Check if user is organization
  bool get isOrganization => role == 'organization';
}

/// Meeting Info Model
class MeetingInfo {
  final int? id;
  final int? inPerson;
  final int? groupMeeting;
  final dynamic price;
  final dynamic inPersonPrice;
  final String? priceWithDiscount;
  final String? discount;
  final String? discountTitle;
  final String? discountPercent;
  final int? timingType;
  final int? groupMeetingCapacity;
  final int? status;

  MeetingInfo({
    this.id,
    this.inPerson,
    this.groupMeeting,
    this.price,
    this.inPersonPrice,
    this.priceWithDiscount,
    this.discount,
    this.discountTitle,
    this.discountPercent,
    this.timingType,
    this.groupMeetingCapacity,
    this.status,
  });

  factory MeetingInfo.fromJson(Map<String, dynamic> json) {
    return MeetingInfo(
      id: json['id'],
      inPerson: json['in_person'],
      groupMeeting: json['group_meeting'],
      price: json['price'],
      inPersonPrice: json['in_person_price'],
      priceWithDiscount: json['price_with_discount']?.toString(),
      discount: json['discount']?.toString(),
      discountTitle: json['discount_title'],
      discountPercent: json['discount_percent']?.toString(),
      timingType: json['timing_type'],
      groupMeetingCapacity: json['group_meeting_capacity'],
      status: json['status'],
    );
  }
}

/// User Badge Model
class UserBadge {
  final int? id;
  final String? title;
  final String? description;
  final String? image;
  final int? condition;
  final String? type;

  UserBadge({
    this.id,
    this.title,
    this.description,
    this.image,
    this.condition,
    this.type,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      condition: json['condition'],
      type: json['type'],
    );
  }
}

/// Education Model
class Education {
  final int? id;
  final String? degree;
  final String? fieldOfStudy;
  final String? university;
  final String? college;
  final int? startDate;
  final int? endDate;

  Education({
    this.id,
    this.degree,
    this.fieldOfStudy,
    this.university,
    this.college,
    this.startDate,
    this.endDate,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      degree: json['degree'],
      fieldOfStudy: json['field_of_study'],
      university: json['university'],
      college: json['college'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

/// Experience Model
class Experience {
  final int? id;
  final String? title;
  final String? company;
  final String? location;
  final int? startDate;
  final int? endDate;

  Experience({
    this.id,
    this.title,
    this.company,
    this.location,
    this.startDate,
    this.endDate,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

