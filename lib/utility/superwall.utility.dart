import 'package:superwallkit_flutter/superwallkit_flutter.dart';

/// Checks if the user has premium access
Future<bool> checkPremiumStatus() async {
  try {
    final status = await Superwall.shared.getSubscriptionStatus();
    final statusString = await status.description;
    // Check if the subscription status indicates an active subscription
    return statusString != "INACTIVE";
  } catch (e) {
    return false;
  }
}
