class NotificationModel {
    Data data;
    String created_at;
    int delivery_man_id;
    int id;
    int status;
    String updated_at;
    int user_id;
    int vendor_id;

    NotificationModel({this.data, this.created_at, this.delivery_man_id, this.id, this.status, this.updated_at, this.user_id, this.vendor_id});

    factory NotificationModel.fromJson(Map<String, dynamic> json) {
        return NotificationModel(
            data: json['data'] != null ? Data.fromJson(json['data']) : null,
            created_at: json['created_at'],
            delivery_man_id: json['delivery_man_id'] ,
            id: json['id'],
            status: json['status'],
            updated_at: json['updated_at'],
            user_id: json['user_id'] ,
            vendor_id: json['vendor_id'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['created_at'] = this.created_at;
        data['id'] = this.id;
        data['status'] = this.status;
        data['updated_at'] = this.updated_at;
        data['vendor_id'] = this.vendor_id;
        if (this.data != null) {
            data['data'] = this.data.toJson();
        }
        // if (this.delivery_man_id != null) {
        //     data['delivery_man_id'] = this.delivery_man_id.toJson();
        // }
        // if (this.user_id != null) {
        //     data['user_id'] = this.user_id.toJson();
        // }
        return data;
    }
}

class Data {
    String description;
    String image;
    int order_id;
    String title;
    String type;

    Data({this.description, this.image, this.order_id, this.title, this.type});

    factory Data.fromJson(Map<String, dynamic> json) {
        return Data(
            description: json['description'],
            image: json['image'],
            order_id: json['order_id'],
            title: json['title'],
            type: json['type'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['description'] = this.description;
        data['image'] = this.image;
        data['order_id'] = this.order_id;
        data['title'] = this.title;
        data['type'] = this.type;
        return data;
    }
}