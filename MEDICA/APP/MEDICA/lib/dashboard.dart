import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:telephony/telephony.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';


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
          title:  Align(
              alignment: Alignment.center,
              child: Text("Medica",
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontSize: 23)
                  ))),
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

  _sendSMS() async {
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
    await telephony.sendSms(
        to: "8126568193",
        message: "This is an attempt to send an alert from MEDICA, \n Location: Latitude: $userLat, longitude: $userLong",
        statusListener: listener
    );
    print('sms sent');
  }

  Timer ? _timer;
  int _start = 20;

  void startTimer() {
    const oneSec =  Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
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
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override

  Widget build(BuildContext context) {

    return Container(
      /*decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff93d3fa), Color(0xffffffff)])),*/
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          //color: Colors.red,//change later
          margin: const EdgeInsets.only(top: 35),
          child: Column(
            children :  <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                child:  Text(
                  "Your Location : ",
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(fontSize: 30)),
                ),
              ),

              Container(
                  margin: const EdgeInsets.only(top:10 ,left: 10),
                  child: Text('Longitude: $userLong\u00B0 \nLatitude: $userLat\u00B0',
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(fontSize: 16)
                    ),)),


              const SizedBox(
                height: 200,
              ),


              Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  gradient: const LinearGradient(
                    begin: Alignment(-1.0, 0.0),
                    end: Alignment(1.0, 0.0),
                    colors: [Color(0xff14279B), Color(0xff93d3fa)],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.transparent,
                    onSurface: Colors.transparent,
                    shadowColor: Colors.transparent,),

                  onPressed: (){
                    _getUserLocation();
                    setState(() {
                      _start = 20;
                    });
                    startTimer();

                    t = Timer(const Duration(seconds: 20), (){
                      _sendSMS();
                    });
                  },

                  child: const Center(
                    child: Text(
                      'Get location',
                      style: TextStyle(
                        fontFamily: 'Roboto Mono',
                        fontSize: 19,
                        color: Color(0xffffffff),
                        letterSpacing: -0.3858822937011719,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
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


              Container(
                width: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  //borderRadius: BorderRadius.circular(6.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xffe60b07), Color(0x55e60b07)],
                    stops: [0.0, 1.0],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.transparent,
                        onSurface: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: CircleBorder()),

                    onPressed: (){
                      if(_start > 0){
                        t!.cancel();
                        setState(() {
                          alertAborted = true;
                          _timer!.cancel();
                        });
                      }
                    },

                    child: const Center(
                      child: Text(
                        'ABORT',
                        style: TextStyle(
                          fontFamily: 'Roboto Mono',
                          fontSize: 19,
                          color: Color(0xffffffff),
                          letterSpacing: -0.3858822937011719,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
