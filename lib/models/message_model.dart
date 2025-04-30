class ChatMessage {
  final String from;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.from,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      from: json['from'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
