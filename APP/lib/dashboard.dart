import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:medica/loginPage.dart';
import 'package:telephony/telephony.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'function.dart';
import 'bluetooth.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
var _userEmail;
bool cancelVibration = false;
class Dashpage extends StatefulWidget {

  const Dashpage({Key? key}) : super(key: key);

  @override
  State<Dashpage> createState() => _DashpageState();
}

class _DashpageState extends State<Dashpage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff93d3fa), Color(0xffffffff)])),
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30)
              )
          ),
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            [
              SizedBox(width: 0),

              Text("Medica",
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontSize: 23)
                  )),

              IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  print(_userEmail);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(Icons.logout),

              ),

            ],

          ),
          flexibleSpace: Container(
            decoration:  BoxDecoration(
              //border: Border.all(color: Colors.red),//remove later
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: <Color>[Color(0xff14279B), Color(0x0014279B)]),
            ),
          ),
        ),
        body: const HomePage(),
        // bottomNavigationBar: BottomNavigationBar(
        //   onTap: (value){
        //     if(value==0) Navigator.pushNamed(context, '/relatives');
        //     if(value == 1){
        //
        //
        //     }
        //   },
        //   selectedItemColor: Colors.grey[600],
        //   selectedLabelStyle: TextStyle(fontSize: 15),
        //   selectedIconTheme:IconThemeData(opacity: 1) ,
        //   unselectedItemColor: Colors.grey[600],
        //   unselectedLabelStyle: TextStyle(fontSize: 15),
        //   unselectedIconTheme:IconThemeData(opacity: 1) ,
        //   items: <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.people),
        //       label: 'Emergency Contact',
        //
        //       activeIcon:null
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.bluetooth),
        //       label: 'Bluetooth',
        //       activeIcon:null
        //     ),
        //
        //   ],
        // ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  double ? userLong ;
  double ? userLat;
  bool alertSent = false;
  bool alertAborted = false;
  Timer ? t;
  String url = '';
  var userData;

  User? _user;
  var EmergencyContacts;


  getCurrentUser() {
    _user = _auth.currentUser;
    print('user uid:');
    print(_user!.uid);
    print('user email: ');
    print(_user!.email);
    _userEmail = _user!.email;
  }

  getUserData() async {
    getCurrentUser();
    DocumentSnapshot dataPath = await FirebaseFirestore.instance
        .collection('users')
        .doc('${_user!.uid}')
        .get();
    print('user data: ');
    if (dataPath.exists) {
      Map<String, dynamic> _userData = dataPath.data() as Map<String, dynamic>;
      print(_userData['ContactInfo']);
      userData = _userData['ContactInfo'];
    }
    EmergencyContacts = [for (var i = 0; i < userData.length; i++) userData[i]['contact']];
    print(EmergencyContacts);
    print('process ended');
  }

  _vibrate() async {
    //vibrate
    Timer.periodic(
      const Duration(seconds: 2),
          (Timer timer) async {
        if (cancelVibration || alertAborted || alertSent) {
          timer.cancel();
          cancelVibration  = false;
        }
         Vibration.vibrate(duration: 1000, amplitude: 255);

      },
    );
  }
  _getUserLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.longitude);
    print(_locationData.latitude);
    setState(() {
      userLat = _locationData.latitude;
      userLong = _locationData.longitude;
    });

  }

  _sendSMS1() async {

    final Telephony telephony = Telephony.instance;
    bool ? sms_permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    print('sending sms');
    final SmsSendStatusListener listener = (SendStatus status) {
      print(status);
      if(status == SendStatus.DELIVERED){
        setState(() {
          alertSent = true;
        });
      }
    };
    await getUserData();
    print("start sending sms");
    for(int i = 0; i < EmergencyContacts.length; i++){
      print('sending sms $i');
      print(EmergencyContacts[i]);
      await telephony.sendSms(
          to: EmergencyContacts[i].toString(),
          message: 'https://www.google.com/maps/preview?q=$userLat,$userLong',
          // message: 'This is an attempt to send an alert from MEDICA, Location: Latitude: $userLat, longitude: $userLong, Location: https://www.google.com/maps/preview?q=$userLat,$userLong',
          // message: 'This is an attempt to send an alert from MEDICA,Our system has predicted a possibility of you being in an emergency situation at location: Latitude: $userLat, longitude: $userLong List of Nearest Hospitals: \n ${data['0']['name']} \n ${data['1']['name']} \n ${data['2']['name']} \n ${data['3']['name']} \n ${data['4']['name']}',
          statusListener: listener
      );
      print('sent sms $i');
    }
    print('sms sent');
  }

  _sendSMS2() async {

    final Telephony telephony = Telephony.instance;
    bool ? sms_permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    print('sending sms');
    final SmsSendStatusListener listener = (SendStatus status) {
      print(status);
      if(status == SendStatus.DELIVERED){
        setState(() {
          alertSent = true;
        });
      }
    };
    await getUserData();
    print("start sending sms");
    for(int i = 0; i < EmergencyContacts.length; i++){
      print('sending sms $i');
      print(EmergencyContacts[i]);
      await telephony.sendSms(
          to: EmergencyContacts[i].toString(),
          // message: 'https://www.google.com/maps/preview?q=$userLat,$userLong',
          message: 'This is an attempt to send an alert from MEDICA, Location: Latitude: $userLat, longitude: $userLong. Please find the location below',
          // message: 'This is an attempt to send an alert from MEDICA,Our system has predicted a possibility of you being in an emergency situation at location: Latitude: $userLat, longitude: $userLong List of Nearest Hospitals: \n ${data['0']['name']} \n ${data['1']['name']} \n ${data['2']['name']} \n ${data['3']['name']} \n ${data['4']['name']}',
          statusListener: listener
      );
      print('sent sms $i');
    }
    print('sms sent');
  }

  Timer ? _timer;
  int _start = 20;
  int _popupstart = 20;

  void startTimer() {
    const oneSec =  Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0 ) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
  @override
  void initState(){
    super.initState();
    print('dashboard opened');
  }
  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: const EdgeInsets.only(top: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children :  <Widget>[



              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child:  Text(
                  "Current Location : ",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(fontSize: 40)),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                  ),
                  margin: const EdgeInsets.only(top:10 ,left: 10),
                  child: Text('Longitude: \n   $userLong\u00B0 \n\nLatitude: \n    $userLat\u00B0',
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(fontSize: 25)
                    ),)),
              const SizedBox(
                height: 50,
              ),

              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       primary: Colors.black,
              //       onPrimary: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30.0),
              //       ),
              //       minimumSize: Size(200, 50),
              //     ),
              //     onPressed: (){
              //       Navigator.push(context, MaterialPageRoute(builder:(_) => BluetoothApp())).then((value) async {
              //
              //         // if(shockValue > 8000){
              //         //   // you have come back to the pageA, now perform your logic
              //         //   print('returned after accident');
              //         //   await _vibrate();
              //         //   await _getUserLocation();
              //         //
              //         //   print('test1');
              //         //   // use 127.0.0.1:5000 for real phones and 10.0.2.2:5000 for emulator
              //         //   url = 'https://medica-api1.herokuapp.com/?lat=$userLat&long=$userLong';
              //         //   print('test2');
              //         //   await fetchdata(url);
              //         //   print('test3');
              //         //   setState(() {
              //         //     output_api = 'Nearest Hospital: ${data['0']['name']}';
              //         //     _start = 20;
              //         //   });
              //         //   startTimer();
              //         //   t = Timer(const Duration(seconds: 20), (){
              //         //     _sendSMS();
              //         //   });
              //         // }
              //         if(shockValue > 8000){
              //           showDialog(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return AlertDialog(
              //                   shape: RoundedRectangleBorder(
              //                       borderRadius: BorderRadius.circular(20.0)),
              //                   scrollable: true,
              //                   title: Text('Accident Detected',
              //                     style: GoogleFonts.montserrat(
              //                         textStyle: const TextStyle(fontSize: 27,fontWeight: FontWeight.w300)),),
              //                   content: Text('Our system has predicted a possibility of you being in an emergency situation. Kindly press the abort button if this is a false indication \n'),
              //                   actions: [
              //                     SizedBox(
              //                       width: 60,
              //                       height: 60,
              //                       child: ElevatedButton(
              //                           style : ElevatedButton.styleFrom(primary: Colors.blue,
              //                               onSurface: Colors.transparent,
              //                               shadowColor: Colors.black87,
              //                               elevation: 10,
              //                               shape: CircleBorder()),
              //                           child: const Icon(Icons.exposure_minus_1),
              //                           onPressed: () {
              //                                cancelVibration  = true;
              //                               if(_start > 0){
              //                                 t!.cancel();
              //                                 setState(() {
              //                                   alertAborted = true;
              //                                   _timer!.cancel();
              //                                 });
              //                             }
              //                               Navigator.of(context).pop();
              //                           }
              //                       ),
              //                     )
              //                   ],
              //                 );
              //               });
              //           // you have come back to the pageA, now perform your logic
              //           print('returned after accident');
              //           await _vibrate();
              //           await _getUserLocation();
              //           print('test1');
              //           // use 127.0.0.1:5000 for real phones and 10.0.2.2:5000 for emulator
              //           url = 'https://medica-api1.herokuapp.com/?lat=$userLat&long=$userLong';
              //           print('test2');
              //
              //           print('test3');
              //           startTimer();
              //           t = Timer(const Duration(seconds: 20), () async {
              //             await fetchdata(url);
              //             setState(() {
              //               output_api = 'List of Nearest Hospitals: \n ${data['0']['name']} \n ${data['1']['name']} \n ${data['2']['name']} \n ${data['3']['name']} \n ${data['4']['name']}';
              //             });
              //             _sendSMS();
              //           });
              //           setState(() {
              //             _start = 20;
              //           });
              //         }
              //
              //       });
              //       // Navigator.pushNamed(context, '/bluetooth');
              //     },
              //   child: Wrap(
              //     children: const <Widget>[
              //       Icon(
              //         Icons.bluetooth,
              //         color: Colors.lightBlue,
              //         size: 30.0,
              //       ),
              //       SizedBox(
              //         width:10,
              //       ),
              //       Text("Bluetooth", style:TextStyle(fontSize:20)),
              //       SizedBox(
              //         width: 10,
              //       )
              //     ],
              //   ),
              // ),


              // Container(
              //   width: 250,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(6.0),
              //     gradient: const LinearGradient(
              //       begin: Alignment(-1.0, 0.0),
              //       end: Alignment(1.0, 0.0),
              //       colors: [Color(0xff14279B), Color(0xff93d3fa)],
              //       stops: [0.0, 1.0],
              //     ),
              //   ),
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(primary: Colors.transparent,
              //       onSurface: Colors.transparent,
              //       shadowColor: Colors.transparent,),
              //
              //     onPressed: (){
              //       Navigator.pushNamed(context, '/relatives');
              //     },
              //     icon: const Icon(
              //       Icons.people,
              //       color: Colors.white,
              //       size: 30.0,
              //     ),
              //     label:  Center(
              //       child: Text(
              //         'Emergency Contacts',
              //         style: GoogleFonts.montserrat(
              //           textStyle: const TextStyle(fontSize: 17,fontWeight: FontWeight.w500,color: Color(0xFFC23131))
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),
              // ),


              // ElevatedButton(
              //
              //
              //   onPressed: () async {
              //     await _vibrate();
              //     await _getUserLocation();
              //
              //     print('test1');
              //     // use 127.0.0.1:5000 for real phones and 10.0.2.2:5000 for emulator
              //     url = 'https://medica-api1.herokuapp.com/?lat=$userLat&long=$userLong';
              //     print('test2');
              //     await fetchdata(url);
              //     print('test3');
              //     setState(() {
              //       output_api = 'Nearest Hospital: ${data['0']['name']}';
              //       _start = 20;
              //     });
              //     startTimer();
              //     t = Timer(const Duration(seconds: 20), (){
              //       _sendSMS();
              //     });
              //   },
              //   child: const Text(
              //     'Get location',
              //   ),
              // ),


              alertSent == true ? Align(
                alignment: Alignment.center,
                child: Text('Alert sent!' ,
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(fontSize: 20)
                    )),
              ) : Container(),
              alertAborted == true ? Align(
                alignment: Alignment.center,
                child: Text('Aborted' ,
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(fontSize: 20)
                    )),
              ) : Container(),
              Text(output_api, style: TextStyle(fontSize: 20),),
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Align(
                    alignment: Alignment.center,
                    child:
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: "Time left until alert is sent : ",
                            style: TextStyle(color: Colors.black87, fontSize: 20)),
                        TextSpan(
                            text: " ${_start}s",
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 23)),
                      ]),
                    )
                ),
              ),
              Column(
                children: [
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton.icon(
                      style : ElevatedButton.styleFrom(primary: Colors.black,
                          onSurface: Colors.transparent,
                          shadowColor: Colors.black87,
                          elevation: 10),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder:(_) => BluetoothApp())).then((value) async {

                          // if(shockValue > 8000){
                          //   // you have come back to the pageA, now perform your logic
                          //   print('returned after accident');
                          //   await _vibrate();
                          //   await _getUserLocation();
                          //
                          //   print('test1');
                          //   // use 127.0.0.1:5000 for real phones and 10.0.2.2:5000 for emulator
                          //   url = 'https://medica-api1.herokuapp.com/?lat=$userLat&long=$userLong';
                          //   print('test2');
                          //   await fetchdata(url);
                          //   print('test3');
                          //   setState(() {
                          //     output_api = 'Nearest Hospital: ${data['0']['name']}';
                          //     _start = 20;
                          //   });
                          //   startTimer();
                          //   t = Timer(const Duration(seconds: 20), (){
                          //     _sendSMS();
                          //   });
                          // }
                          if(shockValue > 8000){
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  Future.delayed(Duration(seconds: 22)).then((_) {
                                    cancelVibration  = true;
                                    Navigator.of(context).pop();
                                  });
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)),
                                    scrollable: true,
                                    title: Text('Accident Detected',
                                      style: GoogleFonts.montserrat(
                                          textStyle: const TextStyle(fontSize: 27,fontWeight: FontWeight.w300)),),
                                    content: Text('Our system has predicted a possibility of you being in an emergency situation. Kindly press the abort button if this is a false indication \n'),
                                    actions: [
                                      ElevatedButton.icon(
                                          style : ElevatedButton.styleFrom(primary: Colors.blue,
                                              onSurface: Colors.transparent,
                                              shadowColor: Colors.black87,
                                              elevation: 10,
                                             ),
                                          icon: const Icon(Icons.cancel),
                                          label: Text("Cancel"),
                                          onPressed: () {
                                            // cancelVibration  = true;
                                            if(_start > 0){
                                              t!.cancel();
                                              setState(() {
                                                alertAborted = true;
                                                _timer!.cancel();
                                              });
                                            }

                                            Navigator.of(context).pop();
                                            cancelVibration  = true;
                                            _start = 20;

                                            shockValue = 0;

                                          }
                                      )
                                    ],
                                  );
                                });
                            // you have come back to the pageA, now perform your logic
                            print('returned after accident');
                            await _vibrate();
                            await _getUserLocation();
                            print('test1');
                            // use 127.0.0.1:5000 for real phones and 10.0.2.2:5000 for emulator
                            url = 'https://medica-api1.herokuapp.com/?lat=$userLat&long=$userLong';
                            print('test2');

                            print('test3');
                            startTimer();
                            t = Timer(const Duration(seconds: 20), () async {
                              await fetchdata(url);
                              setState(() {
                                output_api = 'List of Nearest Hospitals: \n ${data['0']['name']}: 09816351133\n ${data['1']['name']}: 01905226278 \n ${data['2']['name']}: 01905223469 \n ${data['4']['name']}: 01905281231';
                              });
                              _sendSMS2();
                              _sendSMS1();
                            });
                            setState(() {
                              _start = 20;
                            });
                          }

                        });
                        // Navigator.pushNamed(context, '/bluetooth');
                      },
                      label: Text('Bluetooth',
                          style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(fontSize: 20))),
                      icon: const Icon(
                        Icons.bluetooth,
                        color: Colors.lightBlue,),
                    ),



                  ),
                  SizedBox(height: 5,),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton.icon(
                      style : ElevatedButton.styleFrom(primary: Colors.black,
                          onSurface: Colors.transparent,
                          shadowColor: Colors.black87,
                          elevation: 10),
                      onPressed: () {
                        Navigator.pushNamed(context, '/relatives');
                      },
                      label: Text('Emergency Contacts',
                          style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(fontSize: 20,color: Colors.white))),
                      icon: Icon(Icons.people),
                    ),



                  )
                ],
              ),






              // Container(
              //   width: 250,
              //   decoration: const BoxDecoration(
              //     shape: BoxShape.circle,
              //     //borderRadius: BorderRadius.circular(6.0),
              //     gradient: LinearGradient(
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //       colors: [Color(0xffe60b07), Color(0x55e60b07)],
              //       stops: [0.0, 1.0],
              //     ),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(20.0),
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(primary: Colors.transparent,
              //           onSurface: Colors.transparent,
              //           shadowColor: Colors.transparent,
              //           shape: CircleBorder()),
              //
              //       onPressed: (){
              //         cancelVibration  = true;
              //         if(_start > 0){
              //           t!.cancel();
              //           setState(() {
              //             alertAborted = true;
              //             _timer!.cancel();
              //           });
              //         }
              //       },
              //
              //       child: const Center(
              //         child: Text(
              //           'ABORT',
              //           style: TextStyle(
              //             fontFamily: 'Roboto Mono',
              //             fontSize: 19,
              //             color: Color(0xffffffff),
              //             letterSpacing: -0.3858822937011719,
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

}
