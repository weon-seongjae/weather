import 'package:flutter/material.dart';

var theme = ThemeData(
  iconTheme: IconThemeData( color: Colors.blue),
  appBarTheme: AppBarTheme(
  color: Colors.white,
  actionsIconTheme: IconThemeData(color: Colors.black),
  elevation: 1,
  titleTextStyle: TextStyle( color : Colors.black, fontSize: 25),
  ),
  textTheme: TextTheme(bodyMedium: TextStyle( color: Colors.black, fontSize: 15, )
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
  )
);