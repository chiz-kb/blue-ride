import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String verify = '';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+251";
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  String? phoneNo, verificationId;
  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode =
      const CountryCode(name: 'Ethiopia', code: 'ET', dialCode: '+251');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(230, 230, 230, 1),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/bajaj.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Pleas enter your phone number!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Form(
                  key: _formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () async {
                              final code = await countryPicker.showPicker(
                                  context: context);
                              if (code != null) countryCode = code;
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: countryCode.flagImage,
                                    ),
                                  ),
                                  Text(countryCode.dialCode),
                                  Icon(Icons.keyboard_arrow_down_rounded)
                                ],
                              ),
                            ),
                          )),
                      const Text(
                        "|",
                        style: TextStyle(fontSize: 33, color: Colors.grey),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: TextFormField(
                              maxLength: 9,

                              // textAlign: TextAlign.justify,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                counter: Offstage(),
                                border: InputBorder.none,
                                hintText: "Phone",
                                
                              ),
                              onChanged: (value) {
                                setState(() {
                                  phoneNo = value;
                                });
                              },
                            ),
                          ))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      await verifyPhoneNumber(phoneNo);
                    },
                    child: const Text("Send")),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhoneNumber(phoneNo) async {
    autoRetrieval(String verId) {
      verificationId = verId;
    }

    codeSent(String verId, int? resendToken) {
      verificationId = verId;
      LoginPage.verify = verId;
      Navigator.pushNamed(context, 'verify');
    }

    verificationCompleted(PhoneAuthCredential credential) async {
      FirebaseAuth.instance.signInWithCredential(credential);
    }

    // and if your number doesn't exist or doesn't match with your country code,Then this will show you an error message
    verfifailed(FirebaseAuthException exception) {
      if (exception.message == 'invalid-phone-number') {
        var snackBar = const SnackBar(content: Text('Invalid phone number!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        var snackBar = const SnackBar(content: Text('Invalid phone number!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      //Fluttertoast.showToast(msg: "${exception.message}"); //
    }

    if (phoneNo != null) {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '${countryController.text + phoneNo}',
          codeAutoRetrievalTimeout: autoRetrieval,
          codeSent: codeSent,
          timeout: const Duration(seconds: 30),
          verificationCompleted: verificationCompleted,
          verificationFailed: verfifailed);
    }
  }
}
