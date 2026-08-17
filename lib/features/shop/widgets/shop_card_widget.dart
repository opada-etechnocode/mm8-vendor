import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/screens/shop_update_screen.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ShopCardWidget extends StatelessWidget {
  const ShopCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return  Consumer<ShopController>(
      builder: (context, shopInfo, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).hintColor.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: double.infinity,
                  height: 128,
                  child: CustomImageWidget(image: '${shopInfo.shopModel?.bannerFullUrl?.path}'),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context).hintColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: CustomImageWidget(image: '${shopInfo.shopModel?.imageFullUrl?.path}'),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shopInfo.shopModel?.name ?? '',
                                  style: robotoBold.copyWith(
                                    color: Theme.of(context).textTheme.titleMedium?.color,
                                    fontSize: Dimensions.fontSizeLarge, height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${getTranslated('created_at', context)} ${DateConverter.localToIsoString(DateTime.parse(shopInfo.shopModel!.createdAt!))}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall, height: 1.2)
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopUpdateScreen())),
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 44,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      const CustomAssetImageWidget(Images.myShopEditIcon, width: 15, height: 15),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        getTranslated('edit', context) ?? '',
                                        style: robotoBold.copyWith(color: Theme.of(context).highlightColor)
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeMedium),

                      Row(
                        children: [
                          Expanded(
                            child: ShopInfoCard(
                              title: getTranslated('products', context) ?? '',
                              count: shopInfo.shopModel?.totalProducts.toString() ?? '0',
                              image: Images.productsIcon,
                              color: Theme.of(context).colorScheme.surfaceTint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ShopInfoCard(
                              title: getTranslated('orders', context) ?? '',
                              count: shopInfo.shopModel?.totalOrder.toString() ?? '0',
                              image: Images.orderIcon,
                              color: ColorHelper.darken(Theme.of(context).colorScheme.onSecondary, 0.1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ShopInfoCard(
                              title: getTranslated('reviews', context) ?? '',
                              count: shopInfo.shopModel?.totalReview.toString() ?? '0',
                              image: Images.reviewsIcon,
                              color: ColorHelper.darken(Theme.of(context).colorScheme.onTertiaryContainer, 0.1),
                            ),
                          ),
                        ],
                      ),

                      if(shopInfo.shopModel?.taxIdentificationNumber != null && shopInfo.shopModel?.tinExpireDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).hintColor.withValues(alpha: 0.06),
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${getTranslated('tin', context)} : ${shopInfo.shopModel?.taxIdentificationNumber}",
                                      style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${getTranslated('exp', context)} : ${ DateConverter.localToIsoString(DateTime.parse(shopInfo.shopModel?.tinExpireDate ?? ''))}",
                                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)
                                    ),
                                  ],
                                ),
                              ),
                              const CustomAssetImageWidget(Images.tinIdIcon, width: 20, height: 20),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      }
    );
  }
}


class ShopInfoCard extends StatelessWidget {
  final String title;
  final String count;
  final String image;
  final Color? color;
  final double? width;
  const ShopInfoCard({super.key, required this.title, required this.count, required this.image, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).hintColor.withValues(alpha: 0.06),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomAssetImageWidget(image, width: 18, height: 18),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(
              color: color,
              fontSize: Dimensions.fontSizeExtraLargeTwenty,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)
          ),
        ],
      ),
    );
  }
}
