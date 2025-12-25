import 'dart:ui';

import '../../../constants/colors.dart';
import '../../../models/product_model.dart';

final List<Product> fluidsProducts = [
  Product(
    id: 301,
    images: ["assets/images/maintenance_fluids/Brake Cleaner.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Brake Cleaner",
    price: 200.00,
    rating: 4.0,
    category: "Maintenance Fluids",
    description:
    "Brake cleaner formulated to remove dust, oil, and contaminants from braking components. "
        "Ensures optimal braking performance and prolongs the life of discs and pads. "
        "Quick-drying and leaves no residue, making it ideal for maintenance.",
  ),
  Product(
    id: 302,
    images: ["assets/images/maintenance_fluids/Brake Fluid DOT 3 (1L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Brake Fluid DOT 3 (1L)",
    price: 250.00,
    rating: 3.9,
    category: "Maintenance Fluids",
    description:
    "DOT 3 brake fluid designed for safe and consistent braking performance. "
        "Provides excellent protection against vapor lock and maintains stability under high temperatures. "
        "Ensures smooth hydraulic pressure transfer in the braking system.",
  ),
  Product(
    id: 303,
    images: ["assets/images/maintenance_fluids/Coolant (4L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Coolant (4L)",
    price: 800.00,
    rating: 4.2,
    category: "Maintenance Fluids",
    description:
    "Long-lasting coolant formulated to regulate engine temperature and prevent overheating. "
        "Provides anti-freeze protection and resists corrosion in the cooling system. "
        "Ideal for maintaining efficient performance in all weather conditions.",
  ),
  Product(
    id: 304,
    images: ["assets/images/maintenance_fluids/CVT Oil (4L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "CVT Oil (4L)",
    price: 3050.00,
    rating: 4.3,
    category: "Maintenance Fluids",
    description:
    "Specialized CVT oil designed for continuously variable transmissions. "
        "Ensures smooth gear shifting, reduces friction, and prolongs transmission life. "
        "Formulated to resist oxidation and maintain performance under extreme conditions.",
  ),
  Product(
    id: 305,
    images: ["assets/images/maintenance_fluids/Differential Oil (1L).webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Differential Oil (1L)",
    price: 400.00,
    rating: 4.1,
    category: "Maintenance Fluids",
    description:
    "High-quality differential oil that reduces wear and friction in gear systems. "
        "Provides excellent lubrication and heat resistance. "
        "Ensures smooth operation and extends the lifespan of differential components.",
  ),
  Product(
    id: 306,
    images: ["assets/images/maintenance_fluids/Engine Oil 5W-30 ( 4L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Engine Oil 5W-30 (4L)",
    price: 1800.00,
    rating: 4.6,
    category: "Maintenance Fluids",
    description:
    "Premium synthetic engine oil 5W-30 designed for modern engines. "
        "Provides superior protection against wear, reduces friction, and enhances fuel efficiency. "
        "Ensures smooth cold starts and stable performance at high temperatures.",
  ),
  Product(
    id: 307,
    images: ["assets/images/maintenance_fluids/Engine Oil 15W-40 (6L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Engine Oil 15W-40 (6L)",
    price: 1200.00,
    rating: 4.4,
    category: "Maintenance Fluids",
    description:
    "Heavy-duty engine oil 15W-40 suitable for diesel and high-performance engines. "
        "Provides excellent wear protection, maintains viscosity under stress, and resists breakdown. "
        "Ideal for vehicles operating under tough conditions.",
  ),
  Product(
    id: 308,
    images: ["assets/images/maintenance_fluids/Fome Cleaner.jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Foam Cleaner",
    price: 150.00,
    rating: 3.8,
    category: "Maintenance Fluids",
    description:
    "Multi-purpose foam cleaner for interior and exterior surfaces. "
        "Effectively removes dirt, grease, and stains while being gentle on materials. "
        "Leaves a fresh finish and is easy to apply.",
  ),
  Product(
    id: 309,
    images: ["assets/images/maintenance_fluids/T-IV ATF Oil (5L).jpg"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "T-IV ATF Oil (5L)",
    price: 3500.00,
    rating: 4.2,
    category: "Maintenance Fluids",
    description:
    "Automatic transmission fluid (ATF) T-IV designed for smooth gear shifting. "
        "Provides excellent thermal stability and oxidation resistance. "
        "Ensures long-lasting protection for transmission components.",
  ),
  Product(
    id: 310,
    images: ["assets/images/maintenance_fluids/Windshield Washer Fluid.webp"],
    colors: [
      Color(0xFFF6625E),
      Color(0xFF836DB8),
      Color(0xFFDECB9C),
      AppColors.white,
    ],
    title: "Windshield Washer Fluid",
    price: 60.00,
    rating: 3.9,
    category: "Maintenance Fluids",
    description:
    "Windshield washer fluid formulated to remove dirt, bugs, and debris from glass surfaces. "
        "Provides streak-free cleaning and enhances visibility. "
        "Safe for all vehicle types and effective in various weather conditions.",
  ),
];
