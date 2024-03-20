class DeviceModel {
  String? uid;
  String? deviceId;
  String? webDeviceId;
  String? currentTime;
  bool? isOnWeb;

  DeviceModel({
    this.uid,
    this.deviceId,
    this.webDeviceId,
    this.currentTime,
    this.isOnWeb,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      uid: json['uid'],
      deviceId: json['deviceId'],
      webDeviceId: json['webDeviceId'],
      currentTime: json['currentTime'],
      isOnWeb: json['isOnWeb'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['deviceId'] = this.deviceId;
    data['webDeviceId'] = this.webDeviceId;
    data['currentTime'] = this.currentTime;
    data['isOnWeb'] = this.isOnWeb;

    return data;
  }

}
