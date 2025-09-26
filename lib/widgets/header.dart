import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/logo.png', width: 40, height: 40),
        const SizedBox(width: 8),
        SvgPicture.asset('assets/app-name.svg', height: 30),
      ],
    );
  }
}
