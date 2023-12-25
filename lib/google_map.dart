import 'dart:async';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:blue_ride/address_search.dart';
import 'package:blue_ride/places_service.dart';
import 'fb_modal.dart';
import 'my_drawer.dart';
import 'dart:convert';
// import 'package:uuid/uuid.dart';

const double _minHeight = 250;
const double _maxHeight = 635;
 double requestRideContainerHieght=0;

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample>
  with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PlaceApiProvider _placeApi = PlaceApiProvider.instance;
  final _destinationController = TextEditingController();
  late var _pickupController = TextEditingController();
  static LatLng curPos = LatLng(8.8378814392663, 37.977293668373086);
  var initialPosDetail;
  late LatLng dropOfLocation;
  late LatLng PickUplocation;
  bool isRequested = false;
  bool isPick = false;
  bool search = false;
  bool ride_rq=false;
  List<Suggestion> _predictions = [];
  bool f =false;
 
  _inputOnChanged(String query) {
    if (query.trim().length > 2) {
      setState(() {
        search = true;
      });
      _search(query);
    } else {
      if (search || _predictions.length > 0) {
        setState(() {
          search = false;
          _predictions = [];
        });
      }
    }
  }

  _search(String query) {
    _placeApi.fetchSuggestions(query).asStream().listen((List<Suggestion> predictions) {
      setState(() {
        search = false;
        _predictions = predictions;
        //  print('Resultados: ${predictions.length}');
      });
    });
  }
  getLoc(placeId) async {
    LatLng loc = await _placeApi.fetchLatLang(placeId);
    setState(() {
      isPick?curPos=loc: dropOfLocation = loc;
    });
    // print('here is it $dropOfLocation');
  }

  late AnimationController _animationController;
  double _currentHeight = _minHeight;
  double heading = 30;
  _determinePosition() async {
    var loc = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best);
    initialPosDetail =await PlaceApiProvider().fetchPlace(loc.latitude, loc.longitude);
    TextEditingController pickUpController =  TextEditingController(text: '$initialPosDetail');
    setState(() {
      curPos = LatLng(loc.latitude, loc.longitude);
      heading = loc.heading;
      _pickupController = pickUpController;
    });
   
  }
  late String uId;
  late String phone;
  final db = FirebaseFirestore.instance;

  bookOrder({pickUpLat,pickUpLng,dropOffLat,dropOffLng,pickUpPlaceDetail,dropOffPlaceDetail})async{
    String phoneNumber=phone;
    final docRef = db.collection('order').doc(uId);
    UserD user = UserD(
     uId:uId,
     phone_number:phoneNumber,
     pickUpLat: pickUpLat,
     pickUpLng:pickUpLng,
     dropOffLat:dropOffLat,
     dropOffLng:dropOffLng,
     pickUpPlaceDetail:pickUpPlaceDetail,
     dropOffPlaceDetail:dropOffPlaceDetail
   );
   const snackBar1 = SnackBar(
   content: Text('Appointment booked successfully!'),
    );
    const snackBar2 = SnackBar(
   content: Text('Error booking appointment'),
    );
   await docRef.set(user.toJson()).then(
     (value) => ScaffoldMessenger.of(context).showSnackBar(snackBar1),
     onError: (e) => ScaffoldMessenger.of(context).showSnackBar(snackBar2));
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _determinePosition();
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 650));
    getUserInfo();
    super.initState();
  }
 
  getUserInfo()async{
   var cUser=await FirebaseAuth.instance.currentUser;
    phone=cUser!.phoneNumber!;
    uId=cUser.uid;
  }
  @override
  void dispose() {
    _destinationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  // double _originLatitude = 8.5378814392663, _originLongitude =  37.977293668373086;
  // double _destLatitude = 8.5678814392663, _destLongitude = 37.997293668373086;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        width: 6,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCEFmYjU1qSau0zS3G_LedL89cTNkhZ6KA',
      PointLatLng(curPos.latitude, curPos.longitude),
      PointLatLng(dropOfLocation.latitude, dropOfLocation.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }
  void OpenRequestRide(){
    setState(() {
      ride_rq?requestRideContainerHieght=250:requestRideContainerHieght=0;
    });
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height / 3.4;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: curPos == const LatLng(8.8378814392663, 37.977293668373086)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: h),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      // polylines: ,
                      initialCameraPosition: CameraPosition(
                        target: curPos,
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      polylines: Set<Polyline>.of(polylines.values),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 10,
                    child: CircleAvatar(
                      maxRadius: 25,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.black,
                        ),
                        onPressed: _openDrawer,
                      ),
                    ),
                  ),
                  
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        final newHeight = _currentHeight - details.delta.dy;
                        _animationController.value =
                            _currentHeight / _maxHeight;
                        _currentHeight = newHeight.clamp(0, _maxHeight);
                      });
                    },
                    onVerticalDragEnd: (details) {
                      if (_currentHeight < _maxHeight / 2) {
                        setState(() {
                          _animationController.reset();
                        });
                      } else {
                        setState(() {
                          _animationController.forward(
                              from: _currentHeight / _maxHeight);
                          _currentHeight = _maxHeight;
                        });
                      }
                    },
                    child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, snapshot) {
                          final value = _animationController.value;
                          return Stack(children: [
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 0,
                              height: isRequested
                                  ? _minHeight
                                  : lerpDouble(_minHeight, _maxHeight, value),
                              child: _draggable(),
                            ),
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 0,
                              height: lerpDouble(0, 400, value),
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    search
                                        ? const Expanded(
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                                physics: ScrollPhysics(
                                                parent:
                                                AlwaysScrollableScrollPhysics()),
                                                scrollDirection: Axis.vertical,
                                                itemCount: _predictions.length,
                                                itemBuilder: (_, i) {
                                                  final Suggestion item =
                                                      _predictions[i];
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                       !isPick  ? _destinationController.text =item.description: _pickupController.text =item.description;
                                                       _predictions = [];
                                                         //print(dropOfLocation);
                                                      });
                                                      await getLoc(
                                                       item.placeId);
                                                       isRequested = true;
                                                      if (!isPick)
                                                      {
                                                        _getPolyline();
                                                       // print(_destinationController.text.trim());
                                                       // print(_pickupController.text.trim());
                                                        _animationController.reverse();
                                                       // _destinationController.text='';   
                                                        // _pickupController.clear();
                                                      }
                                                    },
                                                    child: ListTile(
                                                      title: Text(
                                                          item.description),
                                                      leading: Icon(
                                                          Icons.location_on),
                                                    ),
                                                  );
                                             }))
                                  ],
                                ),
                              ),
                            ),
                          ]);
                        }),
                  ),
                  AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, snapshot) {
                        return Positioned(
                          right: 0,
                          left: 0,
                          top: isRequested
                              ? -170
                              : -170 * (1 - _animationController.value),
                          child: SizedBox(height: 170, child: _appBar()),
                        );
                      }),
                  AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, snapshot) {
                        return Positioned(
                          left: 0,
                          right: 0,
                          bottom: isRequested
                              ? -50
                              : -50 * (1 - _animationController.value),
                          child: PickPlaceMap(),
                        );
                      }),
                      Positioned(
                    child: RequestRide(context),
                    left: 0,
                    bottom: 0,
                    right: 0,
                    ),
                ],
              ),
        drawer: MyDrawer(),
        drawerEnableOpenDragGesture: false,
      ),
    );
  }
  Widget _appBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      title: const Text(
        'Enter Pickup',
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _animationController.reverse();
            _currentHeight = 0.0;
          });
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21.5),
          child: Column(children: [
            _Input(
              enabled: false,
              controller: _pickupController,
              iconData: Icons.gps_fixed,
              color: Colors.green,
              hintText: 'Enter pickup',
              onTap: () {
                isPick = true;
              },
              onChanged: _inputOnChanged,
            ),
            const SizedBox(
              height: 9,
            ),
            Row(
              children: [
                _Input(
                  controller: _destinationController,
                  iconData: Icons.place_sharp,
                  color: Colors.indigo,
                  hintText: 'Enter destination',
                  onChanged: _inputOnChanged,
                  onTap: () {
                    isPick = false;
                  },
                ),
                const Expanded(
                    child: Icon(
                  Icons.add,
                  size: 25,
                ))
              ],
            ),
            const SizedBox(
              height: 10,
              // child: Suggestion.description.length>0?Padding(padding: null,):Container();
            )
          ]),
        ),
      ),
    );
  }

  Widget _draggable() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0, -1),
              blurRadius: 3,
            )
          ],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: isRequested
          ? _requestRide()
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 35,
                  color: Colors.grey[300],
                  height: 3.5,
                ),
                _searchButton(),
                LocationListTile('Enter home location', Icons.home),
                LocationListTile('Enter work location', Icons.work),
              ],
            ),
    );
  }

  Widget _requestRide() {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          //margin: const EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 5),
          width: 35,
          color: Colors.grey[300],
          height: 3.5,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          height: 50,
          width: MediaQuery.of(context).size.width / 1.1,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            left: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[200],
          ),
          child: Row(
            children: const [
              Icon(
                Icons.car_crash,
                size: 30,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Bajaj',
                style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                '300m away',
                style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isRequested = false;
              polylines.clear();
              polylineCoordinates.clear();
              _destinationController.clear();
              dropOfLocation=LatLng(0, 0);
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 50,
            width: MediaQuery.of(context).size.width / 1.1,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ),
        GestureDetector(
          onTap: ()async {
           await bookOrder(
               pickUpLat: curPos.latitude,
               pickUpLng: curPos.longitude,
               dropOffLat: dropOfLocation.latitude,
               dropOffLng: dropOfLocation.longitude,
               pickUpPlaceDetail: _pickupController.text,
               dropOffPlaceDetail:_destinationController.text );
            setState( ()
            { 
              isRequested = false;
              polylines.clear();
              polylineCoordinates.clear();
              _destinationController.clear();
              ride_rq =true;
              OpenRequestRide();
            });
            
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 50,
            width: MediaQuery.of(context).size.width / 1.1,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.blue,
            ),
            child: const Text(
              'Request',
              style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _searchButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _animationController.forward(from: 1);
          _currentHeight = _maxHeight;
        });
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 1.1,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey[200],
        ),
        child: const Text(
          'Where to',
          style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  Widget RequestRide(BuildContext context){
  const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
    ];

   const colorizeTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Horizon',
  
);

return Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),
    color: Colors.white,
    boxShadow: [
      BoxShadow(spreadRadius: 0.5,blurRadius: 16,color: Colors.black54,offset: Offset(0.7, 0.7))
    ],
    
  ),
  height: requestRideContainerHieght,
  child:   Column(
    children: [
      SizedBox(height: 12,),
      SizedBox(
      
        width: MediaQuery.of(context).size.width/ 1,
      
        child: AnimatedTextKit(
      
          animatedTexts: [
      
            ColorizeAnimatedText(
      
              'Requesting Ride...',
              textAlign: TextAlign.center,
              textStyle: colorizeTextStyle,
      
              colors: colorizeColors,
      
            ),
      
            ColorizeAnimatedText(
      
              'Pleas wait...',
              textAlign: TextAlign.center,
              textStyle: colorizeTextStyle,
      
              colors: colorizeColors,
      
            ),
      
            ColorizeAnimatedText(
      
            'Finding driver...',
              textAlign: TextAlign.center,
              textStyle: colorizeTextStyle,
      
              colors: colorizeColors,
      
            ),
      
          ],
      
          isRepeatingAnimation: true,
      
          onTap: () {
      
            print("Tap Event");
      
          },
      
        ),
      
      ),
      SizedBox(height: 22,),
      GestureDetector(
        onTap: (){
          ride_rq =false;
          OpenRequestRide();
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(26),
          border: Border.all(width: 2,color: Colors.grey)
          ),
          
          child:Icon(Icons.close,color: Colors.grey,size: 20,)
        ),
      ),
      SizedBox(height: 10,),
      Container(child: Text('Cancel Request',textAlign: TextAlign.center,),)
    ],
  ),
);
}
}
  
