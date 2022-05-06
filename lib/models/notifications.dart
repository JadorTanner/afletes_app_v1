class NotificationModel {
  int id, negotiationId, userId, senderId;
  String mensaje, sentAt;
  NotificationModel({
    this.id = 0,
    this.senderId = 0,
    this.mensaje = '',
    this.sentAt = '',
    this.negotiationId = 0,
    this.userId = 0,
  });
}
