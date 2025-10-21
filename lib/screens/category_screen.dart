import 'package:flash_feed/widgets/category_card.dart';
import 'package:flash_feed/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Category",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: const [
                CategoryCard(
                  icon: Icons.business_center_outlined,
                  title: "Business",
                  backgroundColor: Color(0xFFE7F8EA),
                  iconColor: Colors.green,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  icon: Icons.restaurant_outlined,
                  title: "Food & Culture",
                  backgroundColor: Color(0xFFEAF2FF),
                  iconColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                CategoryCard(
                  icon: Icons.coffee_outlined,
                  title: "Office Productivity",
                  backgroundColor: Color(0xFFFFE8E7),
                  iconColor: Colors.red,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Finance & Accounting",
                  backgroundColor: Color(0xFFFFF4E5),
                  iconColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                CategoryCard(
                  icon: Icons.computer_outlined,
                  title: "IT & Software",
                  backgroundColor: Color(0xFFEAF2FF),
                  iconColor: Colors.blue,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  icon: Icons.work_outline,
                  title: "Office Productivity",
                  backgroundColor: Color(0xFFF8EAF8),
                  iconColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                CategoryCard(
                  icon: Icons.psychology_outlined,
                  title: "Personal Development",
                  backgroundColor: Color(0xFFEAF2FF),
                  iconColor: Colors.indigo,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  icon: Icons.design_services_outlined,
                  title: "Design",
                  backgroundColor: Color(0xFFE7F8EA),
                  iconColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                CategoryCard(
                  icon: Icons.camera_alt_outlined,
                  title: "Photography & Video",
                  backgroundColor: Color(0xFFEAF2FF),
                  iconColor: Colors.blue,
                ),
                SizedBox(width: 10),
                CategoryCard(
                  icon: Icons.favorite_outline,
                  title: "Health & Fitness",
                  backgroundColor: Color(0xFFE7F8EA),
                  iconColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomElevatedButton(
              text: "Get Started",
              txtColor: Colors.white,
              hPadding: 64,
              vPadding: 12,
              onTap: () {},
              icon: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
