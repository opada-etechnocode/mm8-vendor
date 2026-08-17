
class NotificationBody {
  int? orderId;
  int? orderDetailsId;
  int? refundId;
  int? senderId;
  String? type;
  String? messageKey;
  String? senderName;
  String? title;

  NotificationBody({
    this.orderId,
    this.orderDetailsId,
    this.refundId,
    this.senderId,
    this.type,
    this.messageKey,
    this.senderName,
    this.title,
  });

  NotificationBody.fromJson(Map<String, dynamic> json) {
    orderId = _toInt(json['order_id'] ?? json['orderId']);
    orderDetailsId = _toInt(json['order_details_id'] ?? json['orderDetailsId']);
    refundId = _toInt(json['refund_id'] ?? json['refundId']);
    senderId = _toInt(
      json['sender_id'] ??
      json['sent_by'] ??
      json['user_id'] ??
      json['customer_id'] ??
      json['delivery_man_id'],
    );
    type = _toString(json['type'] ?? json['notification_type']);
    messageKey = _toString(json['message_key'] ?? json['messageKey']);
    senderName = _toString(json['sender_name'] ?? json['name'] ?? json['f_name'] ?? json['title']);
    title = _toString(json['title']);
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_details_id': orderDetailsId,
      'refund_id': refundId,
      'sender_id': senderId,
      'type': type,
      'message_key': messageKey,
      'sender_name': senderName,
      'title': title,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text == 'null' || text == '0') {
      return null;
    }
    return int.tryParse(text);
  }

  static String? _toString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }
}
