import 'package:efood_multivendor_restaurant/controller/notification_controller.dart';
import 'package:efood_multivendor_restaurant/controller/splash_controller.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/custom_app_bar.dart';
import 'package:efood_multivendor_restaurant/view/screens/notification/widget/notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/order_controller.dart';
import '../../../data/model/body/notification_body.dart';
import '../../../data/model/response/order_model.dart';
import '../../../helper/route_helper.dart';
import '../order/order_details_screen.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.find<NotificationController>().getNotificationList();

    return Scaffold(
      appBar: CustomAppBar(title: 'notification'.tr),
      body: GetBuilder<NotificationController>(builder: (notificationController) {
        if(notificationController.notificationList != null) {
          notificationController.saveSeenNotificationCount(notificationController.notificationList.length);
        }
        List<DateTime> _dateTimeList = [];
        return notificationController.notificationList != null ? notificationController.notificationList.length > 0 ? RefreshIndicator(
          onRefresh: () async {
            await notificationController.getNotificationList();
          },
          child: Scrollbar(child: SingleChildScrollView(child: Center(child: SizedBox(width: 1170, child: ListView.builder(
            itemCount: notificationController.notificationList.length,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DateTime _originalDateTime = DateConverter.dateTimeStringToDate(notificationController.notificationList[index].created_at);
              DateTime _convertedDate = DateTime(_originalDateTime.year, _originalDateTime.month, _originalDateTime.day);
              bool _addTitle = false;
              if(!_dateTimeList.contains(_convertedDate)) {
                _addTitle = true;
                _dateTimeList.add(_convertedDate);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                _addTitle ? Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Text(DateConverter.dateTimeStringToDateOnly(notificationController.notificationList[index].created_at)),
                ) : SizedBox(),

                ListTile(
                  onTap: () {

                  //  Get.find<OrderController>().getOrderDetails(notificationController.notificationList[index].data.order_id);

                   // OrderModel orderModel = Get.find<OrderController>().orderModel;


                    var  orderModel = OrderModel(id: notificationController.notificationList[index].data.order_id);

                   // if(orderModel != null){
                      Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationController.notificationList[index].data.order_id),
                          arguments: OrderDetailsScreen(
                              orderModel: orderModel, isRunningOrder: notificationController.notificationList[index].data.type == 'new_order'?true:false)
                      );
                  //  }


                    //Get.toNamed(RouteHelper.getConversationRoute());


                    // Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBody(
                    //   notificationType: NotificationType.message,
                    //   //deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
                    //   //adminId: data['sender_type'] == 'admin' ? 0 : null,
                    //   adminId: 1 == 'admin' ? 0 : null,
                    //   restaurantId: 1 == 'vendor' ? 0 : null,
                    //   conversationId: 1,
                    // )));

                    // showDialog(context: context, builder: (BuildContext context) {
                    //   return NotificationDialog(notificationModel: notificationController.notificationList[index]);
                    // });
                  },
                  leading: ClipOval(child: FadeInImage.assetNetwork(
                    placeholder: Images.placeholder, height: 40, width: 40, fit: BoxFit.cover,
                    image: '${Get.find<SplashController>().configModel.baseUrls.notificationImageUrl}'
                        '/${notificationController.notificationList[index].data.image}',
                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 40, width: 40, fit: BoxFit.cover),
                  )),
                  title: Text(
                    notificationController.notificationList[index].data.title ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                  ),
                  subtitle: Text(
                    notificationController.notificationList[index].data.description ?? '',
                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                  child: Divider(color: Theme.of(context).disabledColor),
                ),

              ]);
            },
          ))))),
        ) : Center(child: Text('no_notification_found'.tr)) : Center(child: CircularProgressIndicator());
      }),
    );
  }
}
