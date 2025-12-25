import 'package:flutter/material.dart';

import '../../models/product_model.dart';

class ProductDescription extends StatelessWidget {
  final Product product;
  final VoidCallback pressOnSeeMore;

  const ProductDescription({
    Key? key,
    required this.product,
    required this.pressOnSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(product.description,
              maxLines: 3, overflow: TextOverflow.ellipsis),
          TextButton(
            onPressed: pressOnSeeMore,
            child: const Text("See More"),
          ),
        ],
      ),
    );
  }
}
