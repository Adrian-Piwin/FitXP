import 'package:healthcore/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/pages/app.dart';
import 'permissions_controller.dart';

class PermissionsView extends StatefulWidget {
  const PermissionsView({super.key});

  static const String routeName = "/permissions";

  @override
  State<PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<PermissionsView> {
  final PermissionsController _controller = PermissionsController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool isAuthorized = await _controller.checkPermissions();
    if (isAuthorized && mounted) {
      Navigator.of(context).pushReplacementNamed(MainView.routeName);
    } else {
      // Permissions not granted, stay on this page
      setState(() {});
    }
  }

  void _retry() {
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (_controller.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Permissions Required')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(PaddingSizes.xlarge),
            child: Column(
              children: [
                Text(
                  _controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: FontSizes.medium),
                ),
                const SizedBox(height: GapSizes.xlarge),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // This case should not occur, but handle it gracefully
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
