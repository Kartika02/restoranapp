import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/providers/detail/readmore_provider.dart';

class ExpandableDescription extends StatefulWidget {
  final String text;

  const ExpandableDescription({super.key, required this.text});

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadMoreProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: Text(
                widget.text,
                maxLines: provider.expanded ? null : 3,
                overflow: provider.expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                provider.toggleExpanded();
              },
              child: Text(
                provider.expanded ? "Read Less" : "Read More",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
