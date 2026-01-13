class Referent {
  final String id;
  final String name;
  final String email;
  final String role;
  final String category; // Nouvelle propriété

  const Referent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.category,
  });
}