import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/top_selling_product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/title_row_widget.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/top_most_product_card_widget.dart';

class TopSellingProductScreen extends StatelessWidget {
  final bool isMain;
  final ScrollController? scrollController;
  const TopSellingProductScreen({super.key, this.isMain = false, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        Provider.of<ProductController>(context,listen: false).getTopSellingProductList(1, context, 'en');
      },
      child: Consumer<ProductController>(
        builder: (context, prodProvider, child) {
          List<Products>? productList;
          productList = prodProvider.topSellingProductModel?.products;

          return Column(mainAxisSize: MainAxisSize.min, children: [
            isMain?
            productList != null ? Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeMedium,
                Dimensions.paddingSizeMedium,
                Dimensions.paddingSizeMedium,
                0,
              ),
              child: Row(children: [
                Expanded(child: TitleRowWidget(
                  title: '${getTranslated('top_selling_products', context)}',

                  onTap: (productList.length > 4)
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen(title: 'top_selling_products')))
                    : null,
                )),
              ]),
            ) : TopSellingProductSectionShimmer(isMain: isMain, isDarkMode : Provider.of<ThemeController>(context).darkTheme) : const SizedBox(),

            productList != null ? productList.isNotEmpty ?
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeSmall,
                isMain ? Dimensions.paddingSizeMedium : Dimensions.paddingSizeSmall,
              ),
              child: PaginatedListViewWidget(
                reverse: false,
                scrollController: scrollController,
                totalSize: prodProvider.topSellingProductModel!.totalSize,
                offset: prodProvider.topSellingProductModel != null ? int.parse(prodProvider.topSellingProductModel!.offset!) : null,
                onPaginate: (int? offset) async {
                  await prodProvider.getTopSellingProductList(offset!, context,'en', reload: false);
                },
                itemView: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: MediaQuery.of(context).size.width < 400? 0.68: MediaQuery.of(context).size.width < 415? 0.70 : 0.72,
                  ),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: isMain && productList.length >4? 4 : productList.length,
                  itemBuilder: (context, index) {
                    return TopMostProductWidget(productModel: productList![index].product, totalSold: productList[index].product?.totalQtySold.toString());
                  },
                ),
              ),
            ) : Padding(padding: EdgeInsets.only(top: isMain ? 0.0 :MediaQuery.of(context).size.height/3),
                child: const NoDataScreen()) : const SizedBox.shrink(),

          ]);
        },
      ),
    );
  }
}



class TopSellingProductSectionShimmer extends StatelessWidget {
  final bool isMain;
  final bool isDarkMode;
  const TopSellingProductSectionShimmer({
    super.key,
    required this.isMain,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMain)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, // Dimensions.paddingSizeDefault
              vertical: 12, // Dimensions.paddingSizeSmall
            ),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  color: shimmerColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: shimmerColor,
                  ),
                ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Dimensions.paddingSizeSmall
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: MediaQuery.of(context).size.width < 400
                    ? 0.68
                    : MediaQuery.of(context).size.width < 415
                    ? 0.70
                    : 0.72,
              ),
              itemCount: 4, // Only preview top 4 if isMain
              itemBuilder: (context, index) => _ShimmerProductCard(color: shimmerColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  final Color color;
  const _ShimmerProductCard({required this.color});

  @override
  Widget build(BuildContext context) {

    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.10),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ColoredBox(color: color, child: const SizedBox.expand()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 10, width: double.infinity, color: color),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: 72,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              ),
            ]),
          ),
        ]),
    );
  }
}
