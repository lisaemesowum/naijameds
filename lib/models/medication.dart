
//  coming from firebase store where i add the database
class Medication {
  final String name;
  final String desc;
  final String price;
  final String image;

  //  constructor
  Medication({
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
  });




  // convert firebase data to medication object

  factory Medication.fromFirestore(Map<String, dynamic> data){
    return Medication(
    //   get name from firebase
      name: data["name"] ?? "", //  if name is null, return empty string

      desc: data["desc"] ?? "",

      price: data["price"] ?? "",

      image: data['image'] ?? '',

    );
  }
}
