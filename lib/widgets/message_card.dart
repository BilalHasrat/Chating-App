import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:my_chat_app/apis/apis.dart';
import 'package:my_chat_app/helper/dialogs_widget.dart';
import 'package:my_chat_app/helper/my_date_utile.dart';
import 'package:my_chat_app/model/message_model.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {

  final MessageModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {


  @override
  Widget build(BuildContext context) {
    bool isMe =  APIs.user.uid == widget.message.fromId;
   return InkWell(
     onLongPress: (){
       showBottomNavBar(isMe);
     },child: isMe ? _greenMessage():_blueMessage()
   );
  }

  // Sender or another user message
  Widget _blueMessage(){
    // update Last read message if sender or receiver or different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(s.width * .04),
            margin: EdgeInsets.symmetric(horizontal: s.width * .04,vertical: s.height * .01),
            decoration: BoxDecoration(
              color: widget.message.type == Type.image ? Colors.brown.shade100 : Colors.brown.shade200,
              border: Border.all(color: Colors.brown),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            ),
            child: widget.message.type == Type.text
                ? Text(widget.message.msg,style: TextStyle(color: Colors.white),)
            : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: widget.message.msg,
                placeholder: (context,url)=> Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Icon(Icons.image,size: 70,),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: s.width * .04),
          child: Row(
            children: [
              Text(MyDateTime.getFormattedDate(context: context, time: widget.message.sent),style: TextStyle(color: Colors.black54),),
              SizedBox(width: s.width * .04),

            ],
          ),
        ),
      ],
    );
  }

  // MY messages
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: s.width * .04),
          child: Row(
            children: [
              if(widget.message.read.isNotEmpty)
                Icon(Icons.done_all, color: Colors.blue,),
              if(widget.message.read.isEmpty)
                Icon(Icons.done_all,color: Colors.grey,),

              SizedBox(width: s.width * .02),
              Text(MyDateTime.getFormattedDate(context: context, time: widget.message.sent),
                 style: TextStyle(color: Colors.black54),),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(s.width * .04),
            margin: EdgeInsets.symmetric(horizontal: s.width * .04,vertical: s.height * .01),
            decoration: BoxDecoration(
                color: widget.message.type == Type.image ? Colors.brown.shade100 : Colors.green.shade200,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
            ),
            child:widget.message.type == Type.text
                ? Text(widget.message.msg,style: TextStyle(color: Colors.white),)
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    fit: BoxFit.fitWidth,
                    imageUrl: widget.message.msg,
                    placeholder: (context,url)=> Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image,size: 70,),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  void showBottomNavBar(bool isMe){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        builder: (_){
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: s.height *.015,horizontal:s.width *.4 ),
              height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
              ),
              widget.message.type == Type.text
              // copy text
                  ?_Items(icon: Icon(Icons.copy_all_outlined,color: Colors.blue,),
                name: 'Copy Text',
                ontap: () async {
                    await Clipboard.setData(ClipboardData(
                        text: widget.message.msg)).then((value) {
                      Navigator.pop(context);
                     // DialogWidget.showSnackBar(context, 'Text Copied');
                    });
                },)

              // save image
                  :_Items(icon: Icon(Icons.download,color: Colors.blue,),
                name: 'Save Image',
                ontap: () async {
                try{
                  await GallerySaver.saveImage(widget.message.msg, albumName: 'Lets Chats')
                      .then((success) {
                    Navigator.pop(context);
                    if(success != null && success){
                      DialogWidget.showSnackBar(context, 'Image Saved Successfully');
                    }
                  });
                }catch(e){
                  print('-----  **  $e  **  -----');
                }
                },),

              if(isMe)
                Divider(color: Colors.black54, endIndent: s.width * .04, indent: s.width * .04,),

              // edit option
              if(widget.message.type == Type.text && isMe)
                _Items(icon: Icon(Icons.edit,color: Colors.blue,),
                  name: 'Edit Message',
                  ontap: () {
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                  },),

              // delete option
              if(isMe)
                _Items(icon: Icon(Icons.delete_forever,color: Colors.red,),
                  name: 'Delete',
                  ontap: ()async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    Navigator.pop(context);
                    DialogWidget.showSnackBar(context, 'Message Deleted');
                  });
                  },),

             if(isMe) Divider(color: Colors.black54, endIndent: s.width * .04, indent: s.width * .04,),

              // sent time
              _Items(icon: Icon(Icons.remove_red_eye,color: Colors.blue,),
                name: 'Sent At: ${MyDateTime.getMessageTime(context: context, time: widget.message.sent)}', ontap: () {  },),

              // read time
              _Items(icon: Icon(Icons.remove_red_eye,color: Colors.green,),
                name:widget.message.read.isEmpty ? 'Read At: Not seen yet'
                    : 'Read At: ${MyDateTime.getMessageTime(context: context, time: widget.message.read)}',ontap: () {  },),
            ],
          );
        });
  }
  void _showMessageUpdateDialog(){
    String updateMessage = widget.message.msg;
    showDialog(context: context, builder: (context){
      return AlertDialog(
        contentPadding: EdgeInsets.only(top: 20,bottom: 10,left: 24,right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.message,size: 28,color: Colors.brown,),
            Text('Update Message')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => updateMessage = value,
          initialValue: updateMessage,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            )
          ),
        ),
        actions: [
          MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },
            child: Text('Cancel',style: TextStyle(fontSize: 16,color: Colors.brown),),
          ), MaterialButton(
            onPressed: (){
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updateMessage);
            },
            child: Text('Update',style: TextStyle(fontSize: 16,color: Colors.brown),),
          )
        ],
      );
    });
  }
}
class _Items extends StatelessWidget {
  final Icon icon ;
  final String name;
  final VoidCallback ontap;
  final Color? color;
   _Items({required this.icon,required this.name,required this.ontap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding:  EdgeInsets.only(left: s.width * .05,top: s.height * .015, bottom: s.height * .015 ),
        child: Row(children: [icon,Flexible(child: Text('     $name',style: TextStyle(color: Colors.black54,letterSpacing: 0.5),)), ],),
      ),
    );
  }
}

