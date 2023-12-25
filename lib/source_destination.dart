import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class SourceDestScreen extends StatelessWidget {
  const SourceDestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromRGBO(230, 230, 230, 1),
                        spreadRadius: 1,
                        blurRadius: 1)
                  ]),
              child: TextField(
                readOnly: true,
                onTap: () async {
                  const kGoogleApiKey =
                      "AIzaSyCEFmYjU1qSau0zS3G_LedL89cTNkhZ6KA";
                  Prediction? p = await PlacesAutocomplete.show(
                    offset: 0,
                    radius: 1000,
                    strictbounds: false,
                    region: "et",
                    language: "en",
                    context: context,
                    mode: Mode.overlay,
                    apiKey: kGoogleApiKey,
                    components: [Component(Component.country, "et")],
                    types: ["(cities)"],
                    hint: "Search City",
                    // 8.5373948,37.9587504   8.5383244 37.9731622
                  );
                },
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.search),
                    ),
                    border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromRGBO(230, 230, 230, 1),
                        spreadRadius: 1,
                        blurRadius: 1)
                  ]),
              child: const TextField(
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                decoration: InputDecoration(
                    hintText: 'Destination',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.search),
                    ),
                    border: InputBorder.none),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
