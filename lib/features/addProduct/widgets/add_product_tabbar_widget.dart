import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';


class AddProductTitleBar extends StatelessWidget {
  final TabController tabController;
  const AddProductTitleBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = <Tab>[
      Tab(text: getTranslated('general_info', context) ?? 'General Info'),
      Tab(text: getTranslated('variations', context) ?? 'Variations'),
      Tab(text: getTranslated('seo', context) ?? 'SEO'),
    ];

    return TabBar(
      controller: tabController,
      tabs: tabs,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelColor: Theme.of(context).highlightColor,
      unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
      unselectedLabelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
