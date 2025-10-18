import 'package:equatable/equatable.dart';

class PurchaseHistory extends Equatable {
  final String id;
  final String plan;
  final DateTime purchaseDate;
  final double amount;
  final String status;

  const PurchaseHistory({
    required this.id,
    required this.plan,
    required this.purchaseDate,
    required this.amount,
    required this.status,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      id: json['id'] ?? '',
      plan: json['plan'] ?? '',
      purchaseDate: DateTime.parse(
        json['purchase_date'] ?? DateTime.now().toIso8601String(),
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': plan,
      'purchase_date': purchaseDate.toIso8601String(),
      'amount': amount,
      'status': status,
    };
  }

  @override
  List<Object> get props => [id, plan, purchaseDate, amount, status];
}

class FirebaseUserResponse extends Equatable {
  final String uid;
  final String email;
  final bool emailVerified;
  final String? name;
  final String? picture;
  final String? phoneNumber;
  final bool isPremium;
  final String? subscriptionPlan;
  final Map<String, dynamic>? apiUsage;
  final DateTime? premiumExpiresAt;
  final bool loggedIn;
  final List<PurchaseHistory> purchaseHistory;

  const FirebaseUserResponse({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.name,
    this.picture,
    this.phoneNumber,
    this.isPremium = false,
    this.subscriptionPlan,
    this.apiUsage,
    this.premiumExpiresAt,
    this.loggedIn = false,
    this.purchaseHistory = const [],
  });

  factory FirebaseUserResponse.fromJson(Map<String, dynamic> json) {
    return FirebaseUserResponse(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      name: json['name'],
      picture: json['picture'],
      phoneNumber: json['phone_number'],
      isPremium: json['is_premium'] ?? false,
      subscriptionPlan: json['subscription_plan'],
      apiUsage: json['api_usage'],
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'])
          : null,
      loggedIn: json['logged_in'] ?? false,
      purchaseHistory:
          (json['purchase_history'] as List<dynamic>?)
              ?.map((item) => PurchaseHistory.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'email_verified': emailVerified,
      'name': name,
      'picture': picture,
      'phone_number': phoneNumber,
      'is_premium': isPremium,
      'subscription_plan': subscriptionPlan,
      'api_usage': apiUsage,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'logged_in': loggedIn,
      'purchase_history': purchaseHistory.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    emailVerified,
    name,
    picture,
    phoneNumber,
    isPremium,
    subscriptionPlan,
    apiUsage,
    premiumExpiresAt,
    loggedIn,
    purchaseHistory,
  ];
}
