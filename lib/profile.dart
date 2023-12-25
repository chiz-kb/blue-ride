import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String phoneNo = FirebaseAuth.instance.currentUser!.phoneNumber!;
    //String name ='';
   // String uid = FirebaseAuth.instance.currentUser!.uid;
  //  var  user_data = DataBaseService(uid: uid).getData();
    //String na = user_data['name'] as String;
    //TextEditingController nameController = TextEditingController( text: '$user_data[name]' );
    TextEditingController phoneController =TextEditingController(text: '$phoneNo');
    return Scaffold(
      body: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      'Profile',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: ()async {
                      //  final names={'name':name};
                        //await DataBaseService(uid: uid).updateUserData(names);
                      },
                      child: Container(
                        height: 40,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
            const CircleAvatar(
              radius: 35,
              child: Icon(Icons.person),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              child: TextFormField(
               // controller: nameController,
                onChanged: (value) {
                //  name = value;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your username',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
              child: TextFormField(
                enabled: false,
                controller: phoneController,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Phone Number',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle()),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                   Navigator.of(context).pushNamedAndRemoveUntil( 'home', (route) => false);
                },
                child: const Text('Delete my account'))
          ],
        ),
      ),
    );
  }
}
