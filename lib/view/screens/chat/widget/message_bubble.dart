
import 'package:efood_multivendor_restaurant/util/app_constants.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/splash_controller.dart';
import '../../../../controller/user_controller.dart';
import '../../../../data/model/response/config_model.dart';
import '../../../../data/model/response/conversation_model.dart';
import '../../../../data/model/response/message_model.dart';
import '../../../../helper/date_converter.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/user_type.dart';
import '../../../../util/styles.dart';
import '../../../base/custom_image.dart';
import 'image_dialog.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final User user;
  final UserType userType;
  final MessageModel msgModel;
  final bool isCurrentUser;

  const MessageBubble({Key key, @required this.message, @required this.user, @required this.userType, this.msgModel,
      this.isCurrentUser,}) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  BaseUrls _baseUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

     _baseUrl = Get.find<SplashController>().configModel.baseUrls;
    print('_baseUrl'+_baseUrl.customerImageUrl.toString());
  }
  @override
  Widget build(BuildContext context) {

    //bool _isReply = message.senderId != Get.find<UserController>().userInfoModel.userInfo.id;
   // print('userInfo:'+Get.find<UserController>().userInfoModel.userInfo.id.toString());


    return (widget.message != null && !widget.isCurrentUser) ?
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL)),
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('${widget.msgModel.conversation.sender.fName} ${widget.msgModel.conversation.sender.lName}' ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

          ClipRRect(
            child: CustomImage(
              fit: BoxFit.cover, width: 40, height: 40,
              image: '${_baseUrl.customerImageUrl}/${widget.msgModel.conversation.sender.image}',
              // image: '${userType == UserType.admin ? _baseUrl.businessLogoUrl : userType == UserType.vendor
              //     ? _baseUrl.restaurantImageUrl : _baseUrl.deliveryManImageUrl}/${user.image}',
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          SizedBox(width: 10),

          Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(widget.message.message != null) Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(Dimensions.RADIUS_DEFAULT),
                      topRight: Radius.circular(Dimensions.RADIUS_DEFAULT),
                      bottomLeft: Radius.circular(Dimensions.RADIUS_DEFAULT),
                    ),
                  ),
                  padding: EdgeInsets.all(widget.message.message != null ? Dimensions.PADDING_SIZE_DEFAULT : 0),
                  child: Text(widget.message.message ?? ''),
                ),
              ),
              SizedBox(height: 8.0),

              (widget.message.files != null && widget.message.files.isNotEmpty) ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.message.files.length,
                  itemBuilder: (BuildContext context, index) {
                    return  widget.message.files.length > 0 ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => showDialog(context: context, builder: (context) {
                          return ImageDialog(imageUrl: '${_baseUrl.chatImageUrl}/${widget.message.files[index]}');
                        }),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL),
                          child: CustomImage(
                            height: 100, width: 100, fit: BoxFit.cover,
                            image: '${_baseUrl.chatImageUrl}/${widget.message.files[index] ?? ''}',
                          ),
                        ),
                      ),
                    ) : SizedBox();

                  }) : SizedBox(),

            ]),
          ),
        ]),
        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

        Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(widget.message.createdAt)),
          style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_SMALL),
        ),
      ]),
    )
        :
    Container(
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL)),
      child:
     // GetBuilder<UserController>(builder: (profileController) {
        //print('name'+profileController.userInfoModel.fName);
     //   return
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [


          Text(
            '${AppConstants.userInfoModel != null ? AppConstants.userInfoModel.fName ?? '' : ''} '
                '${AppConstants.userInfoModel != null ? AppConstants.userInfoModel.lName ?? '' : ''}',
            style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [

            Flexible(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [

                (widget.message.message != null && widget.message.message.isNotEmpty) ? Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.RADIUS_DEFAULT),
                        bottomRight: Radius.circular(Dimensions.RADIUS_DEFAULT),
                        bottomLeft: Radius.circular(Dimensions.RADIUS_DEFAULT),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(widget.message.message != null ? Dimensions.PADDING_SIZE_DEFAULT : 0),
                      child: Text(widget.message.message ?? ''),
                    ),
                  ),
                ) : SizedBox(),

                (widget.message.files != null && widget.message.files.isNotEmpty) ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                      reverse: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.message.files.length,
                      itemBuilder: (BuildContext context, index){
                        return  widget.message.files.length > 0 ?
                        InkWell(
                          onTap: () => showDialog(context: context, builder: (context) {
                            return ImageDialog(imageUrl: '${_baseUrl.chatImageUrl}/${widget.message.files[index]}');
                          }),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Dimensions.PADDING_SIZE_SMALL , right:  0,
                              top: (widget.message.message != null && widget.message.message.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                              child: CustomImage(
                                height: 100, width: 100, fit: BoxFit.cover,
                                image: '${_baseUrl.chatImageUrl}/${widget.message.files[index] ?? ''}',
                              ),
                            ),
                          ),
                        ) : SizedBox();
                      }),
                ) : SizedBox(),
              ]),
            ),
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CustomImage(
                fit: BoxFit.cover, width: 40, height: 40,
                image: AppConstants.userInfoModel != null ? '${_baseUrl.restaurantImageUrl}/${AppConstants.userInfoModel.image}' : '',
              ),
            ),
          ]),

          Icon(
            widget.message.isSeen == 1 ? Icons.done_all : Icons.check,
            size: 12,
            color: widget.message.isSeen == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

          Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(widget.message.createdAt)),
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.FONT_SIZE_SMALL),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

        ])
     // }),
    );
  }
}


class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key key,
     this.message,
     this.msgModel,
     this.isCurrentUser,
  }) : super(key: key);
  final Message message;
  final MessageModel msgModel;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {

    print('user: '+Get.find<UserController>().userInfoModel.fName);

    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        // align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end :  MainAxisAlignment.start,
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end :  CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.all(0),
              child: Text(isCurrentUser ? '':msgModel != null ? '${msgModel.conversation.sender.fName}'
                  ' ${msgModel.conversation.sender.lName}':Get.find<UserController>().userInfoModel.userInfo.fName),
            ),

            DecoratedBox(
              // chat bubble decoration
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  message.message,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: isCurrentUser ? Colors.white : Colors.black87),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                DateConverter.localDateToIsoStringAMPM(DateTime.parse(message.createdAt)),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.grey,fontSize: 10),
              ),
            ),
          ],
        )

      ),
    );
  }
}