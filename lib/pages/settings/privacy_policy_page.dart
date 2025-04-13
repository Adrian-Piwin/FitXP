import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const routeName = '/privacy-policy';
  
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Last updated: April 13, 2025',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildSection(
                'INTRODUCTION',
                'This privacy policy ("Policy") describes how FitXP collects, uses, and discloses your personal information when you use our mobile application. By using the FitXP app, you agree to the collection and use of information in accordance with this policy.'
              ),
              
              _buildSection(
                'INFORMATION WE COLLECT',
                'We collect information that you provide directly to us when you create an account, set up your profile, or interact with our app features.\n\n'
                'This includes:\n'
                '• Personal Information: Name, email address, date of birth, gender\n'
                '• Health Data: Weight, height, activity levels, workout information\n'
                '• Device Information: Device type, operating system, unique device identifiers\n'
                '• Usage Data: How you interact with our app, features you use, time spent in the app'
              ),
              
              _buildSection(
                'HOW WE USE YOUR INFORMATION',
                'We use the information we collect to:\n'
                '• Provide, maintain, and improve our services\n'
                '• Process your transactions and manage your account\n'
                '• Send you technical notices, updates, and support messages\n'
                '• Personalize your experience and deliver tailored content\n'
                '• Monitor and analyze trends, usage, and activities\n'
                '• Detect, prevent, and address technical issues'
              ),
              
              _buildSection(
                'SHARING YOUR INFORMATION',
                'We may share your information with:\n'
                '• Service Providers: Companies that perform services on our behalf\n'
                '• Business Partners: Third parties with whom we may offer joint products or services\n'
                '• Legal Requirements: When required by law or to protect our rights\n\n'
                'We will never sell your personal information to third parties for marketing purposes.'
              ),
              
              _buildSection(
                'DATA SECURITY',
                'We implement appropriate security measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.'
              ),
              
              _buildSection(
                'YOUR RIGHTS',
                'Depending on your location, you may have rights regarding your personal information, including:\n'
                '• Access: Request access to your personal information\n'
                '• Correction: Request that we correct inaccurate information\n'
                '• Deletion: Request that we delete your personal information\n'
                '• Restriction: Request that we restrict processing of your information\n'
                '• Data Portability: Request transfer of your information to another service'
              ),
              
              _buildSection(
                'CHILDREN\'S PRIVACY',
                'Our services are not intended for use by children under 13 years of age. We do not knowingly collect personal information from children under 13.'
              ),
              
              _buildSection(
                'CHANGES TO THIS POLICY',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.'
              ),
              
              _buildSection(
                'CONTACT US',
                'If you have any questions about this Privacy Policy, please contact us at:\n\ndevaydren@gmail.com'
              ),
              
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '© ${DateTime.now().year} FitXP. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 
