import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RelativesPage extends StatefulWidget {
  const RelativesPage({Key? key}) : super(key: key);

  @override
  _RelativesPageState createState() => _RelativesPageState();
}

class _RelativesPageState extends State<RelativesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  var _userEmail;
  var userData;
  String data = '';
  String newName = '';
  int newPhone = 0;
  bool _isLoading = true;

  getCurrentUser() {
    _user = _auth.currentUser;
    print('user uid:');
    print(_user!.uid);
    print('user email: ');
    print(_user!.email);
    _userEmail = _user!.email;
  }

  getUserData() async {
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
    setState(() {
      data = userData.toString();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    getCurrentUser();
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFF2F2F2),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            :
            Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: userData.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          if (userData.length == 0) {
                            return Icon(Icons.refresh);
                          }
                          return ListTile(
                            minLeadingWidth: 0,

                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                              leading: Container(
                                padding: const EdgeInsets.only(right: 12.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        right: BorderSide(width: 1.0, color: Colors.white24))),
                                child: const Icon(Icons.person, color: Colors.blue),
                              ),
                              title: Text(
                                '${userData[index]['name']}',
                                style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(fontSize: 18,fontWeight: FontWeight.w300)),
                              ),

                              subtitle: Row(
                                children: <Widget>[
                                  const Icon(Icons.phone, color: Colors.blueGrey),
                                  Text('${userData[index]['contact']}', style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400))),
                                ],
                              ),
                              trailing: IconButton(
                                  icon : const Icon(Icons.delete), color: Colors.red,
                                onPressed: () async {
                                //delete contact from firebase function 1
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc('${_user!.uid}')
                                    .update({
                                  'ContactInfo': FieldValue.arrayRemove([
                                    userData[index]
                                  ])
                                });
                                setState(() {
                                  getUserData();
                                });;


                                  /*
                                 //delete from Firebase function 2
                                String name_to_be_deleted = userData[index]['name'].toString();
                                String contact_to_be_deleted = userData[index]['contact'].toString();
                                final collection = await FirebaseFirestore.instance.collection('users').doc('${_user!.uid}').update({
                                  'ContactInfo': FieldValue.arrayRemove([{'name':name_to_be_deleted , 'contact': contact_to_be_deleted}])
                                }).then((_) => print('Added'))
                                    .catchError((error) => print('Delete failed: $error'));*/
                                },),

                          );





                        }),
                  ),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      style : ElevatedButton.styleFrom(primary: Colors.blueGrey,
                          onSurface: Colors.transparent,
                          shadowColor: Colors.black87,
                          elevation: 10),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(

                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),

                                scrollable: true,
                                title: Text('Add new contact',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(fontSize: 27,fontWeight: FontWeight.w300)),),
                                content: Form(
                                  child: Column(
                                    children: [
                                      TextFormField(

                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            icon: Icon(Icons.person),

                                            labelText: 'Name*',
                                            labelStyle: TextStyle(fontSize: 13),
                                ),
                                        onChanged: (val){
                                          newName = val;
                                        },
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      TextFormField(

                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          icon: Icon(Icons.phone),
                                          labelText: 'Phone Number*',
                                          labelStyle: TextStyle(fontSize: 13),
                                        ),
                                        onChanged: (val){
                                          newPhone = int.parse(val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: ElevatedButton(
                                      style : ElevatedButton.styleFrom(primary: Colors.blue,
                                          onSurface: Colors.transparent,
                                          shadowColor: Colors.black87,
                                          elevation: 10,
                                          shape: CircleBorder()),
                                        child: const Icon(Icons.add),
                                        onPressed: () async{
                                          List<dynamic> newEntry = [{'name': newName, 'contact': newPhone}];
                                          await FirebaseFirestore.instance.collection('users').doc('${_user!.uid}').update({
                                            'ContactInfo': FieldValue.arrayUnion(newEntry)
                                          }).then((_) => print('Added'));
                                          Navigator.of(context).pop();
                                          getUserData();
                                        }
                                        ),
                                  )
                                ],
                              );
                            });
                      },
                      child: Text('Add Relatives',
                          style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(fontSize: 20))),
                    ),
                  )
                ],
              ));
  }
}


