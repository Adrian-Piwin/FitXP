import 'package:flutter/material.dart';
import 'package:healthxp/services/health_fetcher_service.dart';

class DataLoadingView extends StatefulWidget {
  static const routeName = '/data-loading';

  const DataLoadingView({super.key});

  @override
  State<DataLoadingView> createState() => _DataLoadingViewState();
}

class _DataLoadingViewState extends State<DataLoadingView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await HealthFetcherService().cacheAllHistoricalData();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load health data')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading health data...'),
          ],
        ),
      ),
    );
  }
} 
