class ChatMessageModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? photoUrl;
  String? messageType;
  bool? isMe;
  bool? isMessageRead;
  String? message;
  String? stickerPath;
  int? status;
  int? createdAt;
  String? currentLat;
  String? currentLong;
  bool? isEncrypt;
  Map<String, dynamic>? readBy = {};
  ChatMessageModel(
      {this.id,
      this.senderId,
      this.receiverId,
      this.createdAt,
      this.message,
      this.isMessageRead,
      this.photoUrl,
      this.status,
      this.messageType,
      this.stickerPath,
      this.currentLat,
      this.currentLong,
      this.isEncrypt,
      this.readBy});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
        id: json['id'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        message: json['message'],
        isMessageRead: json['isMessageRead'],
        photoUrl: json['photoUrl'],
        messageType: json['messageType'],
        stickerPath: json['stickerPath'],
        status: json['status'],
        createdAt: json['createdAt'],
        currentLat: json['currentLat'],
        currentLong: json['currentLong'],
        isEncrypt: json['isEncrypt'],
        readBy: json['readBy']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['message'] = this.message;
    data['senderId'] = this.senderId;
    data['isMessageRead'] = this.isMessageRead;
    data['receiverId'] = this.receiverId;
    data['photoUrl'] = this.photoUrl;
    data['stickerPath'] = this.stickerPath;
    data['status'] = this.status;
    data['messageType'] = this.messageType;
    data['currentLat'] = this.currentLat;
    data['currentLong'] = this.currentLong;
    data['isEncrypt'] = this.isEncrypt;
    data['readBy'] = this.readBy;
    return data;
  }
}
