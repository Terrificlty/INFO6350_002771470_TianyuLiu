//import 'package:exercise4/basic_hero_animation.dart';
//import 'package:exercise4/basic_radial_hero_animation.dart';
import 'package:exercise4/hero_animation.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(
    const MaterialApp(
      home: HeroAnimation(), // For hero_animation(standard hero animation)
      // home: BasicHeroAnimation(), // For basic_hero_animation(standard hero animation)
      // home: RadiaalHeroAnimation(), // For radial_hero_animation(radial hero animation)
        // home: BasicRadialHeroAnimation(), // For basic_radial_hero_animation(radial hero animation)
      // home: RadialHeroAnimationAnimateRectclip(), // For radial_hero_animation_animate_rectclip(radial hero animation)
    ),
  );
}