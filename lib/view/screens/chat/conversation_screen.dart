
import 'package:efood_multivendor_restaurant/view/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/chat_controller.dart';
import '../../../controller/splash_controller.dart';
import '../../../controller/user_controller.dart';
import '../../../data/model/body/notification_body.dart';
import '../../../data/model/response/conversation_model.dart';
import '../../../helper/date_converter.dart';
import '../../../helper/route_helper.dart';
import '../../../helper/user_type.dart';
import '../../../util/app_constants.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_image.dart';
import '../../base/custom_snackbar.dart';
import '../../base/paginated_list_view.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key key}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<ChatController>().getConversationList(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel _conversation;
      if(chatController.searchConversationModel != null) {
        _conversation = chatController.searchConversationModel;
      }else {
        _conversation = chatController.conversationModel;
      }

      return Scaffold(
        appBar: CustomAppBar(title: 'Conversation list'),
        // floatingActionButton: (chatController.conversationModel != null && !chatController.hasAdmin) ? FloatingActionButton.extended(
        //   label: Text('${'Chat with'} ${AppConstants.APP_NAME}', style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE , color: Colors.white)),
        //   icon: Icon(Icons.chat, color: Colors.white),
        //   backgroundColor: Theme.of(context).primaryColor,
        //   onPressed: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBody(
        //     notificationType: NotificationType.message, adminId: 0,
        //   ))),
        // ) : null,
        body: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Column(children: [

            // (Get.find<AuthController>().isLoggedIn() && _conversation != null && _conversation.conversations != null
            //     && chatController.conversationModel.conversations.isNotEmpty) ? Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: SearchField(
            //   controller: _searchController,
            //   hint: 'search'.tr,
            //   suffixIcon: chatController.searchConversationModel != null ? Icons.close : Icons.search,
            //   onSubmit: (String text) {
            //     if(_searchController.text.trim().isNotEmpty) {
            //       chatController.searchConversation(_searchController.text.trim());
            //     }else {
            //       showCustomSnackBar('write_something'.tr);
            //     }
            //   },
            //   iconPressed: () {
            //     if(chatController.searchConversationModel != null) {
            //       _searchController.text = '';
            //       chatController.removeSearchMode();
            //     }else {
            //       if(_searchController.text.trim().isNotEmpty) {
            //         chatController.searchConversation(_searchController.text.trim());
            //       }else {
            //         showCustomSnackBar('write_something'.tr);
            //       }
            //     }
            //   },
            // ))) : SizedBox(),
            // SizedBox(height: (Get.find<AuthController>().isLoggedIn() && _conversation != null && _conversation.conversations != null
            //     && chatController.conversationModel.conversations.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0),

            Expanded(child: Get.find<AuthController>().isLoggedIn() ? (_conversation != null && _conversation.conversation != null)
                ? _conversation.conversation.length > 0 ? RefreshIndicator(
              onRefresh: () async {
                await Get.find<ChatController>().getConversationList(1);
              },

              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: PaginatedListView(
                  scrollController: _scrollController,
                  onPaginate: (int offset) => chatController.getConversationList(offset),
                  totalSize: _conversation.totalSize,
                  offset: _conversation.offset,
                  enabledPagination: chatController.searchConversationModel == null,
                  productView: ListView.builder(
                    itemCount: _conversation.conversation.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      User _user;
                      String _type;
                      if(
                      _conversation.conversation[index].senderType == UserType.customer.name
                       //|| _conversation.conversation[index].senderType == UserType.delivery_man.name
                      ) {
                        _user = _conversation.conversation[index].sender;
                        _type = _conversation.conversation[index].senderType;

                      }else {
                        _user = _conversation.conversation[index].receiver;
                        _type = _conversation.conversation[index].receiverType;
                      }


                      String _baseUrl = '';
                      if(_type == UserType.customer.name) {
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.customerImageUrl;
                      }else if(_type == UserType.vendor.name) {
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.vendorImageUrl;
                      }else if(_type == UserType.admin.name){
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.businessLogoUrl;
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),

                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                        ),
                        child: InkWell(
                          onTap: () {

                            if(_user != null) {
                              print('_type: '+_type);
                              print('_user.id: '+_user.id.toString());
                              // AppConstants.CONVERSATION_ID = _conversation.conversation[index].id.toString();
                              // AppConstants.userType = _type;
                              // AppConstants.user = _user;

                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) =>  ChatScreen(
                              //       notificationBody: NotificationBody(
                              //       type: _conversation.conversation[index].senderType,
                              //       notificationType: NotificationType.message,
                              //        adminId: _type == UserType.admin.name ? 0 : null,
                              //      // restaurantId: _type == UserType.vendor.name ? _user.id : null,
                              //       customerId: _type == UserType.customer.name ? _user.id : null,
                              //       // deliverymanId: _type == UserType.delivery_man.name ? _user.id : null,
                              //     ),
                              //       conversationID: _conversation.conversation[index].id,
                              //       index: index,
                              //       user: _user,
                              //     ),
                              //   ),
                              // );

                              Get.toNamed(RouteHelper.getChatRoute(
                                notificationBody: NotificationBody(
                                  type: _conversation.conversation[index].senderType,
                                  notificationType: NotificationType.message,
                                  adminId: _type == UserType.admin.name ? 0 : null,
                                  // restaurantId: _type == UserType.vendor.name ? _user.id : null,
                                  customerId: _type == UserType.customer.name ? _user.id : null,
                                  // deliverymanId: _type == UserType.delivery_man.name ? _user.id : null,
                                ),
                                conversationID: _conversation.conversation[index].id,
                                index: index,
                                user: _user,
                              ));
                            }else {
                              showCustomSnackBar('${_type.tr} ${'not_found'.tr}');
                            }
                          },
                          highlightColor: Theme.of(context).backgroundColor.withOpacity(0.1),
                          radius: Dimensions.RADIUS_SMALL,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                              child: Row(children: [
                                ClipOval(child: CustomImage(
                                  height: 50, width: 50,
                                  image: '$_baseUrl/${_user != null ? _user.image : ''}'?? '',
                                )),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  _user != null ? Text(
                                    '${_user.fName} ${_user.lName}', style: robotoMedium,
                                  ) : Text('user_deleted'.tr, style: robotoMedium),
                                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                                  Text(
                                    '${_type.tr}',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                                  ),
                                ])),
                              ]),
                            ),

                            Positioned(
                              right: 5,bottom: 5,
                              child: Text(
                                DateConverter.localDateToIsoStringAMPM(DateConverter.dateTimeStringToDate(
                                    _conversation.conversation[index].lastMessageTime)),
                                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_SMALL),
                              ),
                            ),

                            GetBuilder<UserController>(builder: (userController) {
                              return (userController.userInfoModel != null && userController.userInfoModel.userInfo != null
                                  && _conversation.conversation[index].lastMessage.senderId != userController.userInfoModel.userInfo.id
                                  && _conversation.conversation[index].unreadMessageCount > 0) ? Positioned(right: 5,top: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                                  child: Text(
                                    _conversation.conversation[index].unreadMessageCount.toString(),
                                    style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL),
                                  ),
                                ),
                              ) : SizedBox();
                            }),

                          ]),
                        ),
                      );
                    },
                  ),
                ))),
              ),
              //) : Center(child: Text('no_conversation_found'.tr)) : Center(child: CircularProgressIndicator()) : NotLoggedInScreen()),
            ) : Center(child: Text('no_conversation_found'.tr)) : Center(child: CircularProgressIndicator()) : Get.toNamed(RouteHelper.getSignInRoute())),

          ]),
        ),
      );
    });
  }
}

