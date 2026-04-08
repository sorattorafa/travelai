import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> showOptions(
    BuildContext context,
    String address,
  ) async {
    final encoded = Uri.encodeComponent(address);

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Abrir rota em...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (Platform.isIOS)
                _MapOption(
                  icon: Icons.map_outlined,
                  label: 'Apple Maps',
                  color: const Color(0xFF34C759),
                  url: 'https://maps.apple.com/?daddr=$encoded&dirflg=d',
                ),
              _MapOption(
                icon: Icons.travel_explore,
                label: 'Google Maps',
                color: const Color(0xFF4285F4),
                url:
                    'https://www.google.com/maps/dir/?api=1&destination=$encoded',
              ),
              _MapOption(
                icon: Icons.navigation_outlined,
                label: 'Waze',
                color: const Color(0xFF00BFFF),
                url: 'https://waze.com/ul?q=$encoded&navigate=yes',
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const _MapOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () async {
        Navigator.pop(context);
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
