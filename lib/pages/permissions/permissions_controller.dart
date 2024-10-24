import '../../services/health_service.dart';

class PermissionsController {
  final HealthService _healthService = HealthService();

  bool isLoading = true;
  String? errorMessage;

  Future<bool> checkPermissions() async {
    try {
      isLoading = true;
      errorMessage = null;

      bool isAuthorized = await _healthService.checkAndRequestPermissions();

      isLoading = false;

      if (!isAuthorized) {
        errorMessage = 'Health permissions are required to use this app.';
      }

      return isAuthorized;
    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred: $e';
      return false;
    }
  }
}
