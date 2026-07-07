// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/screens/authentication/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      backgroundColor: AppTheme.darkGray,
      elevation: 15,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userData.username.isNotEmpty ? userData.username : "Loading...",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
            accountEmail: Text(
              userData.email.isNotEmpty ? userData.email : "Loading...",
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.green,
              backgroundImage: userData.imageFile != null
                  ? FileImage(userData.imageFile!) as ImageProvider
                  : (userData.imageUrl != null && userData.imageUrl!.isNotEmpty)
                  ? NetworkImage(userData.imageUrl!)
                  : null,
              child:
                  (userData.imageFile == null &&
                      (userData.imageUrl == null || userData.imageUrl!.isEmpty))
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.lightGray,
                    )
                  : null,
            ),
            decoration: const BoxDecoration(color: AppTheme.green),
          ),
          _buildEditableTile(
            context,
            title: "Username",
            value: userData.username,
            onEdit: () => _showEditDialog(
              context,
              title: "Edit Username",
              initialValue: userData.username,
              onSave: (val) async {
                try {
                  await userData.updateUsername(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Username updated successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll("Exception: ", "")),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          _buildEditableTile(
            context,
            title: "Name",
            value: userData.name,
            onEdit: () => _showEditDialog(
              context,
              title: "Edit Name",
              initialValue: userData.name,
              onSave: (val) => userData.updateName(val),
            ),
          ),
          _buildEditableTile(
            context,
            title: "Bio",
            value: userData.bio,
            onEdit: () => _showEditDialog(
              context,
              title: "Edit Bio",
              initialValue: userData.bio,
              onSave: (val) => userData.updateBio(val),
            ),
          ),
          _buildEditableTile(
            context,
            title: "Password",
            value: "********",
            onEdit: () => _showEditDialog(
              context,
              title: "Change Password",
              isPassword: true,
              onSave: (val) => userData.updatePassword(val),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.lightGray),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.darkGray,
                  title: const Text(
                    "Confirm Logout",
                    style: TextStyle(color: AppTheme.lightGray),
                  ),
                  content: const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(color: AppTheme.lightGray),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Cancel
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppTheme.lightGray),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog first

                        // Perform logout
                        await auth.logout();
                        userData.clearUserData();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTile(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: AppTheme.lightGray)),
      subtitle: Text(value, style: TextStyle(color: AppTheme.lightGrayBlue)),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: AppTheme.green),
        onPressed: onEdit,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    String initialValue = "",
    bool isPassword = false,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: Text(title, style: TextStyle(color: AppTheme.lightGray)),
        content: TextField(
          cursorColor: AppTheme.lightGrayBlue,
          controller: controller,
          style: TextStyle(color: AppTheme.lightGrayBlue),
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: isPassword ? "New Password" : null,
            labelStyle: TextStyle(color: AppTheme.lightGrayBlue),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ), // bottom border when focused
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppTheme.lightGray),
            ),
          ),
          TextButton(
            onPressed: () async {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                await onSave(value);
              }
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: AppTheme.green)),
          ),
        ],
      ),
    );
  }
}
