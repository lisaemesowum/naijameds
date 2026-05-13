
//  coming from firebase store where i add the database
class Medication {
  final String name;
  final String desc;
  final String price;

  //  constructor
  Medication({
    required this.name,
    required this.desc,
    required this.price,
  });




  // convert firebase data to medication object

  factory Medication.fromFirestore(Map<String, dynamic> data){
    return Medication(
    //   get name from firebase
      name: data["name"] ?? "", //  if name is null, return empty string

      desc: data["desc"] ?? "",

      price: data["price"] ?? "",
    );
  }
}