class PriedictionTile extends StatelessWidget {
  final Suggestion suggestion;
  const PriedictionTile({Key, key, required this.suggestion}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.add_location),
            SizedBox(
              width: 14,
            ),
            Expanded(
              child: Text(
                suggestion.description,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            )
          ]),
        ],
      ),
    );
  }
}


class _Input extends StatelessWidget {
  const _Input(
      {super.key,
      this.iconData,
      this.onChanged,
      this.hintText,
      this.onTap,
      this.enabled,
      this.controller,
      this.color});

  final IconData? iconData;
  final void Function(String)? onChanged;
  final String? hintText;
  final TextEditingController? controller;
  final Function()? onTap;
  final bool? enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(iconData, size: 19, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width / 1.4,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey[200]),
            child: TextField(
              onChanged: onChanged,
              onTap: onTap,
              enabled: enabled,
              controller: controller,
              keyboardType: TextInputType.name,
              decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }
}

class LocationListTile extends StatelessWidget {
  final String head;
  final IconData icon;
  LocationListTile(this.head, this.icon);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 37, top: 26),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 22,
          ),
          Text(
            head,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

class PickPlaceMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black54, offset: Offset(-1, 0), blurRadius: 2)
      ]),
      padding: EdgeInsets.all(10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.place_sharp,
          color: Colors.grey,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Choose on map',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
        )
      ]),
    );
  }
}

