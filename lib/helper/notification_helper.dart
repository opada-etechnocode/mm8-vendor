import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/chat_screen.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/notification/screens/notification_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:sixvalley_vendor_app/features/refund/domain/models/refund_model.dart';
import 'package:sixvalley_vendor_app/features/refund/screens/refund_details_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/wallet_screen.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/notification/models/notification_body.dart';

class NotificationHelper {
  static const Set<String> _chatTypes = {
    'chatting',
    'chat',
    'message',
    'conversation',
    'message_from_customer',
    'message_from_delivery_man',
  };

  static const Set<String> _orderTypes = {
    'order',
    'orders',
    'order_status',
    'new_order',
    'order_edit',
    'order_updated',
    'pending',
    'confirmed',
    'processing',
    'processed',
    'out_for_delivery',
    'delivered',
    'canceled',
    'cancelled',
    'returned',
    'failed',
    'failed_to_deliver',
  };

  static const Set<String> _refundTypes = {
    'refund',
    'refund_request',
  };

  static const Set<String> _walletTypes = {
    'wallet',
    'wallet_withdraw',
    'withdraw',
    'withdraw_request',
    'withdraw_approved',
    'withdraw_rejected',
  };

  static const Set<String> _productTypes = {
    'product_request_approved_message',
    'product_request_rejected_message',
    'product_request_denied_message',
    'product_approved',
    'product_rejected',
  };

  static void handleNotificationClick(NotificationBody? payload, {bool replace = false}) {
    final BuildContext? context = Get.context;
    if (context == null || payload == null) {
      return;
    }

    try {
      final Widget screen = screenFor(payload, context);
      final Route<dynamic> route = MaterialPageRoute(builder: (_) => screen);
      if (replace) {
        Navigator.of(context).pushReplacement(route);
      } else {
        Navigator.of(context).push(route);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Notification navigation error: $e\n$stackTrace');
      }
    }
  }

  static Widget screenFor(NotificationBody payload, BuildContext context) {
    final String type = (payload.type ?? '').toLowerCase();

    if (_chatTypes.contains(type) || _isChatMessageKey(payload.messageKey) || (payload.senderId != null && payload.orderId == null && type.isEmpty)) {
      return _chatScreen(payload, context);
    }

    if (_refundTypes.contains(type) || type.contains('refund') || payload.refundId != null) {
      return RefundDetailsScreen(
        fromNotification: true,
        refundModel: RefundModel(id: payload.refundId),
        orderDetailsId: payload.orderDetailsId,
      );
    }

    if (_orderTypes.contains(type) || type.contains('order') || payload.orderId != null) {
      if (payload.orderId != null) {
        return OrderDetailsScreen(orderId: payload.orderId, fromNotification: true);
      }
    }

    if (_walletTypes.contains(type) || type.contains('wallet') || type.contains('withdraw')) {
      return const WalletScreen(fromNotification: true);
    }

    if (_productTypes.contains(type) || type.contains('product_request')) {
      return const ProductListMenuScreen(fromNotification: true);
    }

    return const NotificationScreen();
  }

  static Widget _chatScreen(NotificationBody payload, BuildContext context) {
    final bool isDeliveryMan = payload.messageKey == 'message_from_delivery_man';
    Provider.of<ChatController>(context, listen: false).setUserTypeIndex(
      context,
      isDeliveryMan ? 1 : 0,
      isUpdate: false,
    );

    if (payload.senderId != null) {
      return ChatScreen(
        userId: payload.senderId,
        name: payload.senderName ?? payload.title ?? '',
        fromNotification: true,
      );
    }

    return InboxScreen(fromNotification: true, initIndex: isDeliveryMan ? 1 : 0);
  }

  static bool _isChatMessageKey(String? messageKey) {
    final String key = (messageKey ?? '').toLowerCase();
    return key.contains('message_from_customer') || key.contains('message_from_delivery_man');
  }
}
