class MessageModel {
  late final String msg;
  late final String toId;
  late final String read;
  late final Type type;
  late final String sent;
  late final String fromId;

  MessageModel({
    required this.msg,
    required this.toId,
    required this.read,
    required this.type,
    required this.sent,
    required this.fromId,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image: Type.text;
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    return data;
  }
}
enum Type{text, image}
