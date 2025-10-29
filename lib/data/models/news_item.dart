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
}
