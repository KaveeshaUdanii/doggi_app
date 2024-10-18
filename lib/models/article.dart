class Article {
  final String title;
  final String description;
  final String author;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.author,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
      author: json['author'] ?? 'Unknown Author',
      url: json['url'],
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }
}
