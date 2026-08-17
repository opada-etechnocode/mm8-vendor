import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'dart:ui' as ui;


class TopMostProductWidget extends StatelessWidget{
  final Product? productModel;
  final bool isPopular;
  final String? totalSold;
  const TopMostProductWidget({super.key, this.productModel, this.isPopular = false, this.totalSold});

  @override
  Widget build(BuildContext context) {

    double ratting = (productModel?.rating?.isNotEmpty ?? false) ?  double.parse('${productModel?.rating?[0].average}') : 0;

    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return GestureDetector(
      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productModel: productModel))),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: isDark ? 0.18 : 0.10)),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: ColoredBox(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                      child: CachedNetworkImage(
                        placeholder: (ctx, url) => Image.asset(Images.placeholderImage, fit: BoxFit.cover),
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => Image.asset(Images.placeholderImage, fit: BoxFit.cover),
                        imageUrl: productModel?.thumbnailFullUrl?.path ?? '',
                      ),
                    ),
                  ),
                ),

                isPopular ? const SizedBox() : Positioned(
                  left: 8, right: 8, bottom: 8,
                  child: Center(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Text('${NumberFormat.compact().format(double.parse(totalSold!))} ${getTranslated('sold', context)}',
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),),
                  )),
                ),

               if(hasDiscount())
                 DiscountTagWidget(positionedTop: 8, positionedLeft: 0, positionedRight: 0, productModel: productModel!),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(productModel!.name!.trim(), textAlign: TextAlign.start, style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                if(hasDiscount()) ...[
                  Flexible(
                    child: Text(PriceConverter.convertPrice(context, productModel?.unitPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    PriceConverter.convertPrice(
                      context, productModel?.unitPrice,
                      discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                        ? productModel?.clearanceSale?.discountType
                        : productModel?.discountType,
                      discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                        ? productModel?.clearanceSale?.discountAmount
                        : productModel?.discount
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      color: isDark ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ]),
              if(ratting > 0) Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.star_rate_rounded, color: Colors.orange, size: 14),
                  const SizedBox(width: 2),
                  Text(ratting.toStringAsFixed(1), style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.1,
                  )),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text('(${PriceConverter.longToShortPrice(productModel?.reviewsCount?.toDouble() ?? 0, withDecimalPoint: false)})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor, height: 1.1),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  bool hasDiscount() => (productModel?.discount != null && productModel!.discount! > 0) || (productModel?.clearanceSale?.discountAmount ?? 0) > 0;

}



class DiscountTagWidget extends StatelessWidget {
  const DiscountTagWidget({
    super.key,
    required this.productModel,
    this.positionedTop = 10,
    this.positionedLeft = 0,
    this.positionedRight = 0,
    this.topLeftBorderRadius = 0,
    this.bottomRightBorderRadius = 0,
  });

  final Product productModel;
  final double positionedTop;
  final double positionedLeft;
  final double positionedRight;
  final double? topLeftBorderRadius;
  final double? bottomRightBorderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Positioned(
        top: positionedTop, left: isLtr ? positionedLeft : null, right: !isLtr ? positionedRight : null,
        child: Container(
          transform: Matrix4.translationValues(-1, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(isLtr ? Dimensions.paddingSizeSmall : 0),
              topRight: Radius.circular(isLtr ?  Dimensions.paddingSizeSmall : 0),
              bottomLeft: Radius.circular(!isLtr ? Dimensions.paddingSizeSmall : 0),
              topLeft: Radius.circular(!isLtr ? Dimensions.paddingSizeSmall : 0),
            )
          ),
          child: Center(
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  productModel.clearanceSale != null ?
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.clearanceSale?.discountAmount, productModel.clearanceSale?.discountType) :
                  PriceConverter.percentageCalculation(context, productModel.unitPrice, productModel.discount, productModel.discountType),
                  style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,
                ),
              )
          ),
        )
    );
  }
}