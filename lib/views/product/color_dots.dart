import 'package:flutter/material.dart';

import '../../models/product_model.dart';

class ColorDots extends StatelessWidget {
  final Product product;

  const ColorDots({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: product.colors.map((color) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26),
          ),
        );
      }).toList(),
    );
  }
}
