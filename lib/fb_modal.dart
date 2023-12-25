
class UserD{
final  uId;
final  phone_number;
final  pickUpLat;
final  pickUpLng;
final  dropOffLat;
final  dropOffLng;
final  pickUpPlaceDetail;
final  dropOffPlaceDetail;

UserD({
  required this.uId,
  required this.phone_number,
  required this.pickUpLat,
  required this.pickUpLng,
  required this.dropOffLat,
  required this.dropOffLng,
  required this.pickUpPlaceDetail,
  required this.dropOffPlaceDetail,
  
  });
  toJson(){
    return{
      'phone':phone_number,
      'pickUpLat':pickUpLat,
      'pickUpLng':pickUpLng,
      'dropOffLat':dropOffLat,
      'dropOffLng':dropOffLng,
      'pickUpPlaceDetail':pickUpPlaceDetail,
      'dropOffPlaceDetail':dropOffPlaceDetail,
      'time':DateTime.now().toString()
    };
  }
}


