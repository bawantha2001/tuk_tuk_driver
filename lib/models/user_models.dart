import 'package:firebase_database/firebase_database.dart';

class usermodel{
  String? phone;
  String? name;
  String? id;
  String? email;

  usermodel({
    this.email,
    this.id,
    this.name,
    this.phone
  });

  usermodel.fromSnapshot(DataSnapshot snapshot){
    phone=(snapshot.value as dynamic)['phone'];
    email=(snapshot.value as dynamic)['email'];
    id=(snapshot.value as dynamic)['id'];
    name=(snapshot.value as dynamic)['name'];
  }
}