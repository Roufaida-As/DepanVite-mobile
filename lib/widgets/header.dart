import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/headerlogo.png'),
        // const SizedBox(width: 8),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: SvgPicture.asset('assets/app-name.svg', height: 30),
        // ),
      ],
    );
  }
}
