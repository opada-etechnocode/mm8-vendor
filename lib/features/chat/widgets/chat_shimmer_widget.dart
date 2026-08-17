import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmerWidget extends StatelessWidget {
  const ChatShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color highlight = isDark ? Colors.grey[500]! : Colors.grey[100]!;
    final Color block = Theme.of(context).colorScheme.secondaryContainer;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {

          bool isMe = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              enabled: true,
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Container(height: 30, width: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: block)),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    height: 42,
                    width: MediaQuery.of(context).size.width * (isMe ? 0.45 : 0.52),
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: const Radius.circular(18),
                        topEnd: const Radius.circular(18),
                        bottomStart: Radius.circular(isMe ? 18 : 6),
                        bottomEnd: Radius.circular(isMe ? 6 : 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
