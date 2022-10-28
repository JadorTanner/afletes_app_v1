class NotificationModel {
  int id, negotiationId, userId, senderId;
  String mensaje, sentAt;
  bool visto;
  NotificationModel({
    this.id = 0,
    this.senderId = 0,
    this.mensaje = '',
    this.sentAt = '',
    this.negotiationId = 0,
    this.userId = 0,
    this.visto = false,
  });
}
