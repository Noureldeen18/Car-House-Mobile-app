import 'dart:ui';

import '../../../constants/colors.dart';
import '../../../models/product_model.dart';

final List<Product> partsProducts = [
  Product(
    id: 401,
    images: ["assets/images/maintenance_parts/Ac Filter.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "AC Filter",
    price: 2000.00,
    rating: 4.1,
    category: "Maintenance Parts",
    description:
    "High-quality AC filter designed to provide clean and fresh air inside the cabin. "
        "It effectively removes dust, pollen, and other airborne particles, ensuring a healthier environment. "
        "Durable construction for long-lasting performance and easy installation.",
  ),
  Product(
    id: 402,
    images: ["assets/images/maintenance_parts/Air Filter.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Air Filter",
    price: 2500.00,
    rating: 4.7,
    category: "Maintenance Parts",
    description:
    "Efficient air filter engineered to protect your engine from harmful particles. "
        "Ensures optimal airflow for better combustion and improved fuel efficiency. "
        "Made with premium materials to resist clogging and extend engine life.",
  ),
  Product(
    id: 403,
    images: ["assets/images/maintenance_parts/Battery.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Battery",
    price: 3800.00,
    rating: 4.8,
    category: "Maintenance Parts",
    description:
    "Reliable automotive battery delivering consistent power for starting and running electrical systems. "
        "Designed for long-lasting performance with high cold-cranking amps. "
        "Maintenance-free and resistant to extreme temperatures.",
  ),
  Product(
    id: 404,
    images: ["assets/images/maintenance_parts/crankshaft rear seal.jpeg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Crankshaft Rear Seal",
    price: 1500.00,
    rating: 4.2,
    category: "Maintenance Parts",
    description:
    "Durable crankshaft rear seal designed to prevent oil leaks and maintain engine integrity. "
        "Manufactured with high-quality rubber compounds for heat and wear resistance. "
        "Ensures reliable sealing under high pressure and long-term use.",
  ),
  Product(
    id: 405,
    images: ["assets/images/maintenance_parts/Fuel Filter.jfif"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Fuel Filter",
    price: 1500.00,
    rating: 4.3,
    category: "Maintenance Parts",
    description:
    "High-performance fuel filter that removes impurities and contaminants from fuel. "
        "Ensures clean fuel delivery to the engine for optimal combustion. "
        "Helps improve fuel efficiency and prolong engine life.",
  ),
  Product(
    id: 406,
    images: ["assets/images/maintenance_parts/Headlight.jfif"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Headlight lamp",
    price: 2000.00,
    rating: 4.5,
    category: "Maintenance Parts",
    description:
    "Bright and durable headlight providing excellent visibility during night driving. "
        "Designed with advanced optics for focused light distribution. "
        "Resistant to weather conditions and built for long-lasting performance.",
  ),
  Product(
    id: 407,
    images: ["assets/images/maintenance_parts/Oil Filter.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Oil Filter",
    price: 500.00,
    rating: 4.4,
    category: "Maintenance Parts",
    description:
    "Premium oil filter that traps dirt, debris, and contaminants from engine oil. "
        "Ensures clean oil circulation for better lubrication and reduced wear. "
        "Built with durable materials to withstand high pressure and temperature.",
  ),
  Product(
    id: 408,
    images: ["assets/images/maintenance_parts/Rubber Blade.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Rubber Blade",
    price: 700.00,
    rating: 4.0,
    category: "Maintenance Parts",
    description:
    "High-quality rubber blade for windshield wipers. "
        "Provides streak-free cleaning and excellent durability. "
        "Designed to withstand UV rays and harsh weather conditions.",
  ),
  Product(
    id: 409,
    images: ["assets/images/maintenance_parts/Spark Plug.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Spark Plug",
    price: 1000.00,
    rating: 4.6,
    category: "Maintenance Parts",
    description:
    "High-performance spark plug ensuring efficient ignition and smooth engine operation. "
        "Provides reliable spark for better fuel combustion and improved acceleration. "
        "Built with advanced materials for long-lasting durability.",
  ),
  Product(
    id: 410,
    images: ["assets/images/maintenance_parts/V Belt.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "V Belt",
    price: 3000.00,
    rating: 4.3,
    category: "Maintenance Parts",
    description:
    "Durable V-belt designed to transfer power efficiently between engine components. "
        "Resistant to wear, heat, and stretching. "
        "Ensures smooth operation of alternators, water pumps, and other accessories.",
  ),
];
