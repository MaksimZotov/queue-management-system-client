enum ClientInQueueStatus {
  confirmed('CONFIRMED'),
  reserved('RESERVED');

  final String name;
  const ClientInQueueStatus(this.name);

  static ClientInQueueStatus? get(String? name) {
    if (name == ClientInQueueStatus.confirmed.name) {
      return ClientInQueueStatus.confirmed;
    }
    if (name == ClientInQueueStatus.reserved.name) {
      return ClientInQueueStatus.reserved;
    }
    return null;
  }
}