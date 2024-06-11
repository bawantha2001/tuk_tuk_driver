import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuk_tuk_project_driver/models/driver_data.dart';
import 'package:tuk_tuk_project_driver/models/user_models.dart';

import '../models/direction_details_info.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;


AssetsAudioPlayer audioPlayer= AssetsAudioPlayer();


String cloudMessaginServerToken = "";

usermodel? userModelCurrrentInfo;
Position? driverCurrentPosition;

List dList = [];

DriverData onlineDriverData=DriverData();

String? driverVehicleType='';

String? titleStarsRating='';