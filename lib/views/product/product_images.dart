import 'package:flutter/material.dart';

import '../../models/product_model.dart';

class ProductImages extends StatelessWidget {
  final Product product;

  const ProductImages({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: product.images.length,
        itemBuilder: (context, index) => Image.asset(product.images[index]),
      ),
    );
  }
}
