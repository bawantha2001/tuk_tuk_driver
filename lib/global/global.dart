import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuk_tuk_project_driver/models/user_models.dart';

import '../models/direction_details_info.dart';

final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
User? currentUser;

String cloudMessaginServerToken = "";

usermodel? userModelCurrrentInfo;
List dList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
String driverCardDetails = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titleStarRating = "";

