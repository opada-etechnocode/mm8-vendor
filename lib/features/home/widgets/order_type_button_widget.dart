import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class OrderTypeButtonWidget extends StatelessWidget {
  final String? text;
  final String? icon;
  final int index;
  final Color? color;
  final Function? callback;
  final int? numberOfOrder;
  final bool showBorder;
  const OrderTypeButtonWidget({super.key, required this.text,this.icon ,required this.index, required this.callback, required this.numberOfOrder, this.color, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Provider.of<OrderController>(context, listen: false).setIndex(context,index);
          callback!();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(icon!),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ],
              Expanded(
                child: Text(
                  text!,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  numberOfOrder.toString(),
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(color: color, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
