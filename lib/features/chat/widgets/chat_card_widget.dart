import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/chat_screen.dart';

class ChatCardWidget extends StatelessWidget {
  final Chat? chat;
  final Function callBack;
  const ChatCardWidget({super.key, this.chat, required this.callBack});

  @override
  Widget build(BuildContext context) {

    int? id = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer?.id?? -1 : chat!.deliveryManId;

    String? image = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer != null? chat?.customer?.imageFullUrl?.path: '' : chat!.deliveryMan?.imageFullUrl?.path;

    String name = Provider.of<ChatController>(context, listen: false).userTypeIndex == 0 ?
    chat!.customer != null?
    '${chat!.customer?.fName} ${chat!.customer?.lName}' :'Deleted' :
    '${chat!.deliveryMan?.fName??'Deliveryman'} ${chat!.deliveryMan?.lName??'Deleted'}';

    final bool isUnread = !(chat?.seenBySeller ?? false);
    final int unseen = chat?.unseenMessageCount ?? 0;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;


    return Padding(
      padding:  const EdgeInsetsDirectional.fromSTEB(Dimensions.paddingSizeMedium, 4, Dimensions.paddingSizeMedium, 4),
      child: Material(
        color: isUnread
            ? Theme.of(context).primaryColor.withValues(alpha: isDark ? 0.12 : 0.06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          onTap: (){

            Provider.of<ChatController>(context, listen: false).seenMessage( context, id, id);
            callBack();

            if(name.trim() == "Deleted"){
              showCustomSnackBarWidget('Customer was deleted', context,  sanckBarType: SnackBarType.success);
            }else{
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return ChatScreen(userId: id, name: name);
              }));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).hintColor.withValues(alpha: isDark ? 0.18 : 0.10),
              ),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

              ClipRRect(borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  errorWidget: (ctx, url ,err )=>Image.asset(Images.placeholderImage,
                    height: 52, width: 52, fit: BoxFit.cover,),
                  placeholder: (ctx, url )=>Image.asset(Images.placeholderImage, height: 52, width: 52, fit: BoxFit.cover),
                  imageUrl: '$image',
                  fit: BoxFit.cover, height: 52, width: 52,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall,),

              Expanded(
                child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titilliumSemiBold.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateConverter.customTime(DateTime.parse(chat!.createdAt!)),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    ),
                  ],
                  ),
                  const SizedBox(height: 6),

                  Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                    Flexible(
                      child: Text( (chat!.message == null && chat!.attachment != null) ? getTranslated('sent_attachment', context)! : chat!.message??'',
                        maxLines: 1,overflow: TextOverflow.ellipsis,
                        style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                            color: isUnread ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                        ),
                      ),
                    ),

                    if(unseen > 0)
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    if(unseen > 0)
                      Container(
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text('$unseen', style: titilliumSemiBold.copyWith(
                            color: Theme.of(context).cardColor,
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.1,
                        )),
                      )
                  ]),
                ]),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
