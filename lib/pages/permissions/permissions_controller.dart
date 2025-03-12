import '../../services/health_fetcher_service.dart';

class PermissionsController {
  late final HealthFetcherService _healthService;

  bool isLoading = true;
  String? errorMessage;

  Future<bool> checkPermissions() async {
    _healthService = await HealthFetcherService.getInstance();
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
