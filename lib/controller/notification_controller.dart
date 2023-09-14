import 'package:efood_multivendor_restaurant/data/api/api_checker.dart';
import 'package:efood_multivendor_restaurant/data/model/response/notification_model.dart';
import 'package:efood_multivendor_restaurant/data/repository/notification_repo.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationRepo notificationRepo;
  NotificationController({@required this.notificationRepo});

  List<NotificationModel> _notificationList;
  List<NotificationModel> get notificationList => _notificationList;

  Future<void> getNotificationList() async {
    Response response = await notificationRepo.getNotificationList();
    if (response.statusCode == 200) {
      _notificationList = [];
      response.body.forEach((notification) {
        NotificationModel _notification = NotificationModel.fromJson(notification);
        // _notification.title = notification['data']['title'];
        // _notification.description = notification['data']['description'];
        // _notification.image = notification['data']['image'];
        _notificationList.add(_notification);
      });
      _notificationList.sort((NotificationModel n1, NotificationModel n2) {
        return DateConverter.dateTimeStringToDate(n1.created_at).compareTo(DateConverter.dateTimeStringToDate(n2.created_at));
      });
      _notificationList = _notificationList.reversed.toList();

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void saveSeenNotificationCount(int count) {
    notificationRepo.saveSeenNotificationCount(count);
  }

  int getSeenNotificationCount() {
    return notificationRepo.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
  }
}
