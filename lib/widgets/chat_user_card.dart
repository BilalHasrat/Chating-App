import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/apis/apis.dart';
import 'package:my_chat_app/helper/my_date_utile.dart';
import 'package:my_chat_app/model/chat_user_model.dart';
import 'package:my_chat_app/model/message_model.dart';
import 'package:my_chat_app/screen/chat_screen.dart';
import 'package:my_chat_app/widgets/show_alert_dialog.dart';

import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  MessageModel? _messageModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      margin: EdgeInsets.symmetric(horizontal: s.width * .04,vertical: s.height * .003),
      color: Colors.deepOrange.shade50,
      child: StreamBuilder(
        stream: APIs.getLastMessage(widget.user),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data!.docs != null){
            final data = snapshot.data?.docs;
            final list = data!.map((e) => MessageModel.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty) _messageModel = list[0];
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user,)));
              },
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=> ShowAlertDialog(user: widget.user,));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(s.height * .3),
                  child: CachedNetworkImage(
                    height: s.height * .055,
                    width: s.height * .055,
                    imageUrl: widget.user.image,
                    // placeholder: (context,url)=> CircularProgressIndicator(),
                    errorWidget: (context,url, error)=> CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),


              title: Text(widget.user.name),

              subtitle: Text(
                _messageModel != null
                    ? _messageModel!.type == Type.image
                    ? 'Image'
                    : _messageModel!.msg
                    :widget.user.about,
                maxLines: 1,),

              trailing: _messageModel == null
                  ? null
                  : _messageModel!.read.isEmpty && _messageModel!.fromId != APIs.user.uid
                  ? Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    borderRadius: BorderRadius.circular(s.height * .3)
                ),
              ):Text(MyDateTime.getGetLastMessageTime(context: context, time: _messageModel!.sent),style: TextStyle(),),
            );
          }
          else{
            return SizedBox();
          }

        },)
    );
  }
}
