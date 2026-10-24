import 'package:flutter/material.dart';
// In an actual Flutter project, replace this with the package import path:
// ignore: avoid_relative_lib_imports
import '../lib/gcoin_club/gcoin_club_screen.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false,
  home: GCoinClubScreen(lifetimeEligibleCoins: 2750)));
