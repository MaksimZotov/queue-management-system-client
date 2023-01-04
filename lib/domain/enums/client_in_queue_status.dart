enum ClientInQueueStatus {
  inQueue("IN_QUEUE"),
  reserved("RESERVED");

  final String name;
  const ClientInQueueStatus(this.name);

  static ClientInQueueStatus? get(String? name) {
    if (name == ClientInQueueStatus.inQueue.name) {
      return ClientInQueueStatus.inQueue;
    }
    if (name == ClientInQueueStatus.reserved.name) {
      return ClientInQueueStatus.reserved;
    }
    return null;
  }
}