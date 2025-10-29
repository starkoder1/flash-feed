import 'package:flash_feed/ui/screens/home/home_page.dart';
import 'package:flash_feed/ui/screens/home/home_page_controller.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/ui/widgets/category_card.dart';
import 'package:flash_feed/ui/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Set<String> _selectedCategories = {};

  void toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: secondaryShade,
        title: Text(
          "CATEGORIES",
          style: GoogleFonts.manrope(
            color: primaryShade,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.business_center_outlined,
                    title: "Business",
                    backgroundColor: const Color(0xFFE7F8EA),
                    iconColor: Colors.green,
                    isSelected: _selectedCategories.contains("Business"),
                    onTap: () => toggleCategory("Business"),
                  ),
                  const SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.restaurant_outlined,
                    title: "Food & Culture",
                    backgroundColor: const Color(0xFFEAF2FF),
                    iconColor: Colors.blue,
                    isSelected: _selectedCategories.contains("Food & Culture"),
                    onTap: () => toggleCategory("Food & Culture"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.coffee_outlined,
                    title: "Office Productivity",
                    backgroundColor: const Color(0xFFFFE8E7),
                    iconColor: Colors.red,
                    isSelected: _selectedCategories.contains(
                      "Office Productivity",
                    ),
                    onTap: () => toggleCategory("Office Productivity"),
                  ),
                  const SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Finance & Accounting",
                    backgroundColor: const Color(0xFFFFF4E5),
                    iconColor: Colors.orange,
                    isSelected: _selectedCategories.contains(
                      "Finance & Accounting",
                    ),
                    onTap: () => toggleCategory("Finance & Accounting"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.computer_outlined,
                    title: "IT & SOFTWARE",
                    backgroundColor: Color(0xFFEAF2FF),
                    iconColor: Colors.blue,
                    isSelected: _selectedCategories.contains("IT & SOFTWARE"),
                    onTap: () => toggleCategory("IT & SOFTWARE"),
                  ),
                  const SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.water_drop_outlined,
                    title: "Weather",
                    backgroundColor: Color(0xFFF8EAF8),
                    iconColor: Colors.purple,
                    isSelected: _selectedCategories.contains("weather"),
                    onTap: () => toggleCategory("weather"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.psychology_outlined,
                    title: "Personal Development",
                    backgroundColor: Color(0xFFEAF2FF),
                    iconColor: Colors.indigo,
                    isSelected: _selectedCategories.contains(
                      "Personal Development",
                    ),
                    onTap: () => toggleCategory("Personal Development"),
                  ),
                  const SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.design_services_outlined,
                    title: "Design",
                    backgroundColor: Color(0xFFE7F8EA),
                    iconColor: Colors.green,
                    isSelected: _selectedCategories.contains("Design"),
                    onTap: () => toggleCategory("Design"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.camera_alt_outlined,
                    title: "Photography & Video",
                    backgroundColor: Color(0xFFEAF2FF),
                    iconColor: Colors.blue,
                    isSelected: _selectedCategories.contains(
                      "Photography & Video",
                    ),
                    onTap: () => toggleCategory("Photography & Video"),
                  ),
                  SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.calendar_month_outlined,
                    title: "Lifestyle",
                    backgroundColor: Color(0xFFEAF2FF),
                    iconColor: Colors.blue,
                    isSelected: _selectedCategories.contains("Lifestyle"),
                    onTap: () => toggleCategory("Lifestyle"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CategoryCard(
                    icon: Icons.favorite_border_outlined,
                    title: "Health & Fitness",
                    backgroundColor: Color(0xFFE7F8EA),
                    iconColor: Colors.blue,
                    isSelected: _selectedCategories.contains(
                      "Health & Fitness",
                    ),
                    onTap: () => toggleCategory("Health & Fitness"),
                  ),
                  SizedBox(width: 10),
                  CategoryCard(
                    icon: Icons.calendar_month_outlined,
                    title: "Development",
                    backgroundColor: const Color(0xFFFFF4E5),
                    iconColor: Colors.orange,
                    isSelected: _selectedCategories.contains("Development"),
                    onTap: () => toggleCategory("Development"),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomElevatedButton(
                text: "Save & next",
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageController(),
                    ),
                    (route) => false,
                  );
                },
                txtColor: Colors.white,
                btnHeight: 48,
                btnWidth: 180,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
