import 'package:flutter/material.dart';
import '../services/conductor_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = ConductorService.notificationsEnabled;
  bool _autoSyncEnabled = ConductorService.autoSyncEnabled;
  bool _hapticFeedbackEnabled = ConductorService.hapticFeedbackEnabled;
  late final TextEditingController _fareController;
  bool _isSavingFare = false;

  @override
  void initState() {
    super.initState();
    _fareController = TextEditingController(
      text: ConductorService.defaultFareAmount.toString(),
    );
  }

  @override
  void dispose() {
    _fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conductor = ConductorService.currentConductor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.foregroundColor ??
                  (isDarkMode ? Colors.white : Colors.black87)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor ??
                (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionHeader('Profile', isDarkMode),
          _buildProfileCard(conductor, isDarkMode),
          const SizedBox(height: 24),

          // Fare Settings
          _buildSectionHeader('Fare Settings', isDarkMode),
          _buildFareSettings(isDarkMode),
          const SizedBox(height: 24),

          // App Preferences
          _buildSectionHeader('App Preferences', isDarkMode),
          _buildAppPreferences(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic conductor, bool isDarkMode) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(isDarkMode ? 50 : 25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isDarkMode ? Colors.blue[200] : Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conductor?.fullName ?? 'Conductor Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${conductor?.username ?? 'username'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${conductor?.id ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vehicle: ${conductor?.vehicleAssigned ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... rest of the settings screen code remains the same
  Widget _buildFareSettings(bool isDarkMode) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.attach_money,
            title: 'Default Fare Amount',
            subtitle: 'Set default fare for quick collection',
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                controller: _fareController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  suffixIcon: _isSavingFare
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  suffixText: 'KSH',
                  suffixStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onFieldSubmitted: (value) async {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please enter a valid fare amount greater than 0.'),
                      ),
                    );
                    _fareController.text =
                        ConductorService.defaultFareAmount.toString();
                    return;
                  }

                  setState(() {
                    _isSavingFare = true;
                  });
                  final ok = await ConductorService.updateSettings(
                    defaultFareAmount: parsed,
                  );
                  setState(() {
                    _isSavingFare = false;
                  });

                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Default fare updated to Ksh $parsed for this conductor.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Failed to update default fare. Please try again.'),
                      ),
                    );
                    _fareController.text =
                        ConductorService.defaultFareAmount.toString();
                  }
                },
              ),
            ),
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildSettingItem(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: 'Display currency for transactions',
            trailing: Text(
              'KSH',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('Currency is fixed to KSH (Kenyan Shilling)'),
                  backgroundColor: isDarkMode ? Colors.grey[700] : null,
                ),
              );
            },
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildSettingItem(
            icon: Icons.route,
            title: 'Route Presets',
            subtitle: 'Manage fare presets for different routes',
            trailing: Icon(Icons.arrow_forward_ios,
                size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey),
            onTap: _manageRoutePresets,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(bool isDarkMode) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive notifications from admin',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                final ok = await ConductorService.updateSettings(
                  notificationsEnabled: value,
                );
                if (!ok) {
                  // Roll back on failure
                  setState(() {
                    _notificationsEnabled = !value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to update notification preference.'),
                    ),
                  );
                  return;
                }

                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Notifications enabled - You will receive updates from admin'),
                      backgroundColor: isDarkMode ? Colors.grey[700] : null,
                    ),
                  );
                }
              },
              activeThumbColor: Colors.blue,
            ),
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildSettingItem(
            icon: Icons.sync,
            title: 'Auto Sync',
            subtitle: 'Automatically sync data when online',
            trailing: Switch(
              value: _autoSyncEnabled,
              onChanged: (value) async {
                setState(() {
                  _autoSyncEnabled = value;
                });
                final ok = await ConductorService.updateSettings(
                  autoSyncEnabled: value,
                );
                if (!ok) {
                  setState(() {
                    _autoSyncEnabled = !value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to update auto-sync preference.'),
                    ),
                  );
                  return;
                }

                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Auto sync will be enabled when database is connected'),
                      backgroundColor: isDarkMode ? Colors.grey[700] : null,
                    ),
                  );
                }
              },
              activeThumbColor: Colors.blue,
            ),
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'App language preference',
            trailing: Text(
              'English',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Only English is supported currently'),
                  backgroundColor: isDarkMode ? Colors.grey[700] : null,
                ),
              );
            },
            isDarkMode: isDarkMode,
          ),
          _buildDivider(isDarkMode),
          _buildSettingItem(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Enable vibration feedback for actions',
            trailing: Switch(
              value: _hapticFeedbackEnabled,
              onChanged: (value) async {
                setState(() {
                  _hapticFeedbackEnabled = value;
                });
                final ok = await ConductorService.updateSettings(
                  hapticFeedbackEnabled: value,
                );
                if (!ok) {
                  setState(() {
                    _hapticFeedbackEnabled = !value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Failed to update haptic feedback preference.'),
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value
                        ? 'Haptic feedback enabled'
                        : 'Haptic feedback disabled'),
                    backgroundColor: isDarkMode ? Colors.grey[700] : null,
                  ),
                );
              },
              activeThumbColor: Colors.blue,
            ),
            onTap: () {},
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDarkMode ? Colors.blue[200] : Colors.blue),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Divider(
        height: 1,
        color: isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
      ),
    );
  }

  void _manageRoutePresets() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route presets management coming soon!')),
    );
  }
}
