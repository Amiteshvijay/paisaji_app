import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class DeviceDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? deviceData;

  const DeviceDetailScreen({
    super.key,
    this.deviceData,
  });

  @override
  ConsumerState<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> {
  String _osVersion = 'Android 16';
  String _appVersion = '1.0.0+1';
  String _deviceUid = 'ZK-DEV-8D0C-221F-94B2';
  String _ipAddress = '192.168.1.105';

  @override
  void initState() {
    super.initState();
    _loadDeviceMeta();
  }

  Future<void> _loadDeviceMeta() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        setState(() {
          _osVersion = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
          _appVersion = '${pkg.version}+${pkg.buildNumber}';
          _deviceUid = android.id.isNotEmpty ? android.id : 'ZK-8D0C-221F-94B2';
        });
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        setState(() {
          _osVersion = '${ios.systemName} ${ios.systemVersion}';
          _appVersion = '${pkg.version}+${pkg.buildNumber}';
          _deviceUid = ios.identifierForVendor ?? 'ZK-IOS-UUID';
        });
      }

      // Get real local IP address
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            setState(() {
              _ipAddress = addr.address;
            });
            break;
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final devName = widget.deviceData?['device_name'] ?? 'OPPO CPH2729';
    final platform = widget.deviceData?['platform'] ?? 'ANDROID';
    
    // Format timestamp nicely with date and time
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final formattedDate = '${months[now.month - 1]} ${now.day}, ${now.year}, ${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    final lastActive = 'Active now ($formattedDate)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Center(child: Icon(Icons.phone_android, size: 64, color: AppTheme.primaryBlue)),
                    const SizedBox(height: 16),
                    Center(child: Text(devName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20))),
                    const SizedBox(height: 4),
                    const Center(child: Text('Trusted Primary Registered Device', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 13))),
                    const Divider(height: 32, color: AppTheme.border),
                    _buildInfoRow('Device UID', _deviceUid),
                    const SizedBox(height: 12),
                    _buildInfoRow('Platform', platform),
                    const SizedBox(height: 12),
                    _buildInfoRow('OS Version', _osVersion),
                    const SizedBox(height: 12),
                    _buildInfoRow('App Version', _appVersion),
                    const SizedBox(height: 12),
                    _buildInfoRow('IP Address', _ipAddress),
                    const SizedBox(height: 12),
                    _buildInfoRow('Last Active', lastActive),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'This is my current device',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
