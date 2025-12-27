class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class WebSocketException implements Exception {
  final String message;
  
  const WebSocketException(this.message);
  
  @override
  String toString() => 'WebSocketException: $message';
}

class ConnectionException implements Exception {
  final String message;
  
  const ConnectionException(this.message);
  
  @override
  String toString() => 'ConnectionException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}