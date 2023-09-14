

import 'dart:convert';
import 'dart:io';

import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/helper/user_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../controller/auth_controller.dart';
import '../controller/chat_controller.dart';
import '../controller/notification_controller.dart';
import '../controller/order_controller.dart';
import '../data/model/body/notification_body.dart';
import '../util/app_constants.dart';

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = new AndroidInitializationSettings('notification_icon');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onSelectNotification: (String payload) async {
      try{
        NotificationBody _payload;
        if(payload != null && payload.isNotEmpty) {
          _payload = NotificationBody.fromJson(jsonDecode(payload));
          if(_payload.notificationType == NotificationType.order) {
            Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(_payload.orderId.toString())));
          } else if(_payload.notificationType == NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute());
          } else{
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: _payload, conversationID: _payload.conversationId));
          }
        }
      }catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification.title}/${message.notification.body}/${message.data}");
      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if(Get.find<ChatController>().messageModel.conversation.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBody(
              type: 'customer',
              notificationType: NotificationType.message,
              // adminId: _type == UserType.admin.name ? 0 : null,
              // restaurantId: _type == UserType.vendor.name ? _user.id : null,
              customerId: message.data['sender_id'],
              // deliverymanId: _type == UserType.delivery_man.name ? _user.id : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      }else {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
        if(Get.find<AuthController>().isLoggedIn()) {
          // Get.find<OrderController>().getRunningOrders(1);
          // Get.find<OrderController>().getHistoryOrders(1);
          Get.find<NotificationController>().getNotificationList();
          // if(message.data['type'] == 'message' && message.data['message'] != null && message.data['message'].isNotEmpty) {
          //   if(Get.currentRoute.contains(RouteHelper.conversation)) {
          //     Get.find<ChatController>().reloadConversationWithNotification(m.Message.fromJson(message.data['message']).conversationId);
          //   }else {
          //     Get.find<ChatController>().reloadMessageWithNotification(m.Message.fromJson(message.data['message']));
          //   }
          // }
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onOpenApp: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
      try{
        if(message.data != null || message.data.isNotEmpty) {
          NotificationBody _notificationBody = convertNotification(message.data);
          if(_notificationBody.notificationType == NotificationType.order) {
            print('order call-------------');
            Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id'])));
          } else if(_notificationBody.notificationType == NotificationType.general) {
            Get.toNamed(RouteHelper.getNotificationRoute());
          } else{
            Get.toNamed(RouteHelper.getChatRoute(notificationBody: _notificationBody, conversationID: _notificationBody.conversationId));
          }
        }
      }catch (e) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    if(!GetPlatform.isIOS) {
      String _title;
      String _body;
      String _orderID;
      String _image;
      NotificationBody _notificationBody = convertNotification(message.data);
      if(data) {
        _title = message.data['title'];
        _body = message.data['body'];
        _orderID = message.data['order_id'];
        _image = (message.data['image'] != null && message.data['image'].isNotEmpty)
            ? message.data['image'].startsWith('http') ? message.data['image']
            : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.data['image']}' : null;
      }else {
        _title = message.notification.title;
        _body = message.notification.body;
        _orderID = message.notification.titleLocKey;
        if(GetPlatform.isAndroid) {
          _image = (message.notification.android.imageUrl != null && message.notification.android.imageUrl.isNotEmpty)
              ? message.notification.android.imageUrl.startsWith('http') ? message.notification.android.imageUrl
              : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.android.imageUrl}' : null;
        }else if(GetPlatform.isIOS) {
          _image = (message.notification.apple.imageUrl != null && message.notification.apple.imageUrl.isNotEmpty)
              ? message.notification.apple.imageUrl.startsWith('http') ? message.notification.apple.imageUrl
              : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.apple.imageUrl}' : null;
        }
      }

      if(_image != null && _image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(_title, _body, _orderID, _notificationBody, _image, fln);
        }catch(e) {
          await showBigTextNotification(_title, _body, _orderID, _notificationBody, fln);
        }
      }else {
        await showBigTextNotification(_title, _body, _orderID, _notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, NotificationBody notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String title, String body, String orderID, NotificationBody notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
      String title, String body, String orderID, NotificationBody notificationBody, String image, FlutterLocalNotificationsPlugin fln,
      ) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stackfood', 'stackfood',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'general') {
      return NotificationBody(notificationType: NotificationType.general);
    }else if(data['type'] == 'order_status') {
      return NotificationBody(notificationType: NotificationType.order, orderId: int.parse(data['order_id']));
    }else {
      return NotificationBody(
        notificationType: NotificationType.message,
        deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
        adminId: data['sender_type'] == 'admin' ? 0 : null,
        restaurantId: data['sender_type'] == 'vendor' ? 0 : null,
        customerId: int.parse(data['sender_id'].toString()),
        conversationId: int.parse(data['conversation_id'].toString()),
      );
    }
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print("onBackground: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}







// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
// import 'package:efood_multivendor_restaurant/helper/user_type.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:efood_multivendor_restaurant/util/app_constants.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// import '../controller/auth_controller.dart';
// import '../controller/chat_controller.dart';
// import '../controller/notification_controller.dart';
// import '../controller/order_controller.dart';
// import '../data/model/body/notification_body.dart';
// import '../util/alarm_service.dart';
//
// class NotificationHelper {
//
//   // static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   //   var androidInitialize = new AndroidInitializationSettings('notification_icon');
//   //   //var iOSInitialize = new IOSInitializationSettings();
//   //   var initializationsSettings = new InitializationSettings(android: androidInitialize);
//   //   flutterLocalNotificationsPlugin.initialize(initializationsSettings);
//   // }
//
//   static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//
//     print("LocalNotificationsinitialize:");
//
//     var androidInitialize = new AndroidInitializationSettings('notification_icon');
//     //var iOSInitialize = new IOSInitializationSettings();
//     var initializationsSettings = new InitializationSettings(android: androidInitialize);
//     flutterLocalNotificationsPlugin.initialize(initializationsSettings, onSelectNotification: (String payload) async {
//       try{
//         NotificationBody _payload;
//         if(payload != null && payload.isNotEmpty) {
//           _payload = NotificationBody.fromJson(jsonDecode(payload));
//           print('_payload:'+_payload.toString());
//           if(_payload.notificationType == NotificationType.order) {
//             Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(_payload.orderId.toString())));
//           } else if(_payload.notificationType == NotificationType.general) {
//             Get.toNamed(RouteHelper.getNotificationRoute());
//           } else{
//             Get.toNamed(RouteHelper.getChatRoute(notificationBody: _payload, conversationID: _payload.conversationId));
//           }
//         }
//       }catch (e) {}
//       return;
//     });
//
//
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//
//       print("onMessage: ${message.notification.title}/${message.notification.body}/${message.data}");
//       if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
//         if(Get.find<AuthController>().isLoggedIn()) {
//           Get.find<ChatController>().getConversationList(1);
//           if(Get.find<ChatController>().messageModel.conversation.id.toString() == message.data['conversation_id'].toString()) {
//             Get.find<ChatController>().getMessages(
//               1, NotificationBody(
//               notificationType: NotificationType.message, adminId: message.data['sender_type'] == UserType.admin.name ? 0 : null,
//               restaurantId: message.data['sender_type'] == UserType.vendor.name ? 0 : null,
//               deliverymanId: message.data['sender_type'] == UserType.delivery_man.name ? 0 : null,
//             ),
//               null, int.parse(message.data['conversation_id'].toString()),
//             );
//           }else {
//             NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//           }
//         }
//       }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
//         if(Get.find<AuthController>().isLoggedIn()) {
//           Get.find<ChatController>().getConversationList(1);
//         }
//         NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//       }else {
//         NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//         if(Get.find<AuthController>().isLoggedIn()) {
//           // Get.find<OrderController>().getRunningOrders(1);
//           // Get.find<OrderController>().getHistoryOrders(1);
//           //Get.find<NotificationController>().getNotificationList(true);
//           Get.find<NotificationController>().getNotificationList();
//           // if(message.data['type'] == 'message' && message.data['message'] != null && message.data['message'].isNotEmpty) {
//           //   if(Get.currentRoute.contains(RouteHelper.conversation)) {
//           //     Get.find<ChatController>().reloadConversationWithNotification(m.Message.fromJson(message.data['message']).conversationId);
//           //   }else {
//           //     Get.find<ChatController>().reloadMessageWithNotification(m.Message.fromJson(message.data['message']));
//           //   }
//           // }
//         }
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       FlutterRingtonePlayer.stop();
//       // FlutterRingtonePlayer.play(
//       //   android: AndroidSounds.alarm,
//       //   ios: IosSounds.glass,
//       //   looping: true, // Android only - API >= 28
//       //   volume: 0.1, // Android only - API >= 28
//       //   asAlarm: true, // Android only - all APIs
//       // );
//
//       print("onOpenApp: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}");
//       try{
//         if(message.data != null || message.data.isNotEmpty) {
//           NotificationBody _notificationBody = convertNotification(message.data);
//           if(_notificationBody.notificationType == NotificationType.order) {
//             print('order call-------------');
//             Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id'])));
//           } else if(_notificationBody.notificationType == NotificationType.general) {
//             Get.toNamed(RouteHelper.getNotificationRoute());
//           } else{
//             Get.toNamed(RouteHelper.getChatRoute(notificationBody: _notificationBody, conversationID: _notificationBody.conversationId));
//           }
//         }
//       }catch (e) {}
//     });
//   }
//
//
//   static NotificationBody convertNotification(Map<String, dynamic> data){
//     if(data['type'] == 'new_order') {
//       return NotificationBody(notificationType: NotificationType.order, orderId: int.parse(data['order_id']));
//     }else if(data['type'] == 'general') {
//       return NotificationBody(notificationType: NotificationType.general);
//     }else if(data['type'] == 'order_status') {
//       return NotificationBody(notificationType: NotificationType.order, orderId: int.parse(data['order_id']));
//     }else {
//       return NotificationBody(
//         notificationType: NotificationType.message,
//         deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
//         adminId: data['sender_type'] == 'admin' ? 0 : null,
//         restaurantId: data['sender_type'] == 'vendor' ? 0 : null,
//         conversationId: int.parse(data['conversation_id'].toString()),
//         //conversationId: int.parse(data['conversation_id'].toString()),
//       );
//     }
//   }
//
//   static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
//
//     // await AndroidAlarmManager.oneShot(
//     //   const Duration(seconds: 5),
//     //   // Ensure we have a unique alarm ID.
//     //   Random().nextInt(pow(2, 31) as int),
//     //   _oneShotAtTaskCallback,
//     //   exact: true,
//     //   wakeup: true,
//     // );
//
//     if(!GetPlatform.isIOS) {
//       String _title;
//       String _body;
//       String _orderID;
//       String _image;
//       if(data) {
//         _title = message.data['title'];
//         _body = message.data['body'];
//         _orderID = message.data['order_id'];
//         _image = (message.data['image'] != null && message.data['image'].isNotEmpty)
//             ? message.data['image'].startsWith('http') ? message.data['image']
//             : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.data['image']}' : null;
//       }else {
//         _title = message.notification.title;
//         _body = message.notification.body;
//         _orderID = message.notification.titleLocKey;
//         if(GetPlatform.isAndroid) {
//           _image = (message.notification.android.imageUrl != null && message.notification.android.imageUrl.isNotEmpty)
//               ? message.notification.android.imageUrl.startsWith('http') ? message.notification.android.imageUrl
//               : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.android.imageUrl}' : null;
//         }else if(GetPlatform.isIOS) {
//           _image = (message.notification.apple.imageUrl != null && message.notification.apple.imageUrl.isNotEmpty)
//               ? message.notification.apple.imageUrl.startsWith('http') ? message.notification.apple.imageUrl
//               : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification.apple.imageUrl}' : null;
//         }
//       }
//
//       // AlarmService.instance
//       //     .addAlarm( DateTime.now(), uid: "TEST UID", payload: {"holy": "Moly"});
//       // AlarmService.instance.getAlarmByUid("TEST UID");
//
//       // FlutterRingtonePlayer.play(
//       //   android: AndroidSounds.alarm,
//       //   ios: IosSounds.glass,
//       //   looping: true, // Android only - API >= 28
//       //   volume: 0.1, // Android only - API >= 28
//       //   asAlarm: true, // Android only - all APIs
//       // );
//       // print('alarm');
//       // final today = DateTime.now();
//       // final dt = today.add(const Duration(seconds: 2));
//       //
//       // AndroidAlarmManager.oneShotAt(dt, 1, _oneShotAtTaskCallback);
//
//       await showBigTextNotification(_title, _body, _orderID, fln);
//
//       // if(_image != null && _image.isNotEmpty) {
//       //   try{
//       //     await showBigPictureNotificationHiddenLargeIcon(_title, _body, _orderID, _image, fln);
//       //   }catch(e) {
//       //     await showBigTextNotification(_title, _body, _orderID, fln);
//       //   }
//       // }else {
//       //   await showBigTextNotification(_title, _body, _orderID, fln);
//       // }
//     }
//   }
//
//   static void _oneShotAtTaskCallback() {
//     // This will be null if we're running in the background.
//     // SendPort uiSendPort = IsolateNameServer.lookupPortByName('isolate');
//     // uiSendPort?.send(null);
//     print("One Shot At Task Running");
//
//   }
//
//
//   static Future<void> showTextNotificationTest(String title, String body, String orderID, FlutterLocalNotificationsPlugin fln) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'restaurant', 'restaurant', playSound: true,
//       audioAttributesUsage: AudioAttributesUsage.alarm,
//       ongoing: true,
//       autoCancel: false,
//       importance: Importance.max, priority: Priority.max,
//       sound: RawResourceAndroidNotificationSound('notification1min'),
//     );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
//   }
//
//   static Future<void> showTextNotification(String title, String body, String orderID, FlutterLocalNotificationsPlugin fln) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'restaurant', 'restaurant', playSound: true,
//       audioAttributesUsage: AudioAttributesUsage.alarm,
//       ongoing: true,
//       autoCancel: false,
//       importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification1min'),
//
//     );
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
//   }
//
//   static Future<void> showBigTextNotification(String title, String body, String orderID, FlutterLocalNotificationsPlugin fln) async {
//     BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
//       body, htmlFormatBigText: true,
//       contentTitle: title, htmlFormatContentTitle: true,
//     );
//     AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'restaurant', 'restaurant',
//       //importance: Importance.max,
//       styleInformation: bigTextStyleInformation,
//       autoCancel: false,
//       ongoing: true,
//       audioAttributesUsage: AudioAttributesUsage.alarm,
//       //priority: Priority.max,
//      // playSound: true,
//       additionalFlags: Int32List.fromList(<int>[4]),
//         priority: Priority.high,
//         importance: Importance.high,
//         fullScreenIntent: true,
//
//       sound: RawResourceAndroidNotificationSound('notification1min'),
//     );
//     NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
//
//
//
//
//   }
//
//   static Future<void> showBigPictureNotificationHiddenLargeIcon(String title, String body, String orderID, String image, FlutterLocalNotificationsPlugin fln) async {
//     final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
//     final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
//       contentTitle: title, htmlFormatContentTitle: true,
//       summaryText: body, htmlFormatSummaryText: true,
//     );
//     final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'restaurant', 'restaurant',
//       audioAttributesUsage: AudioAttributesUsage.alarm,
//       ongoing: true,
//       autoCancel: false,
//       largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
//       styleInformation: bigPictureStyleInformation, importance: Importance.max,
//       sound: RawResourceAndroidNotificationSound('notification1min'),
//     );
//     final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
//   }
//
//   static Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
//
// }
//
// Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
//   print("onBackground: ${message.notification.title}/${message.notification.body}/${message.notification.titleLocKey}/${message.data}/${message.senderId}");
//
//   if(message.notification.title == 'Order'){
//     FlutterRingtonePlayer.play(
//       android: AndroidSounds.alarm,
//       ios: IosSounds.glass,
//       looping: true, // Android only - API >= 28
//       volume: 0.1, // Android only - API >= 28
//       asAlarm: true, // Android only - all APIs
//     );
//   }
//
//
//   // var androidInitialize = new AndroidInitializationSettings('notification_icon');
//   // var iOSInitialize = new IOSInitializationSettings();
//   // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
//   // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
//   // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
// }