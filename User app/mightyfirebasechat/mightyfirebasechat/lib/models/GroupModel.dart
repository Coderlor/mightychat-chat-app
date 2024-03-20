class GroupModel {
  String? createdBy;
  DateTime? createdOn;
  String? descriptionId;
  String? adminId;
  String? fltrdId;
  String isTypingID;
  int? latestTimeStamp;
  List<String>? membersList;
  String? name;
  String? photoUrl;
  String? groupType;
  bool isEncrypt;
  List<String>? caseSearch;
  List<String>? adminIds;

  GroupModel({
    this.createdBy,
    this.createdOn,
    this.descriptionId,
    this.adminId,
    this.fltrdId,
    this.isTypingID = '',
    this.latestTimeStamp,
    this.membersList,
    this.name,
    this.photoUrl = '',
    this.groupType,
    this.isEncrypt = false,
    this.caseSearch,
    this.adminIds,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      createdBy: json['createdBy'],
      createdOn: json['createdOn'],
      descriptionId: json['descriptionId'],
      fltrdId: json['fltrdId'],
      adminId: json['adminId'],
      isTypingID: json['isTypingID'],
      latestTimeStamp: json['latestTimeStamp'],
      membersList: json['membersList'] != null ? json['membersList'].cast<String>() : [],
      name: json['name'],
      photoUrl: json['photoUrl'],
      groupType: json['groupType'],
      isEncrypt: json['isEncrypt'],
      caseSearch: json['searchCase'],
      adminIds: json['adminIds'] != null ? json['adminIds'].cast<String>() : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['descriptionId'] = this.descriptionId;
    data['fltrdId'] = this.fltrdId;
    data['adminId'] = this.adminId;
    data['isTypingID'] = this.isTypingID;
    data['latestTimeStamp'] = this.latestTimeStamp;
    data['membersList'] = this.membersList;
    data['name'] = this.name;
    data['photoUrl'] = this.photoUrl;
    data['groupType'] = this.groupType;
    data['isEncrypt'] = this.isEncrypt;
    data['searchCase'] = this.caseSearch;
    data['adminIds'] = this.adminIds;
    return data;
  }
}
