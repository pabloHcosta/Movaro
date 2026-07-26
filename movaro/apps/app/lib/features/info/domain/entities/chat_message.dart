/// A message exchanged with Movaro's local, deterministic assistant.
class ChatMessage {
  const ChatMessage({required this.role, required this.text, this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    text: json['text'] as String,
    timestamp: json['ts'] != null
        ? DateTime.tryParse(json['ts'] as String)
        : null,
  );

  final String role;
  final String text;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    if (timestamp != null) 'ts': timestamp!.toIso8601String(),
  };
}
