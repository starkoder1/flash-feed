class NotificationNewsModel {
  final String title;
  final String source;
  final String imgUrl;

  NotificationNewsModel({
    required this.title,
    required this.source,
    required this.imgUrl,
  });

  factory NotificationNewsModel.fromJson(Map<String, dynamic> json) {
    return NotificationNewsModel(
      title: json['title'] ?? '',
      source: json['source'] ?? '',
      imgUrl: json['imgUrl'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'source': source,
      'imgUrl': imgUrl,
    };
  }
}
