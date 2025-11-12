import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlaceholderNewsCard extends StatelessWidget {
  const PlaceholderNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12)
                  .copyWith(top: 10, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore.",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding:
                    const EdgeInsets.only(right: 20, bottom: 15, left: 12),
                child: Row(
                  children: [
                    Text(
                      "Source • 01 JAN 2025",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    const Icon(Icons.share),
                    const SizedBox(width: 15),
                    const Icon(Icons.bookmark_border),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
