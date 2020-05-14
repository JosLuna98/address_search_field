part of '../../address_search_field.dart';

/// Check if location service is enabled and working and ask for permissions.
Future<void> initLocationService({
  FutureOr<void> Function() noServiceEnabled,
  FutureOr<void> Function() noPermissionGranted,
}) async {
  final Location controller = Location();
  bool serviceEnabled = await controller.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await controller.requestService();
    if (!serviceEnabled && noServiceEnabled != null) await noServiceEnabled();
  }
  serviceEnabled = await controller.serviceEnabled();
  if (!serviceEnabled) return;
  PermissionStatus permissionGranted = await controller.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await controller.requestPermission();
    if (permissionGranted != PermissionStatus.granted &&
        noPermissionGranted != null) await noPermissionGranted();
  }
}
