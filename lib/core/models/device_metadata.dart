class DeviceMetadata {
  final String deviceId;
  final String installationId;
  final String? androidId;
  final String deviceName;
  final String manufacturer;
  final String model;
  final String platform;
  final String osVersion;
  final String appVersion;
  final String? publicKey;

  const DeviceMetadata({
    required this.deviceId,
    required this.installationId,
    this.androidId,
    required this.deviceName,
    required this.manufacturer,
    required this.model,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    this.publicKey,
  });

  Map<String, dynamic> toPayload() {
    return {
      'device_id': deviceId,
      'installation_id': installationId,
      if (androidId != null) 'android_id': androidId,
      'device_name': deviceName,
      'manufacturer': manufacturer,
      'model': model,
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
      if (publicKey != null) 'public_key': publicKey,
    };
  }
}
