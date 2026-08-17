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
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    } else {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse data) async {
        try {
          if (data.payload == null || data.payload!.isEmpty) return;
          NotificationHelper.handleNotificationClick(NotificationBody.fromJson(jsonDecode(data.payload!)));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Local notification tap error: $e');
          }
        }
      },
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      await Future.delayed(const Duration(seconds: 1));
      final BuildContext? context = Get.context;
      if (context == null) return;
      final AuthController authController = Provider.of<AuthController>(context, listen: false);
      if (authController.isLoggedIn()) {
        await authController.updateToken(context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint("onMessage: ${message.notification?.title}/${message.notification?.body}/${message.data}");
      }

      if(message.data['type'] == 'maintenance_mode') {
        await _handleMaintenanceMode();
        return;
      }

      await showNotification(message, flutterLocalNotificationsPlugin, false);
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)  async {
      if (kDebugMode) {
        debugPrint("onOpenApp: ${message.notification?.title}/${message.data}");
      }

      if(message.data['type'] == 'maintenance_mode') {
        await _handleMaintenanceMode();
        return;
      }

      try {
        if (message.data.isNotEmpty || message.notification != null) {
          NotificationHelper.handleNotificationClick(_payloadFromRemoteMessage(message));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('onMessageOpenedApp navigation error: $e');
        }
      }
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
    String? title;
    String? body;
    String? image;
    final Map<String, dynamic> payload = Map<String, dynamic>.from(message.data);
    payload['title'] ??= message.notification?.title;
    payload['body'] ??= message.notification?.body;
    if ((payload['order_id'] == null || payload['order_id'].toString().isEmpty) && (message.notification?.titleLocKey?.isNotEmpty ?? false)) {
      payload['order_id'] = message.notification!.titleLocKey;
      payload['type'] ??= 'order';
    }

    if(data) {
      title = message.data['title']?.toString();
      body = message.data['body']?.toString();
      image = (message.data['image'] != null && message.data['image'].toString().isNotEmpty)
          ? message.data['image'].toString().startsWith('http') ? message.data['image'].toString()
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;
    } else {
      title = message.notification?.title ?? message.data['title']?.toString();
      body = message.notification?.body ?? message.data['body']?.toString();
      if(Platform.isAndroid) {
        image = (message.notification?.android?.imageUrl != null && message.notification!.android!.imageUrl!.isNotEmpty)
            ? message.notification!.android!.imageUrl!.startsWith('http') ? message.notification!.android!.imageUrl
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification?.android?.imageUrl}' : null;
      } else if(Platform.isIOS) {
        image = (message.notification?.apple?.imageUrl != null && message.notification!.apple!.imageUrl!.isNotEmpty)
            ? message.notification!.apple!.imageUrl!.startsWith('http') ? message.notification?.apple?.imageUrl
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.apple!.imageUrl}' : null;
      }
    }

    if (title == null || title.isEmpty) return;
    body ??= title;

    if (Platform.isIOS) {
      await showIOSNotification(title, body, payload, fln);
      return;
    }

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, payload, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body, payload, fln);
      }
    }else {
      await showBigTextNotification(title, body, payload, fln);
    }
  }

  static Future<void> showIOSNotification(
    String title,
    String body,
    Map<String, dynamic> payload,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await fln.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(payload),
    );
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
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await fln.show(id: DateTime.now().millisecondsSinceEpoch.remainder(100000), title: title, body: body, notificationDetails: platformChannelSpecifics, payload: jsonEncode(data));
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
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await fln.show(id: DateTime.now().millisecondsSinceEpoch.remainder(100000), title : title, body: body, notificationDetails: platformChannelSpecifics, payload: jsonEncode(data));
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

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint("onBackground: ${message.notification?.title}/${message.notification?.body}/${message.data}");
  }
}
