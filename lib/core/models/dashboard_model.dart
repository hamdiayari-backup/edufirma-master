/// Dashboard Model - Dashboard data for users/instructors/organizations
class DashboardModel {
  final int? offline;
  final int? spentPoints;
  final int? totalPoints;
  final int? availablePoints;
  final String? roleName;
  final String? fullName;
  final int? financialApproval;
  final UnreadNotifications? unreadNotifications;
  final List<UnreadNoticeboard> unreadNoticeboards;
  final double? balance;
  final bool? canDrawable;
  final Badges? badges;
  final int? countCartItems;
  final int? pendingAppointments;
  final int? monthlySalesCount;
  final MonthlyChart? monthlyChart;
  final int? webinarsCount;
  final int? reserveMeetingsCount;
  final int? supportsCount;
  final int? commentsCount;

  DashboardModel({
    this.offline,
    this.spentPoints,
    this.totalPoints,
    this.availablePoints,
    this.roleName,
    this.fullName,
    this.financialApproval,
    this.unreadNotifications,
    this.unreadNoticeboards = const [],
    this.balance,
    this.canDrawable,
    this.badges,
    this.countCartItems,
    this.pendingAppointments,
    this.monthlySalesCount,
    this.monthlyChart,
    this.webinarsCount,
    this.reserveMeetingsCount,
    this.supportsCount,
    this.commentsCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      offline: json['offline'],
      spentPoints: json['spent_points'],
      totalPoints: json['total_points'],
      availablePoints: json['available_points'],
      roleName: json['role_name'],
      fullName: json['full_name'],
      financialApproval: json['financial_approval'],
      unreadNotifications: json['unread_notifications'] != null
          ? UnreadNotifications.fromJson(json['unread_notifications'])
          : null,
      unreadNoticeboards: (json['unread_noticeboards'] as List<dynamic>?)
              ?.map((v) => UnreadNoticeboard.fromJson(v))
              .toList() ??
          [],
      balance: double.tryParse(json['balance']?.toString() ?? '0'),
      canDrawable: json['can_drawable'],
      badges: json['badges'] != null ? Badges.fromJson(json['badges']) : null,
      countCartItems: json['count_cart_items'],
      pendingAppointments: json['pendingAppointments'],
      monthlySalesCount: json['monthlySalesCount'],
      monthlyChart: json['monthlyChart'] != null
          ? MonthlyChart.fromJson(json['monthlyChart'])
          : null,
      webinarsCount: json['webinarsCount'],
      reserveMeetingsCount: json['reserveMeetingsCount'],
      supportsCount: json['supportsCount'],
      commentsCount: json['commentsCount'],
    );
  }

  bool get isInstructor => roleName == 'teacher' || roleName == 'organization';
}

class UnreadNotifications {
  final int? count;
  final List<DashboardNotification> notifications;

  UnreadNotifications({
    this.count,
    this.notifications = const [],
  });

  factory UnreadNotifications.fromJson(Map<String, dynamic> json) {
    return UnreadNotifications(
      count: json['count'],
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((v) => DashboardNotification.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class DashboardNotification {
  final int? id;
  final String? title;
  final String? message;
  final String? type;
  final int? createdAt;

  DashboardNotification({
    this.id,
    this.title,
    this.message,
    this.type,
    this.createdAt,
  });

  factory DashboardNotification.fromJson(Map<String, dynamic> json) {
    return DashboardNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      createdAt: json['created_at'],
    );
  }
}

class UnreadNoticeboard {
  final int? id;
  final String? title;
  final String? message;
  final String? sender;
  final int? createdAt;

  UnreadNoticeboard({
    this.id,
    this.title,
    this.message,
    this.sender,
    this.createdAt,
  });

  factory UnreadNoticeboard.fromJson(Map<String, dynamic> json) {
    return UnreadNoticeboard(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      sender: json['sender'],
      createdAt: json['created_at'],
    );
  }
}

class Badges {
  final String? nextBadge;
  final dynamic percent;
  final String? earned;

  Badges({
    this.nextBadge,
    this.percent,
    this.earned,
  });

  factory Badges.fromJson(Map<String, dynamic> json) {
    return Badges(
      nextBadge: json['next_badge'],
      percent: json['percent'],
      earned: json['earned'],
    );
  }
}

class MonthlyChart {
  final List<String> months;
  final List<int> data;

  MonthlyChart({
    this.months = const [],
    this.data = const [],
  });

  factory MonthlyChart.fromJson(Map<String, dynamic> json) {
    return MonthlyChart(
      months: (json['months'] as List<dynamic>?)?.cast<String>() ?? [],
      data: (json['data'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }
}
