import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/enums/unit_system.enum.dart';
import 'package:healthcore/pages/settings/about_page.dart';
import 'package:healthcore/pages/settings/contact_us_page.dart';
import 'package:healthcore/pages/settings/account_management_page.dart';
import 'package:in_app_review/in_app_review.dart';
import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  static const routeName = '/settings';
  
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final SettingsController controller = SettingsController();
  final InAppReview _inAppReview = InAppReview.instance;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open review dialog at this time.'),
              backgroundColor: CoreColors.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting review: $e'),
            backgroundColor: CoreColors.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: FontSizes.large,
              fontWeight: FontWeight.bold,
              color: CoreColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: PaddingSizes.medium),
        Card(
          color: CoreColors.foregroundColor,
          margin: const EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: PaddingSizes.xlarge),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? CoreColors.accentColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? CoreColors.textColor,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: CoreColors.textColor,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: CoreColors.accentColor,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: CoreColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: CoreColors.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PaddingSizes.large),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: PaddingSizes.large),
                  _buildSection(
                    'Preferences',
                    [
                      _buildListTile(
                        icon: Icons.settings,
                        title: 'Unit System',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Unit System'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SegmentedButton<UnitSystem>(
                                    segments: const [
                                      ButtonSegment(
                                        value: UnitSystem.metric,
                                        label: Text('Metric'),
                                      ),
                                      ButtonSegment(
                                        value: UnitSystem.imperial,
                                        label: Text('Imperial'),
                                      ),
                                    ],
                                    selected: {controller.unitSystem},
                                    onSelectionChanged: (Set<UnitSystem> selected) {
                                      controller.updateUnitSystem(selected.first);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    'Account',
                    [
                      _buildListTile(
                        icon: Icons.person,
                        title: 'Account Management',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountManagementPage(),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        onTap: () async {
                          final shouldSignOut = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Sign Out',
                                    style: TextStyle(color: CoreColors.errorColor),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldSignOut == true && context.mounted) {
                            await controller.logout(context);
                          }
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    'App',
                    [
                      _buildListTile(
                        icon: Icons.info,
                        title: 'About',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutPage(),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.email,
                        title: 'Contact Us',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactUsPage(),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.star,
                        title: 'Rate the App',
                        onTap: _requestReview,
                      ),
                    ],
                  ),
                  _buildSection(
                    'Data',
                    [
                      _buildListTile(
                        icon: Icons.refresh,
                        title: 'Refresh Data Cache',
                        onTap: controller.clearCache,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: CoreColors.accentColor,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Refresh Data Cache'),
                                content: const Text(
                                  'To improve loading times, we cache your health data on your device. If you want to resync old data directly with Apple Health then use this.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
