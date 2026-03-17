import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  static const String wsUrl = 'ws://localhost:8080/ws/voice';
  
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    try {
      print('[WebSocket] Connecting to $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            print('[WebSocket] Received: $data');
            _messageController.add(data);
          } catch (e) {
            print('[WebSocket] Error parsing message: $e');
          }
        },
        onError: (error) {
          print('[WebSocket] Error: $error');
          _messageController.addError(error);
        },
        onDone: () {
          print('[WebSocket] Connection closed');
          _channel = null;
        },
      );
      
      print('[WebSocket] Connected successfully');
    } catch (e) {
      print('[WebSocket] Connection failed: $e');
      _messageController.addError(e);
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      try {
        final message = jsonEncode(data);
        print('[WebSocket] Sending: $message');
        _channel!.sink.add(message);
      } catch (e) {
        print('[WebSocket] Error sending message: $e');
      }
    } else {
      print('[WebSocket] Not connected, cannot send message');
    }
  }

  void disconnect() {
    try {
      _channel?.sink.close();
      _channel = null;
      print('[WebSocket] Disconnected');
    } catch (e) {
      print('[WebSocket] Error disconnecting: $e');
    }
  }
}
