import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/login_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/maintenance/maintenance_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/notification_helper.dart';
import 'package:sixvalley_vendor_app/notification/models/notification_body.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

import '../main.dart';

class MyNotification {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse data) async {
        try {
          if (data.payload != null && data.payload!.isNotEmpty) {
            NotificationHelper.handleNotificationClick(NotificationBody.fromJson(jsonDecode(data.payload!)));
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Local notification tap error: $e');
          }
        }
      },
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint("onMessage: ${message.data} / ${message.notification?.title}");
      }

      if(message.data['type'] == 'maintenance_mode') {
        await _handleMaintenanceMode();
        return;
      }

      showNotification(message, flutterLocalNotificationsPlugin, false);
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)  async {
      if (kDebugMode) {
        debugPrint("onOpenApp: ${message.data} / ${message.notification?.title}");
      }

      if(message.data['type'] == 'maintenance_mode') {
        await _handleMaintenanceMode();
        return;
      }

      NotificationHelper.handleNotificationClick(_payloadFromRemoteMessage(message));
    });
  }

  static NotificationBody _payloadFromRemoteMessage(RemoteMessage message) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    data['title'] ??= message.notification?.title;
    data['body'] ??= message.notification?.body;
    if ((data['order_id'] == null || data['order_id'].toString().isEmpty) && (message.notification?.titleLocKey?.isNotEmpty ?? false)) {
      data['order_id'] = message.notification!.titleLocKey;
      data['type'] ??= 'order';
    }
    return NotificationBody.fromJson(data);
  }

  static Future<void> _handleMaintenanceMode() async {
    final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
    await splashProvider.initConfig();

    ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;
    bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

    if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1)) {
      Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
        builder: (_) => const MaintenanceScreen(),
        settings: const RouteSettings(name: 'MaintenanceScreen'),
      ));
    }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
      final AuthController authController = Provider.of<AuthController>(Get.context!, listen: false);
      if(authController.isLoggedIn()) {
        Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(message.data);
    payload['title'] ??= message.notification?.title;
    payload['body'] ??= message.notification?.body;
    if ((payload['order_id'] == null || payload['order_id'].toString().isEmpty) && (message.notification?.titleLocKey?.isNotEmpty ?? false)) {
      payload['order_id'] = message.notification!.titleLocKey;
      payload['type'] ??= 'order';
    }

    String? title = payload['title']?.toString();
    String? body = payload['body']?.toString();
    String? image = (payload['image'] != null && payload['image'].toString().isNotEmpty)
        ? payload['image'].toString().startsWith('http') ? payload['image'].toString()
        : '${AppConstants.baseUrl}/storage/app/public/notification/${payload['image']}' : null;

    if (title == null && body == null) {
      return;
    }

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, payload, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body ?? '', payload, fln);
      }
    }else {
      await showBigTextNotification(title, body ?? '', payload, fln);
    }
  }


  static Future<void> showBigTextNotification(String? title, String body, Map<String, dynamic> data, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'mm8_vendor_channel', 'MM8 Vendor', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await fln.show( id: 0, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, Map<String, dynamic> data, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'mm8_vendor_channel', 'MM8 Vendor',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await fln.show(id: 0, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint("onBackground: ${message.notification?.title}/${message.notification?.body}/${message.data}");
  }
}
