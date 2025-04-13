import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';

class TermsConditionsPage extends StatelessWidget {
  static const routeName = '/terms-conditions';
  
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                'AGREEMENT TO TERMS',
                'These Terms and Conditions constitute a legally binding agreement made between you and FitXP concerning your access to and use of the FitXP mobile application.\n\n'
                'By accessing or using the application, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access the application.'
              ),
              
              _buildSection(
                'INTELLECTUAL PROPERTY RIGHTS',
                'Unless otherwise indicated, the application and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the application (collectively, the "Content") and the trademarks, service marks, and logos contained therein (the "Marks") are owned or controlled by us.\n\n'
                'The Content and the Marks are provided "AS IS" for your information and personal use only. Except as expressly provided in these Terms, no part of the application and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.'
              ),
              
              _buildSection(
                'USER REPRESENTATIONS',
                'By using the application, you represent and warrant that:\n'
                '• All registration information you submit will be true, accurate, current, and complete\n'
                '• You will maintain the accuracy of such information and promptly update as necessary\n'
                '• You have the legal capacity to comply with these Terms and Conditions\n'
                '• You are not a minor in the jurisdiction in which you reside\n'
                '• You will not access the application through automated or non-human means\n'
                '• You will not use the application for any illegal or unauthorized purpose'
              ),
              
              _buildSection(
                'SUBSCRIPTION AND PAYMENTS',
                'Some features of the application require payment of fees. You will be required to select a payment plan and provide accurate payment information.\n\n'
                'By submitting such information, you grant us the right to provide the information to third parties for purposes of facilitating payment. Verification of information may be required before the acceptance of any order.\n\n'
                'Subscription fees are billed in advance on either a monthly or annual basis depending on the type of subscription plan selected. Your subscription will automatically renew at the end of each subscription period unless you cancel it through your account settings.'
              ),
              
              _buildSection(
                'FREE TRIAL',
                'We may, at our sole discretion, offer a subscription with a free trial for a limited period of time. You may be required to enter your billing information to sign up for the free trial.\n\n'
                'If you do enter your billing information, you will not be charged until the free trial has expired. On the last day of the free trial period, unless you cancel your subscription, you will be automatically charged the applicable subscription fee for the type of subscription you have selected.'
              ),
              
              _buildSection(
                'PROHIBITED ACTIVITIES',
                'You may not access or use the application for any purpose other than that for which we make the application available. The application may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us.\n\n'
                'As a user of the application, you agree not to:\n'
                '• Systematically retrieve data to create a collection, compilation, database, or directory\n'
                '• Trick, defraud, or mislead us and other users\n'
                '• Circumvent, disable, or otherwise interfere with security-related features\n'
                '• Disparage, tarnish, or otherwise harm, in our opinion, us and/or the application\n'
                '• Use any information obtained from the application to harass, abuse, or harm another person\n'
                '• Make improper use of our support services or submit false reports of abuse\n'
                '• Use the application in a manner inconsistent with any applicable laws or regulations'
              ),
              
              _buildSection(
                'MODIFICATIONS AND INTERRUPTIONS',
                'We reserve the right to change, modify, or remove the contents of the application at any time or for any reason at our sole discretion without notice. We have no obligation to update any information on our application.\n\n'
                'We cannot guarantee the application will be available at all times. We may experience hardware, software, or other problems or need to perform maintenance related to the application, resulting in interruptions, delays, or errors. We reserve the right to change, revise, update, suspend, discontinue, or otherwise modify the application at any time or for any reason without notice to you.'
              ),
              
              _buildSection(
                'GOVERNING LAW',
                'These Terms shall be governed by and defined following the laws of your country of residence. FitXP and yourself irrevocably consent that the courts of your country of residence shall have exclusive jurisdiction to resolve any dispute which may arise in connection with these terms.'
              ),
              
              _buildSection(
                'CORRECTIONS',
                'There may be information on the application that contains typographical errors, inaccuracies, or omissions, including descriptions, pricing, availability, and various other information. We reserve the right to correct any errors, inaccuracies, or omissions and to change or update the information on the application at any time, without prior notice.'
              ),
              
              _buildSection(
                'DISCLAIMER',
                'THE APPLICATION IS PROVIDED ON AN "AS-IS" AND "AS AVAILABLE" BASIS. YOU AGREE THAT YOUR USE OF THE APPLICATION AND OUR SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE APPLICATION AND YOUR USE THEREOF.'
              ),
              
              _buildSection(
                'LIMITATIONS OF LIABILITY',
                'IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE APPLICATION, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.'
              ),
              
              _buildSection(
                'CONTACT US',
                'For questions about these Terms & Conditions, please contact us at:\n\ndevaydren@gmail.com'
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
