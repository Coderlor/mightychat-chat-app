class LogModel {
  int? logId;
  String? callerName;
  String? callerPic;
  String? receiverName;
  String? receiverPic;
  String? callStatus;
  String? callType;
  String? timestamp;
  String? callerId;
  String? receiverId;
  // String? recieverPlayerId;

  LogModel(
      {this.logId, this.callerName, this.callerPic, this.receiverName, this.receiverPic, this.callStatus, this.callType, this.callerId, this.receiverId, this.timestamp /*, this.recieverPlayerId*/});
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
        logId: json['log_id'],
        callerName: json['caller_name'],
        callerPic: json['caller_pic'],
        receiverName: json['receiver_name'],
        receiverPic: json['receiver_pic'],
        callType: json['callType'],
        callStatus: json['call_status'],
        timestamp: json['timestamp'],
        callerId: json['callerId'],
        receiverId: json['receiverId']
        //  recieverPlayerId: json['recieverPlayerId']
        );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['log_id'] = this.logId;
    data['caller_name'] = this.callerName;
    data['caller_pic'] = this.callerPic;
    data['receiver_name'] = this.receiverName;
    data['receiver_pic'] = this.receiverPic;
    data['call_status'] = this.callStatus;
    data['timestamp'] = this.timestamp;
    data['callType'] = this.callType;
    data['callerId'] = this.callerId;
    data['receiverId'] = this.receiverId;
    // data['recieverPlayerId'] = this.recieverPlayerId;
    return data;
  }
}
// to map
