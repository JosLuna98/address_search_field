part of '../../address_search_text_field.dart';

/// Gives more [Location](https://pub.dev/packages/location) plug-in functionalities.
class LocationService {
  /// Control location functionalities.
  static final Location controller = Location();

  /// Check if location service is enabled and working and ask for permissions.
  static Future<void> init() async {
    bool serviceEnabled = await controller.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await controller.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    PermissionStatus permissionGranted = await controller.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await controller.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}
