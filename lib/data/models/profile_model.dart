class ProfileModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String city;
  final String? campusOrArea;
  final String? phoneNumber;
  final int itemsSavedCount;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.city,
    this.campusOrArea,
    this.phoneNumber,
    this.itemsSavedCount = 0,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Pengguna I\'LOOP',
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String? ?? 'Jakarta',
      campusOrArea: json['campus_or_area'] as String?,
      phoneNumber: json['phone_number'] as String?,
      itemsSavedCount: json['items_saved_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'city': city,
      'campus_or_area': campusOrArea,
      'phone_number': phoneNumber,
      'items_saved_count': itemsSavedCount,
    };
  }
}
