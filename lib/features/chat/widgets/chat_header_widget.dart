import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';


class ChatHeaderWidget extends StatefulWidget {
  const ChatHeaderWidget({super.key});

  @override
  State<ChatHeaderWidget> createState() => _ChatHeaderWidgetState();
}

class _ChatHeaderWidgetState extends State<ChatHeaderWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
        builder: (context, chat, _) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(Dimensions.paddingSizeMedium, Dimensions.paddingSizeSmall, Dimensions.paddingSizeMedium, Dimensions.paddingSizeSmall),
            child: SizedBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50,
                    child: CustomSearchFieldWidget(
                      controller: _textEditingController,
                      hint: getTranslated('search', context),
                      prefix: Images.iconsSearch,
                      iconPressed: () => (){},
                      onSubmit: (text) => (){},
                      onChanged: (value){
                        if(value.toString().isNotEmpty){
                          chat.searchedChatList(context, value);
                        }
                        if(value.toString().isEmpty){
                          chat.getChatList(context, 1, reload: true);
                        }
                      },

                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
