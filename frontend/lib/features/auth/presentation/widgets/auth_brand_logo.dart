import 'package:flutter/material.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({
    super.key,
    this.height = 88,
    this.width,
    this.padding = EdgeInsets.zero,
  });

  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        'assets/images/logo/wahforpatients_horizontal.png',
        height: height,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
