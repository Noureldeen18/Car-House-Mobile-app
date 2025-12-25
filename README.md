# Car House Mobile App 🚗🏠

A high-quality Flutter mobile application for car services, spare parts, and workshop bookings, integrated with Supabase.

## ✨ Features

- **Authentication**: Secure login and signup via Supabase Auth (includes Password Reset flow).
- **Product Catalog**: Browse car parts and accessories with categories and filters.
- **Shopping Cart**: Manage items and seamless checkout process.
- **Workshop Bookings**: Schedule car maintenance and services easily.
- **Profile Management**: Update personal info and upload profile pictures to Supabase Storage.
- **Favorites**: Save your favorite products for quick access.
- **Order Tracking**: View history of your orders and their status.

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth, Database, Storage)
- **State Management**: Provider
- **Design**: Premium UI with smooth animations and custom icons.

## 🚀 Getting Started

1.  **Clone the repository**.
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Supabase Setup**:
    -   Create a project on [Supabase](https://supabase.com).
    -   Run the commands in `database.sql` in your Supabase SQL Editor.
    -   Configure your project URL and Anon Key in `lib/main.dart` or your environment config.
4.  **Run the app**:
    ```bash
    flutter run
    ```

## 📂 Project Structure

- `lib/services/`: Supabase integration and data fetching.
- `lib/models/`: Data models and schema definitions.
- `lib/views/`: UI screens and components organized by feature.
- `lib/constants/`: App theme colors and constants.

## 📝 Database Schema

The complete database schema, including tables for products, orders, bookings, and RLS policies, can be found in `database.sql`.

## 📄 License

This project is for graduation purposes.