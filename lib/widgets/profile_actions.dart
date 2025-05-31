import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/widgets/change_password.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            const double minButtonWidth = 180;
            int buttonsPerRow = (maxWidth / minButtonWidth).floor();
            buttonsPerRow = buttonsPerRow > 0 ? buttonsPerRow : 1;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildResponsiveButton(
                  label: 'Modifica contrasenya',
                  icon: Icons.settings,
                  color: Colors.blueAccent,
                  onPressed: () {
                    authController.togglePasswordCard();
                  },
                  width: maxWidth / buttonsPerRow - 12,
                ),
                if (authController.currentWorker.value.role == "admin") ...[
                  _buildResponsiveButton(
                    label: 'Crea nova location',
                    icon: Icons.create,
                    color: Colors.blueAccent,
                    onPressed: () {
                      Get.toNamed(AppRoutes.locationRegister);
                    },
                    width: maxWidth / buttonsPerRow - 12,
                  ),
                  _buildResponsiveButton(
                    label: 'Crea nou treballador',
                    icon: Icons.create,
                    color: Colors.blueAccent,
                    onPressed: () {},
                    width: maxWidth / buttonsPerRow - 12,
                  ),
                ],
                _buildResponsiveButton(
                  label: 'Tanca sessió',
                  icon: Icons.logout,
                  color: Colors.redAccent,
                  onPressed: () {
                    authController.logout();
                  },
                  width: maxWidth / buttonsPerRow - 12,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        Obx(
          () =>
              authController.showPasswordCard.value
                  ? PasswordChangeCard()
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildResponsiveButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
