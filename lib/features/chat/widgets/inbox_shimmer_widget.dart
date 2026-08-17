import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';



class InboxShimmerWidget extends StatelessWidget {
  const InboxShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color highlight = isDark ? Colors.grey[500]! : Colors.grey[100]!;
    final Color block = Theme.of(context).colorScheme.secondaryContainer;

    return Expanded(
      child: ListView.builder(
        itemCount: 8,
        padding: const EdgeInsets.only(top: 4, bottom: Dimensions.paddingSizeDefault),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(Dimensions.paddingSizeMedium, 4, Dimensions.paddingSizeMedium, 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).hintColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  ),
                ),
                child: Row(children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: block),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Container(height: 14, color: block)),
                        const SizedBox(width: 12),
                        Container(height: 10, width: 40, color: block),
                      ]),
                      const SizedBox(height: 10),
                      Container(height: 12, width: double.infinity, color: block),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
