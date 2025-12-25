import 'dart:ui';

import '../../../constants/colors.dart';
import '../../../models/product_model.dart';

final List<Product> engineProducts = [
  Product(
    id: 201,
    images: ["assets/images/engine/alternator.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Alternator",
    price: 34950.00,
    rating: 4.8,
    category: "Engine Parts",
    description:
    "The alternator is responsible for generating electrical power to keep your battery charged "
        "and supply electricity to all vehicle systems. Built with high-efficiency components, "
        "it ensures consistent performance, durability, and reliability even under heavy loads.",
  ),
  Product(
    id: 202,
    images: ["assets/images/engine/compressor.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Compressor",
    price: 67850.00,
    rating: 4.6,
    category: "Engine Parts",
    description:
    "High-performance compressor designed to maintain optimal engine efficiency. "
        "It provides consistent air compression for various systems, ensuring smooth operation "
        "and improved fuel economy. Manufactured with durable materials to withstand extreme conditions.",
  ),
  Product(
    id: 203,
    images: ["assets/images/engine/cylinder head.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Cylinder Head",
    price: 52200.00,
    rating: 4.8,
    category: "Engine Parts",
    description:
    "Durable cylinder head engineered with excellent heat resistance and precision machining. "
        "It plays a critical role in housing the combustion chamber and valves, ensuring efficient "
        "fuel combustion and engine performance. Built to last under high pressure and temperature.",
  ),
  Product(
    id: 204,
    images: ["assets/images/engine/Ignition coil.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Ignition Coil",
    price: 4425.00,
    rating: 4.4,
    category: "Engine Parts",
    description:
    "Ignition coil designed to deliver the necessary voltage to spark plugs for efficient combustion. "
        "Ensures smooth engine start and reliable performance. Built with high-quality insulation "
        "to resist heat and electrical stress.",
  ),
  Product(
    id: 205,
    images: ["assets/images/engine/Injectors.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Fuel Injectors",
    price: 7980.00,
    rating: 4.5,
    category: "Engine Parts",
    description:
    "Precision fuel injectors that deliver the right amount of fuel into the combustion chamber. "
        "They improve fuel efficiency, reduce emissions, and enhance engine performance. "
        "Manufactured with advanced technology for long-lasting reliability.",
  ),
  Product(
    id: 206,
    images: ["assets/images/engine/Radiator.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Radiator",
    price: 26143.00,
    rating: 4.7,
    category: "Engine Parts",
    description:
    "High-quality radiator designed to dissipate heat and maintain optimal engine temperature. "
        "Ensures efficient cooling under heavy loads and extreme conditions. "
        "Built with corrosion-resistant materials for durability.",
  ),
  Product(
    id: 207,
    images: ["assets/images/engine/Starter Motor.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Starter Motor",
    price: 15500.00,
    rating: 4.6,
    category: "Engine Parts",
    description:
    "Reliable starter motor that provides the initial power to start the engine. "
        "Engineered for quick response and consistent performance. "
        "Durable construction ensures long service life.",
  ),
  Product(
    id: 208,
    images: ["assets/images/engine/Thermostat.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Thermostat",
    price: 980.00,
    rating: 4.2,
    category: "Engine Parts",
    description:
    "Engine thermostat regulates coolant flow to maintain optimal operating temperature. "
        "Prevents overheating and ensures efficient fuel combustion. "
        "Compact and durable design for long-term reliability.",
  ),
  Product(
    id: 209,
    images: ["assets/images/engine/turbo.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Turbocharger",
    price: 28540.00,
    rating: 4.9,
    category: "Engine Parts",
    description:
    "High-performance turbocharger that boosts engine power by forcing more air into the combustion chamber. "
        "Improves acceleration, fuel efficiency, and overall performance. "
        "Designed with advanced engineering for durability and reduced lag.",
  ),
  Product(
    id: 210,
    images: ["assets/images/engine/Water Pump.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Water Pump",
    price: 5160.00,
    rating: 4.3,
    category: "Engine Parts",
    description:
    "Durable water pump that circulates coolant throughout the engine to prevent overheating. "
        "Ensures consistent cooling and reliable performance. "
        "Built with precision bearings and seals for long-lasting operation.",
  ),
];
