import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/helper/date_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/screens/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/order_controller.dart';
import '../../util/images.dart';
import 'confirmation_dialog.dart';
import 'custom_button.dart';
import 'custom_loader.dart';
import 'input_dialog.dart';

class OrderWidget extends StatefulWidget {
  final OrderModel orderModel;
  final bool hasDivider;
  final bool isRunning;
  final bool showStatus;
  OrderWidget(
      {@required this.orderModel,
      @required this.hasDivider,
      @required this.isRunning,
      this.showStatus = false});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Get.toNamed(
              RouteHelper.getOrderDetailsRoute(widget.orderModel.id),
              arguments: OrderDetailsScreen(
                orderModel: widget.orderModel,
                isRunningOrder: widget.isRunning,
              )),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(
                                    9), // setting border radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 5,
                                    offset: Offset(0, 1), // setting drop shadow
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8), // setting padding
                              child: Text(
                                  '${'order_id'.tr}: #${widget.orderModel.id}',
                                  style: robotoMedium),
                            ),
                            SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Row(children: [
                              Text(
                                DateConverter.dateTimeStringToDateTime(
                                    widget.orderModel.createdAt),
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                    color: Theme.of(context).disabledColor),
                              ),
                              Container(
                                height: 10,
                                width: 1,
                                color: Theme.of(context).disabledColor,
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              ),
                              Text(
                                widget.orderModel.orderType.tr,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL,
                                    color: Theme.of(context).primaryColor),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              widget.orderModel.orderStatus == 'pending'
                                  ? Icon(
                                      Icons.fiber_new_rounded,
                                      size: 25,
                                      color: Colors.orange,
                                    )
                                  : SizedBox()
                            ]),
                          ]),
                    ),
                    widget.showStatus
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL,
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.orderModel.orderStatus.toUpperCase(),
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                  color: Theme.of(context).cardColor),
                            ),
                          )
                        : Text(
                            '${widget.orderModel.detailsCount} ${widget.orderModel.detailsCount < 2 ? 'item'.tr : 'items'.tr}',
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                color: Theme.of(context).disabledColor),
                          ),
                    widget.showStatus
                        ? SizedBox()
                        : Icon(Icons.keyboard_arrow_right,
                            size: 30, color: Theme.of(context).primaryColor),
                  ]),
            ),
          ]),
        ),
        widget.orderModel.orderStatus == 'pending'
            ? Row(children: [
                Expanded(
                    child: TextButton(
                  onPressed: () => Get.dialog(
                      ConfirmationDialog(
                        icon: Images.warning,
                        title: 'are_you_sure_to_cancel'.tr,
                        description: 'you_want_to_cancel_this_order'.tr,
                        onYesPressed: () {
                          Get.find<OrderController>()
                              .updateOrderStatus(
                                  widget.orderModel.id, 'canceled',
                                  back: true)
                              .then((success) {
                            if (success) {
                              Get.find<AuthController>().getProfile();
                              Get.find<OrderController>().getCurrentOrders();
                            }
                          });
                        },
                      ),
                      barrierDismissible: false),
                  style: TextButton.styleFrom(
                    minimumSize: Size(1170, 40),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    ),
                    backgroundColor: Colors.white, // setting background color
                    elevation: 2, // setting elevation
                  ),
                  child: Text('cancel'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                      )),
                )),
                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.dialog(CustomLoader());
                      Get.find<OrderController>()
                          .updateOrderStatus(widget.orderModel.id, 'confirmed',
                              back: true)
                          .then((success) {
                        if (success) {
                          // Get.find<AuthController>().getProfile();
                          // Get.find<OrderController>().getCurrentOrders();
                          // setState(() {
                          //   isSuccess = success;
                          // });

                          Get.back();

                          Get.dialog(InputDialog(
                            icon: Images.warning,
                            title: 'are_you_sure_to_confirm'.tr,
                            description: 'enter_processing_time_in_minutes'.tr,
                            onPressed: (String time) {
                              Get.back();
                              Get.find<OrderController>()
                                  .updateOrderStatus(
                                      widget.orderModel.id, 'processing',
                                      processingTime: time)
                                  .then((success) {
                                if (success) {
                                  Get.find<AuthController>().getProfile();
                                  Get.find<OrderController>()
                                      .getCurrentOrders();
                                }
                              });
                            },
                          ));
                        }
                      });
                    },
                    child: Text(
                      'confirm'.tr,
                      style: robotoRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(1170, 40),
                      padding: EdgeInsets.zero,
                      elevation: 2, // setting elevation
                      primary: Theme.of(context)
                          .primaryColor, // setting button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Dimensions.RADIUS_SMALL), // setting border radius
                      ),
                      shadowColor:
                          Colors.grey.withOpacity(0.5), // setting shadow color
                    ),
                  ),
                ),
              ])
            : SizedBox(),
        widget.hasDivider
            ? Container(
                height: 1,
                child: Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 1,
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
