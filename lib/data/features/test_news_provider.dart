import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_feed/data/models/news_item.dart';

/// A test provider with hardcoded random news items to test layout edge cases.
final testNewsProvider = FutureProvider<List<NewsItem>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));

  return [
    // Edge Case 1: Extremely long title and description
    NewsItem(
      title:
          'BREAKING: Scientists have discovered an incredibly rare phenomenon in the outer reaches of the galaxy that challenges our fundamental understanding of physics and the universe itself, potentially rewriting textbooks for generations to come ' *
              2,
      description:
          'In a groundbreaking study published today, researchers from top institutions around the world have detailed their findings regarding a mysterious signal detected from deep space. '
          'The signal, which appears to be repeating at irregular intervals, contains patterns that some speculate could be artificial in origin, though most experts remain skeptical and suggest natural astrophysical processes are likely at play. ' *
              10, // Very long description
      link: 'https://example.com/long-article',
      imageUrl: 'https://picsum.photos/seed/1/800/600',
      author: 'Dr. Christopher A. Verylongname III, PhD, MD, Nobel Laureate',
      publishedAt: DateTime.now(),
      source: 'The Daily Intergalactic & Universal News Network Associated Press',
      category: 'Science',
    ),

    // Edge Case 2: Minimal content (empty strings where possible/logical)
    NewsItem(
      title: 'Short Title',
      description: 'Short desc.',
      link: 'https://example.com/short',
      imageUrl: 'https://picsum.photos/seed/2/800/600',
      author: 'A. B.',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      source: 'BBC',
      category: 'World',
    ),

    // Edge Case 3: No spaces in title (simulating a very long word/url)
    NewsItem(
      title: 'Supercalifragilisticexpialidocious_Antidisestablishmentarianism_Pneumonoultramicroscopicsilicovolcanoconiosis',
      description: 'A test case for text wrapping when there are no spaces in the content.',
      link: 'https://example.com/nospaces',
      imageUrl: 'https://picsum.photos/seed/3/800/600',
      author: 'Tester',
      publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      source: 'Tech',
      category: 'Technology',
    ),

    // Edge Case 4: Special characters and Emojis
    NewsItem(
      title: '🎉 🚀 WARNING: System Update Required! [CRITICAL ERROR] <Code: 404> ⚠️',
      description:
          'Testing unicode characters: ∆ ≈ ≠ ≤ ≥ ∑ ∫ ∞ mixed with normal text. Also emojis: 😀 😎 🚀 🌈 🔥. ' * 5,
      link: 'https://example.com/emoji',
      imageUrl: 'https://picsum.photos/seed/4/800/600',
      author: 'Robot 🤖',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      source: 'Emoji Central',
      category: 'Fun',
    ),
    
    // Normal case for contrast
    NewsItem(
      title: 'Market hits record high as tech stocks rally',
      description: 'The S&P 500 reached a new all-time high today, driven by strong earnings reports from major technology companies.',
      link: 'https://example.com/market',
      imageUrl: 'https://picsum.photos/seed/5/800/600',
      author: 'Jane Doe',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      source: 'Finance Daily',
      category: 'Finance',
    ),
  ];
});
