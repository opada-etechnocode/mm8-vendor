import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/widgets/business_setup_guideline.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class MyShopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const MyShopAppBar({super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(title!,
            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color)
          ),
        ),
        centerTitle: false,
        leading:  Consumer<ShopController>(
          builder: (context, shopInfo, child) {
            return IconButton(icon: const Icon(Icons.arrow_back_ios, size: Dimensions.iconSizeDefault),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(shopInfo.myShopPageIndex != 0) {
                  shopInfo.setShopPageIndex(0, isUpdate: true);
                }else {
                  Future.microtask(() {
                    Navigator.of(Get.context!).pop();
                  });
                }
              }
            );
          }
        ),

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 7),
        actions: [
          Material(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).cardColor,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return const BusinessSetupGuideline();
                  },
                );
              } ,
              child:  SizedBox(
                width: 44,
                height: 44,
                child: Center(child: Icon(Icons.info_outline,color: Theme.of(context).primaryColor,)),
              )
            )
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeMedium,
              0,
              Dimensions.paddingSizeMedium,
              Dimensions.paddingSizeSmall,
            ),
            child: Consumer<ShopController>(
              builder: (context, shopInfo, child) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Button(
                          isSelected: shopInfo.myShopPageIndex == 0,
                          title: getTranslated('shop_details', context) ?? '',
                          onPressed: () {
                            shopInfo.setShopPageIndex(0);
                          },
                        ),
                      ),
                      Expanded(
                        child: Button(
                          isSelected: shopInfo.myShopPageIndex == 1,
                          title: getTranslated('payment_info', context) ?? '',
                          onPressed: () {
                            shopInfo.setShopPageIndex(1);
                          },
                        ),
                      ),
                      Expanded(
                        child: Button(
                          isSelected: shopInfo.myShopPageIndex == 2,
                          title: getTranslated('other_setup', context) ?? '',
                          onPressed: () {
                            shopInfo.setShopPageIndex(2);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size(double.maxFinite, 108);
}



class Button extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function? onPressed;
  const Button({
    super.key,
    required this.isSelected,
    required this.title,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          onPressed!();
        },
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: isSelected ?
              robotoBold.copyWith(color: Theme.of(context).highlightColor, fontSize: Dimensions.fontSizeSmall) :
              robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall)
            ),
          ),
        ),
      ),
    );
  }
}
