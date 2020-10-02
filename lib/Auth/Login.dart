import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:souq_alfurat/Auth/Register2.dart';
import 'package:souq_alfurat/Service/PushNotificationService.dart';
import 'package:souq_alfurat/models/StaticVirables.dart';
import 'package:souq_alfurat/ui/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "LoginScreen";
  bool autoLogin  ;
  LoginScreen({this.autoLogin});
  @override
  _LoginScreenState createState() => _LoginScreenState(autoLogin: autoLogin);
}

double screenSizeWidth;
double screenSizeHieght;
bool loginStatus = false;
bool checkboxVal = false;
bool logout ;
bool checkLogin=false;
class _LoginScreenState extends State<LoginScreen> {
  bool autoLogin ;
  _LoginScreenState({this.autoLogin});

  void initState() {
    super.initState();
    if (autoLogin == false) {
      checkboxVal = false;
    } else {
      checkAutoLogin();
    }
  }

  checkAutoLogin()async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    if(sharedPref.getBool('autoLogin') ==true){
      setState(() {
        checkboxVal = sharedPref.getBool('autoLogin');
        if(checkboxVal){
          autoLoginF();
        }
      });
    }

    print(checkboxVal);
  }
  autoLoginF()async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    setState(() {
      _passwordcontroller = TextEditingController(text: sharedPref.getString('password'));
      _emailcontroller = TextEditingController(text: sharedPref.getString('email'));
    });

    Timer(Duration(milliseconds: 100),(){
      login();
    });
  }
  saveLoginAutoStatus()async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool('autoLogin',autoLogin);
  }
  saveShared() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('email', _emailcontroller.text);
    sharedPref.setString('password', _passwordcontroller.text);
    sharedPref.setInt('navigatorSelect', 1);
  }

  login() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    if (_formkey.currentState.validate()) {
      saveShared();
      var result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailcontroller.text, password: _passwordcontroller.text);
      if (result != null) {
        _firebaseMessaging.getToken().then((token) async {
          print("token: " + token);
          Firestore.instance
              .collection('users')
              .document(result.user.uid)
              .updateData({
            "token": token,
          });
        });
        loginStatus = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        print('user not found');
      }
    }
  }

  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    screenSizeWidth = MediaQuery.of(context).size.width;
    screenSizeHieght = MediaQuery.of(context).size.height;
    Virables.screenSizeWidth = screenSizeWidth;
    Virables.screenSizeHeight = screenSizeHieght;
    Virables.login = loginStatus;
    Virables.autoLogin = logout;
    return Scaffold(
      body:Container(
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formkey,
            child: ListView(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 5)),
                Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'AmiriQuran',
                      height: 1,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                ClipRRect(
                  child: Image.asset('assets/images/souq1624wpng.png'),
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                TextFormField(
                  controller: _emailcontroller,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني  (الإيميل)',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Fill Email Input';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _passwordcontroller,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please Fill Password Input';
                    }
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'AmiriQuran',
                        height: 1),
                  ),
                  onPressed: () async {
                    login();
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('تسجيل دخول تلقائي',style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 18,
                        fontFamily: 'AmiriQuran',
                        height: 1),),
                    Checkbox(value: checkboxVal, onChanged: (bool val){
                      autoLogin = val;
                      setState(() {
                        checkboxVal = val;
                      });
                      saveLoginAutoStatus();
                    },

                    ),
                  ],
                ),
                SizedBox(
                  height: 1,
                ),
                RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    'تسجيل مستخدم جديد ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'AmiriQuran',
                        height: 1),
                  ),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen2()));
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Home()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      color: Color(0xffF26726),),
                    width: 324,
                    height: 59,
                    child: Center(child: Text('تصفح في السوق كزائر',style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'AmiriQuran',
                        height: 1),)),
                  ),
                ),
              ],
            )),
      ),
    );
  }

}
