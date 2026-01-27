import 'package:flutter/material.dart';
import '../helpers/widgets.dart';
import '../pages/selectType.dart';
// import 'pre_login_owner.dart';
class NotificationsList extends StatefulWidget {
  const NotificationsList({ Key? key }) : super(key: key);

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  

  var notifications = [];

  @override
  void initState() {
    super.initState();
    notifications.add({"id": "1", "title": "The Best Title", "desc": "Lorem Ipsum is simply dummy text of the priniting and typesettng industry."});
    notifications.add({"id": "2", "title": "The Best Title 1", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "3", "title": "The Best Title 2", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "4", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "5", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "6", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "7", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
    notifications.add({"id": "8", "title": "The Best Title 3", "desc": "Lorem Ipsum is simply dummy text of the printing and typesetting industry."});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // SizedBox(height: 10,),
                Row(
                  // alignment: Alignment.topRight,
                  children:[
                    IconButton(icon:Icon(Icons.arrow_back_ios),onPressed: (){
                      Navigator.of(context).pop();
                    },),
                    SizedBox(width: 20,),
                    Text("Notifications",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize: 24))
                  ]
                ),
                Divider(),
                SizedBox(height: 30,),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for(var i=0;i<notifications.length;i++)
                           Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(width:40,child: Icon(Icons.label_important_outline,color: Colors.blue,)),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                 Container(child: Text(notifications[i]['title'].toString(),style: TextStyle(color:Colors.blueGrey.shade800,fontWeight: FontWeight.bold,fontSize: 18),)),
                                 Container(
                                   width: MediaQuery.of(context).size.width-85,
                                   child: Text(notifications[i]['desc'].toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15,color: Colors.grey)),
                                 ),
                                 SizedBox(height: 35,)
                               ],)
                             ],
                           )
                        ],
                      ),
                    ),
                  ),
                )
                
              ],
              ) /* add child content here */,
          ),
        ),
      ),
    );
  }
}