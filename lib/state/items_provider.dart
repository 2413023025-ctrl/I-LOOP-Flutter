import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/item_model.dart';
import '../data/repositories/item_repository.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemRepository _repo = ItemRepository();

  List<ItemModel> _items = [];
  List<ItemModel> _myItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  ListingType? _selectedType;
  String _selectedCategory = 'Semua';
  String _selectedCity = 'Semua Kota';
  String _searchQuery = '';

  List<ItemModel> get items => _items;
  List<ItemModel> get myItems => _myItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ListingType? get selectedType => _selectedType;
  String get selectedCategory => _selectedCategory;
  String get selectedCity => _selectedCity;
  String get searchQuery => _searchQuery;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _repo.getItems(
        filterType: _selectedType,
        category: _selectedCategory,
        searchQuery: _searchQuery,
        city: _selectedCity == 'Semua Kota' ? null : _selectedCity,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyItems() async {
    try {
      _myItems = await _repo.getMyItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching my items: $e');
    }
  }

  void setFilterType(ListingType? type) {
    if (_selectedType == type) {
      _selectedType = null;
    } else {
      _selectedType = type;
    }
    fetchItems();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchItems();
  }

  void setCity(String city) {
    _selectedCity = city;
    fetchItems();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchItems();
  }

  Future<bool> createItem({
    required String title,
    required String description,
    required ListingType listingType,
    required double price,
    String? swapWishlist,
    required String category,
    required String condition,
    required String city,
    String? areaNotes,
    required List<File> imageFiles,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<String> uploadedUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        final url = await _repo.uploadImage(imageFiles[i], 'item_$i');
        uploadedUrls.add(url);
      }

      await _repo.createItem(
        title: title,
        description: description,
        listingType: listingType,
        price: price,
        swapWishlist: swapWishlist,
        category: category,
        condition: condition,
        city: city,
        areaNotes: areaNotes,
        imageUrls: uploadedUrls,
      );

      await fetchItems();
      await fetchMyItems();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItemStatus(String itemId, ItemStatus status) async {
    await _repo.updateItemStatus(itemId, status);
    await fetchItems();
    await fetchMyItems();
  }

  Future<void> deleteItem(String itemId) async {
    await _repo.deleteItem(itemId);
    await fetchItems();
    await fetchMyItems();
  }
}
