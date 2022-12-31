import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dashboard.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

String username = '';
String password = '';
bool formCompleted = false;

class _RegistrationPageState extends State<RegistrationPage> {
  void validateForm (){
    if(username.length != 0 && password.length > 5){
      formCompleted =true;
    }else{
      formCompleted = false;
    }
  }
  bool signupObscure = true;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  User? _user;
  var _userEmail;
  var userData;
  getCurrentUser() {
    _user = _auth.currentUser;
    print('user uid:');
    print(_user!.uid);
    print('user email: ');
    print(_user!.email);
    _userEmail = _user!.email;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        color: Color(0xff14279B),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeadClipper(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                        TextField(
                          onChanged: (val){
                            username = val;
                            setState(() {validateForm();});
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: customBoxStyle.copyWith(
                              hintText: 'Enter your e-mail id'
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                        TextField(
                          onChanged: (val){
                            password = val;
                            setState(() {validateForm();});
                          },
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          obscureText: signupObscure,
                          decoration: customBoxStyle.copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.remove_red_eye, color: Colors.grey),
                                onPressed: (){
                                  setState(() {
                                    signupObscure = signupObscure == true ? false : true;
                                  });
                                },
                              ),
                              hintText: 'Minimum 6 characters requires'
                          ),
                        ),
                        SizedBox(height: 15.0),
                        GestureDetector(
                          onTap: () async{
                            if(formCompleted){
                              setState(() {
                                showSpinner = true;
                              });
                              try{
                                final newUser = await _auth.createUserWithEmailAndPassword(email: username, password: password);
                                if(newUser != null){
                                  await getCurrentUser();
                                  await FirebaseFirestore.instance.collection('users').doc('${_user!.uid}').set({
                                    'ContactInfo': {}
                                  });
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => Dashpage()),
                                        (Route<dynamic> route) => false,
                                  );
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              }catch(e){
                                print(e);
                              }
                            }else{
                              null;
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text('Sign up', style: TextStyle(fontSize: 20.0, color: Colors.white)),
                            decoration: BoxDecoration(
                                color: formCompleted ? Color(0xff14279B) : Color(0xff14279B).withOpacity(0.5)
                            ),
                          ),
                        ),
                      ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}