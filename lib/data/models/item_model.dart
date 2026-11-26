import 'profile_model.dart';

enum ListingType { sell, swap, share }
enum ItemStatus { available, reserved, completed }

class ItemModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final ListingType listingType;
  final double price;
  final String? swapWishlist;
  final String category;
  final String condition;
  final ItemStatus status;
  final String city;
  final String? areaNotes;
  final String? primaryImageUrl;
  final int viewCount;
  final DateTime createdAt;
  final ProfileModel? owner;
  final List<String> images;

  ItemModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.listingType,
    required this.price,
    this.swapWishlist,
    required this.category,
    required this.condition,
    this.status = ItemStatus.available,
    required this.city,
    this.areaNotes,
    this.primaryImageUrl,
    this.viewCount = 0,
    required this.createdAt,
    this.owner,
    this.images = const [],
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    ListingType type = ListingType.sell;
    final typeStr = json['listing_type'] as String?;
    if (typeStr == 'swap') type = ListingType.swap;
    if (typeStr == 'share') type = ListingType.share;

    ItemStatus st = ItemStatus.available;
    final statusStr = json['status'] as String?;
    if (statusStr == 'reserved') st = ItemStatus.reserved;
    if (statusStr == 'completed') st = ItemStatus.completed;

    List<String> imageList = [];
    if (json['item_images'] != null && json['item_images'] is List) {
      imageList = (json['item_images'] as List)
          .map((img) => img['image_url'] as String)
          .toList();
    }
    if (imageList.isEmpty && json['primary_image_url'] != null) {
      imageList.add(json['primary_image_url'] as String);
    }

    ProfileModel? ownerObj;
    if (json['profiles'] != null && json['profiles'] is Map) {
      ownerObj = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return ItemModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      listingType: type,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      swapWishlist: json['swap_wishlist'] as String?,
      category: json['category'] as String? ?? 'Umum',
      condition: json['condition'] as String? ?? 'Bekas Layak Pakai',
      status: st,
      city: json['city'] as String? ?? 'Jakarta',
      areaNotes: json['area_notes'] as String?,
      primaryImageUrl: json['primary_image_url'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      owner: ownerObj,
      images: imageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'listing_type': listingType.name,
      'price': price,
      'swap_wishlist': swapWishlist,
      'category': category,
      'condition': condition,
      'status': status.name,
      'city': city,
      'area_notes': areaNotes,
      'primary_image_url': primaryImageUrl,
    };
  }
}
