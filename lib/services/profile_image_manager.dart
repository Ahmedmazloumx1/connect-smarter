import 'package:flutter/foundation.dart';

/// A singleton that holds the user's chosen profile photo across all screens.
/// Any screen can listen to [profileImage] via ValueListenableBuilder
/// or simply read/write [profileImage.value].
class ProfileImageManager {
  static final ProfileImageManager _instance = ProfileImageManager._internal();
  factory ProfileImageManager() => _instance;
  ProfileImageManager._internal();

  /// The currently selected profile image. Null means use the default asset.
  final ValueNotifier<Uint8List?> profileImage = ValueNotifier<Uint8List?>(
    null,
  );
}
