class Quote {
  const Quote({
    required this.id,
    required this.text,
    required this.author,
  });

  final int id;
  final String text;
  final String author;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      text: json['quote'] as String,
      author: json['author'] as String,
    );
  }
}
