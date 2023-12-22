import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateTime{


  // For getting formatted time from milliSecondSinceEpoch String
  static String getFormattedDate({required BuildContext context, required String time}){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // get formatted time for sent and read
  static String getMessageTime({required BuildContext context, required String time }){

    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      return formattedTime;
    }
    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonth(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  // Get last message time (used in user card)
  static String getGetLastMessageTime({required BuildContext context, required String time, bool showYear = false }){
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if(now.day == sent.day
        && now.month == sent.month
        && now.year == sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear
        ? '${sent.day} ${_getMonth(sent)} ${sent.year}'
        :'${sent.day} ${_getMonth(sent)}';
  }


  // Get formatted last active time from user in chat screen
  static String getLastActiveTime({required BuildContext context, required String lastActive}){
    final int i = int.tryParse(lastActive) ?? -1;

    // if time is not available then return below statement
    if(i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String timeFormatted = TimeOfDay.fromDateTime(time).format(context);
    if(time.day == now.day
        && time.month == now.month
        && time.year == time.year){
      return 'Last seen today at $timeFormatted';
    }
    if((now.difference(time).inHours / 24).round() == 1){
      return 'Last seen yesterday at $timeFormatted';
    }
    String month = _getMonth(time);
    return 'Last seen on ${time.day} $month on $timeFormatted';
  }


  // Get month name from month no. or index
  static String _getMonth(DateTime date){
    switch(date.month){
      case 1 :return 'Jan';
      case 2 :return 'Feb';
      case 3 :return 'Mar';
      case 4 :return 'Apr';
      case 5 :return 'May';
      case 6 :return 'Jun';
      case 7 :return 'Jul';
      case 8 :return 'Aug';
      case 9 :return 'Sep';
      case 10 :return 'Oct';
      case 11 :return 'Nov';
      case 12 :return 'Dec';
    }
    return 'Na';
  }
}