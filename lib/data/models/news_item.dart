class NewsItem {
  final String title;
  final String description;
  final String link;
  final String imageUrl;
  final String author;
  final DateTime publishedAt;
  final String source;
  final String category;

  const NewsItem({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.source,
    required this.category,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      imageUrl: json['image_url'] ?? '',
      author: json['author'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      source: json['source'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'image_url': imageUrl,
      'author': author,
      'published_at': publishedAt.toIso8601String(),
      'source': source,
      'category': category,
    };
  }
}
