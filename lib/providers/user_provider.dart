import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  late Box _box;
  String _name = 'User';
  String? _imageBase64;

  String get name => _name;

  // Extracts the first name for the Home Screen
  String get firstName => _name.split(' ').first;

  String? get imageBase64 => _imageBase64;

  Future<void> init() async {
    _box = await Hive.openBox('userProfile');
    _name = _box.get('name', defaultValue: 'User');
    _imageBase64 = _box.get('imageBase64');
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    _name = newName.trim();
    await _box.put('name', _name);
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    // Compressing the image to 20% quality keeps the Hive database lightweight and fast
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (xFile != null) {
      final bytes = await File(xFile.path).readAsBytes();
      _imageBase64 = base64Encode(bytes);
      await _box.put('imageBase64', _imageBase64);
      notifyListeners();
    }
  }

  Future<void> clearProfile() async {
    await _box.clear();
    _name = 'User';
    _imageBase64 = null;
    notifyListeners();
  }
}