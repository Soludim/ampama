import 'dart:core';


String timeago(String lastTime) {
  
  DateTime date = DateTime.parse(lastTime);
  int days = DateTime.now().difference(date).inDays;
  int ago = days;
  String time;
  String unit = ' day';

  if (days > 6) {
    //in weeks
    int weeks = (days / 7).truncate();
    unit = ' wk';
    ago = weeks;
    if (weeks > 3) {
      //in months
      int months = (weeks / 4).truncate();
      unit = ' month';
      ago = months;
      if (months > 11) {
        //in years
        int years = (months / 12).truncate();
        unit = ' yr';
        ago = years;
      }
    }
  }
  if (date.hour > 12) {
     time = (date.hour - 12).toString() + ':' + date.minute.toString() + 'pm';
  }else {
    time = date.hour.toString() + ':' + date.minute.toString() + 'am';
  }

  //checking plural state
  if (ago > 1) {
    unit += 's ago';
  } else if(ago==1){
    return time + ', Yesterday';
  } else {
    return time + ', Today';
  }

  return time + ', ' + ago.toString() + unit;
}
