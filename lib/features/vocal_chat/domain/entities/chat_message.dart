/// Rôle d'un message dans la conversation.
enum ChatRole {
  /// Message de l'utilisateur
  user,
  /// Message de l'assistant (LLM)
  assistant,
}

/// Entité représentant un message dans une conversation vocale.
class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// Convertit le message au format attendu par l'API OpenRouter.
  Map<String, String> toApiFormat() => {
        'role': role == ChatRole.user ? 'user' : 'assistant',
        'content': content,
      };

  @override
  String toString() =>
      'ChatMessage(id: $id, role: $role, content: ${content.length} chars)';
}
