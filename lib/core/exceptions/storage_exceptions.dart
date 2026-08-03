/// Thrown when a download or write cannot be completed because the device
/// has run out of storage space.
class StorageFullException implements Exception {
  const StorageFullException(this.message);

  final String message;

  @override
  String toString() => message;
}
