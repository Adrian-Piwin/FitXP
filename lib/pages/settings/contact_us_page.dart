import 'package:flutter/material.dart';
import 'package:healthcore/pages/settings/report_form_page.dart';
import 'package:healthcore/services/report_service.dart';

class ContactUsPage extends StatelessWidget {
  static const routeName = '/contact-us';
  
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            ReportType.featureRequest,
            Icons.lightbulb_outline,
            'Suggest a new feature or improvement',
          ),
          _buildMenuItem(
            context,
            ReportType.bugReport,
            Icons.bug_report_outlined,
            'Report a problem or bug',
          ),
          _buildMenuItem(
            context,
            ReportType.helpRequest,
            Icons.help_outline,
            'Get help with using the app',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ReportType type,
    IconData icon,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(ReportService().getReportTypeLabel(type)),
        subtitle: Text(subtitle),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportFormPage(reportType: type),
            ),
          );
        },
      ),
    );
  }
} 
