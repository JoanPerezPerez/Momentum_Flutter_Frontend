import 'package:momentum/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService._();

  static Future<SocketService> create() async {
    final service = SocketService._();
    await service._initSocket();
    return service;
  }

  Future<void> _initSocket() async {
    final accessToken = await ApiService.secureStorage.read(
      key: 'access_token',
    );
    socket = IO.io(
      //'http://localhost:8080',
      'https://ea5-api.upc.edu',
      IO.OptionBuilder()
          .setTransports(['polling', 'websocket']) // com fa el navegador
          .setAuth({'token': accessToken})
          .enableAutoConnect()
          .build(),
    );
    socket.onConnect((_) {
      print('Connected to socket.io');
    });

    socket.onDisconnect((_) => print('Disconnected from socket'));
  }

  void listen(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  void disconnect() {
    socket.disconnect();
  }
}
