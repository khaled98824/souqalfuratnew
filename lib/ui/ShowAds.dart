import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:souq_alfurat/models/PageRoute.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';


class ShowAd extends StatefulWidget {
  String documentId;
  int indexDocument;
  ShowAd({this.documentId, this.indexDocument});
  @override
  _ShowAdState createState() =>
      _ShowAdState(documentId: documentId, indexDocument: indexDocument);
}
List<DocumentSnapshot> docs ;
var  currectUser ;
DocumentSnapshot documentsAds;
DocumentSnapshot documentsUser;
DocumentSnapshot documentMessages;
List<Widget> messages;
TextEditingController messageController = TextEditingController();
ScrollController scrollController = ScrollController();

var adImagesUrl =List<dynamic>();
bool showSlider=false;
bool showBody=false;

class _ShowAdState extends State<ShowAd> {
  String Messgetext;
  String documentId;
  int indexDocument;
  _ShowAdState({this.documentId, this.indexDocument});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   getDocumentValue();
  }

  getDocumentValue()async{
        DocumentReference documentRef =Firestore.instance.collection('Ads').document(documentId);
        documentsAds = await documentRef.get();
        adImagesUrl = documentsAds.data['imagesUrl'];
        setState(() {
          showSlider=true;
        });
        currectUser = await FirebaseAuth.instance.currentUser();
        DocumentReference documentRefUser =Firestore.instance.collection('users').document(currectUser.uid);
        documentsUser = await documentRefUser.get();
        setState(() {
          showBody =true;
        });

  }

  makePostRequest(token1,AdsN) async {
    currectUser = await FirebaseAuth.instance.currentUser();
    DocumentReference documentRefUser =Firestore.instance.collection('users').document(currectUser.uid);
    documentsUser = await documentRefUser.get();
    print("enter");
    final key1='AAAA3axJ_PM:APA91bF-QTmmVGRzpPvqvaE3xioEvuaBkGmj8JT2aG-puw3_83aSBnEdC5n8RGj78a1n_996CbwbVpk8OxYumCPP8vBAA7ykx7BrXXETkSU-EiySB2hD96Gx8JHsRnbXgyXp2-H9Qk29';
    final uri = 'https://fcm.googleapis.com/fcm/send';
    final headers = {'Content-Type': 'application/json',HttpHeaders.authorizationHeader:"key="+key1};
    Map<String, dynamic> title ={'title': "${documentsUser.data['name']} علق على  ${AdsN}","Mess":"${Messgetext}"};
    Map<String, dynamic> body = {'data': title,"to":token1};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    String responseBody = response.body;
    print(statusCode);
    print(responseBody);
  }
  final Firestore _firestore = Firestore.instance;
  Future<void> callBack() async {
    DocumentReference documentRef;

    var currentUser = await FirebaseAuth.instance.currentUser();
    if (messageController.text.length > 0){
      Messgetext=messageController.text;
      await _firestore.collection("messages").add({
        'text': Messgetext,
        'from': currentUser.email,
        'date': DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now()),
        'name': documentsUser['name'],
        'Ad_id':documentsAds.documentID
      });
      documentRef =Firestore.instance.collection('Ads').document(documentId);
      documentsAds = await documentRef.get();
      documentRef =Firestore.instance.collection('users').document(documentsAds.data['uid']);
      documentsUser = await documentRef.get();
      print("token"+documentsUser.data['token']);
      print(documentsAds.data['uid']);
      print(documentsUser.documentID);
      if(documentsAds.data['uid']!=currentUser.uid){
        makePostRequest(documentsUser.data['token'],documentsAds.data['name']);
      }

      setState(() {

      });
      messageController.clear();
      scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:showBody?
      Column(
        children: <Widget>[

          Expanded(
            child: ListView(
              controller: scrollController,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsUser['name'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 21,
                        fontFamily: 'AmiriQuran',
                        height: 0.7,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 130,),
                    InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_forward_ios,size: 30,)),
                  ],
                ),
                SizedBox(height: 5,),
                showSlider ?CarouselSlider(
                  items: adImagesUrl.map((url){
                    return Builder(
                        builder: (BuildContext context){
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, BouncyPageRoute(widget: PageImage(imageUrl: url)));
                            },
                            child: Container(
                              child:Hero(
                                  tag: Text('imageAd'),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(17),
                                      child: Image.network(url))),
                            ),
                          );
                        });
                  }).toList(),
                  options: CarouselOptions(
                      initialPage: 0,
                      autoPlay: true,
                      pauseAutoPlayOnTouch: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 900),
                      disableCenter:false,
                      height: 230
                  ),):Container(),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: (){

                      },
                      child: Container(
                        width: 130,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueAccent
                        ),
                        child: InkWell(
                          onTap: (){

                            messageController.clear();
                            scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('علق',textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'AmiriQuran',
                                  height: 0.7,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12,),
                              Icon(Icons.comment,color: Colors.white,),
                            ],
                          ),
                        ),
                      ),
                    ),InkWell(
                      onTap: (){
                        launch('tel:${documentsAds['phone']}');
                      },
                      child: Container(
                        width: 130,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueAccent
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('اتصل',textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'AmiriQuran',
                                height: 0.7,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12,),
                            Icon(Icons.call,color: Colors.white,),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20,bottom: 10,right: 10),
                    child: Text(documentsAds['name'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 21,
                        fontFamily: 'AmiriQuran',
                        height: 0.7,
                        color: Colors.black,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 4,bottom: 5,right: 10),
                    child: Text(documentsAds['time'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'AmiriQuran',
                        height: 0.7,
                        color: Colors.black,
                      ),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['area'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 80,),
                    Text(': المنطقة ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['description'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 80,),
                    Text(': الوصف ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['status'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 80,),
                    Text(': الحالة ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['category'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 80,),
                    Text(': القسم ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['department'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 40,),
                    Text(': القسم الفرعي ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 6,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['phone'],textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.black,
                      ),),
                    SizedBox(width: 80,),
                    Text(': موبايل ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 6,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[300]
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(documentsAds['price'].toString(),textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.red,
                      ),),
                    SizedBox(width: 80,),
                    Text(': السعر ',textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'AmiriQuran',
                        height: 1,
                        color: Colors.grey[700],
                      ),),
                    SizedBox(width: 10,)
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  width: MediaQuery.of(context).size.width-6,
                  height: 5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey
                  ),
                ),

                   Padding(
                    padding:EdgeInsets.only(top: 10,right: 10,left: 10),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection("messages").where('Ad_id',isEqualTo:documentId ).orderBy('date').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child:Column(
                              children: <Widget>[
                                CircularProgressIndicator(strokeWidth: 1,),
                                SizedBox(height: 8,),
                                Text('!...لا توجد تعليقات ',style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'AmiriQuran',
                                  height: 1,
                                  color: Colors.grey[500],
                                ),)
                              ],
                            )

                          );
                        }
                        docs = snapshot.data.documents;
                        List<Widget> messages = docs.map((doc) => Message(
                            from: doc.data["name"],
                            text: doc.data["text"],
                            time: doc.data['date'],
                            me: documentsUser['name'] == doc.data["name"]
                        )).toList();

                        return  Column(
                          children: <Widget>[

                                  ...messages,
                                ],

                        );
                      },
                    ),
                  ),

                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 42,
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10,left: 10),
                            child: TextField(
                              controller: messageController,
                              textAlign: TextAlign.right,
                              maxLines: 4,
                              decoration: InputDecoration(
                                  hintText: "!... اكتب تعليقك هنا",

                              ),
                              onSubmitted: (value) => callBack(),
                            ),
                          ),
                        ),
                        SendButton(
                          text: 'ارسل',
                          callback: callBack,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

        ],
      ):Text('Loading...')

    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    docs.clear();

  }
}

