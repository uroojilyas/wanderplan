import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifications = true;

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SizedBox(height: 16),
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    widget.username.isNotEmpty ? widget.username[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text('${widget.username.toLowerCase()}@wanderplan.app',
                style: const TextStyle(color: AppTheme.textMid, fontSize: 14)),

            const SizedBox(height: 32),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat('12', 'Trips'),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  _stat('47', 'Places'),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  _stat('5', 'Countries'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft,
                child: Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark))),
            const SizedBox(height: 12),

            // Settings tiles
            _tile(Icons.person_outline, 'Edit Profile', () {}),
            _tile(Icons.email_outlined, 'Email Settings', () {}),
            _tile(Icons.lock_outline, 'Change Password', () {}),
            // Notifications with toggle
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                const SizedBox(width: 14),
                const Expanded(child: Text('Notifications', style: TextStyle(fontSize: 15, color: AppTheme.textDark))),
                Switch(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  activeThumbColor: AppTheme.primary,
                ),
              ]),
            ),
            _tile(Icons.help_outline, 'Help & Support', () {}),

            const SizedBox(height: 8),
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
    Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
  ]);

  Widget _tile(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textDark))),
        const Icon(Icons.chevron_right, color: AppTheme.textMid),
      ]),
    ),
  );
}
