import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/helper/my_date_utile.dart';
import 'package:my_chat_app/model/chat_user_model.dart';
import 'package:my_chat_app/screen/user_profile.dart';
import 'package:my_chat_app/widgets/message_card.dart';

import '../apis/apis.dart';
import '../main.dart';
import '../model/message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  TextEditingController _chatController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.brown.shade100,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, s.height * .02),
                child: _appBar(),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                    child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return SizedBox();

                      // if some data or all data are loading
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => MessageModel.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: s.height * .008),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              });
                        } else {
                          return Center(
                              child: Text(
                            'Say hi! 👋',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown),
                          ));
                        }
                    }
                  },
                )),

                // progress indicator for showing uploading
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        )),
                  ),

                _ChatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: s.height * .35,
                    child: EmojiPicker(
                        textEditingController: _chatController,
                        config: Config(
                          bgColor: Colors.brown.shade100,
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.00),
                        )),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
        padding: EdgeInsets.only(bottom: s.height * .01),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UserProfileScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getSpecificUserInfo(widget.user),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs != null) {
                final data = snapshot.data!.docs;
                final list =
                    data.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(s.height * .03),
                      child: CachedNetworkImage(
                        height: s.height * .055,
                        width: s.height * .055,
                        fit: BoxFit.fitWidth,
                        imageUrl: list.isNotEmpty
                            ? list[0].image
                            : widget.user.image.toString(),
                        // placeholder: (context,url)=> CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                    SizedBox(
                      width: s.width * .04,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty
                              ? list[0].name
                              : widget.user.name.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17),
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'online'
                                  : MyDateTime.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateTime.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    )
                  ],
                );
              }
              else{
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        )
    );
  }

  Widget _ChatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: s.height * .01, horizontal: s.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.brown.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        size: 25,
                        color: Colors.brown,
                      )),
                  Expanded(
                      child: TextFormField(
                    controller: _chatController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.brown),
                        border: InputBorder.none),
                    onTap: () {
                      setState(() {
                        _showEmoji = false;
                      });
                    },
                  )),

                  // Take multiple images from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage();
                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        size: 25,
                        color: Colors.brown,
                      )),

                  // Take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        size: 25,
                        color: Colors.brown,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            shape: CircleBorder(),
            minWidth: 0,
            color: Colors.brown,
            onPressed: () {
              if (_chatController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  // on first message (add user to my_user collection of chat user
                  APIs.sendFirstMessage(
                      widget.user, _chatController.text, Type.text);
                } else {
                  // simply send message
                  APIs.sendMessage(
                      widget.user, _chatController.text, Type.text);
                }
                _chatController.clear();
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: s.width * .02,
          )
        ],
      ),
    );
  }
}