class PageImage extends StatefulWidget {
  String imageUrl;
  PageImage({Key key,@required this.imageUrl}):super(key: key);
  @override
  _PageImageState createState() => _PageImageState(imageUrl:imageUrl );
}

class _PageImageState extends State<PageImage> {
  String imageUrl;
  _PageImageState({Key key,@required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الصورة',style: TextStyle(
        fontSize: 30,
        fontFamily: 'AmiriQuran',
        height: 1,
        color: Colors.white,
      ),),),
      body:PhotoViewGallery.builder(
          itemCount: adImagesUrl.length,
          builder: (context,index){
            return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(adImagesUrl[index]),
              minScale: PhotoViewComputedScale.contained *0.8,
              maxScale: PhotoViewComputedScale.covered *2
            );

          },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        //loadingChild: CircularProgressIndicator(),
      )
    );

  }
}
class SendButton extends StatelessWidget {

  final String text;
  final VoidCallback callback;

  const SendButton({ Key key, this.text, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      color: Colors.orange,
      onPressed: callback,
      child: Text(text),
    );
  }
}


class Message extends StatelessWidget {

  final String from;
  final String text;
  final String time;

  final bool me;

  const Message({Key key, this.from, this.text, this.me,this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: me?Alignment(1, 0):Alignment(-1, 0),
      child: Padding(
        padding: EdgeInsets.only(top: 12),
        child: Container(
          child: Column(
            crossAxisAlignment: me? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(from,style: TextStyle(
                fontSize: 12,
                color: Colors.blue[800]
              ),),
              SizedBox(height: 2,),
              Material(
                color: me ? Colors.teal[100] : Colors.white70,
                borderRadius: BorderRadius.circular(5),
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  child:Column(
                    crossAxisAlignment: me?CrossAxisAlignment.end:CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          text,style: TextStyle(
                        fontSize: 15
                      ),
                      ),
                      SizedBox(height: 4,),
                      Text(time,style: TextStyle(
                        fontSize: 11,
                        color: Colors.deepOrange
                      ),)
                    ],
                  )

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
