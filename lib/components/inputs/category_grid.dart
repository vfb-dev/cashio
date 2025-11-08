import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryGrid extends StatelessWidget {
  final String? selectedCategory;
  final Function(String label, int iconCode) onCategorySelected;

  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static List<Map<String, dynamic>> categories = [
    // 🍽️ Food & Drink
    {"icon": Icons.local_pizza, "labelKey": "categories.food".tr()},
    {"icon": Icons.restaurant, "labelKey": "categories.dining_out".tr()},
    {"icon": Icons.local_drink, "labelKey": "categories.drink".tr()},
    {"icon": Icons.local_cafe, "labelKey": "categories.coffee".tr()},
    {"icon": Icons.local_bar, "labelKey": "categories.alcohol".tr()},
    {
      "icon": Icons.local_grocery_store,
      "labelKey": "categories.groceries".tr(),
    },

    // 🏠 Housing & Utilities
    {"icon": Icons.home, "labelKey": "categories.housing".tr()},
    {"icon": Icons.lightbulb, "labelKey": "categories.light".tr()},
    {"icon": Icons.local_gas_station, "labelKey": "categories.gas".tr()},
    {"icon": Icons.water, "labelKey": "categories.water".tr()},
    {"icon": Icons.phone, "labelKey": "categories.phone".tr()},
    {"icon": Icons.wifi, "labelKey": "categories.internet".tr()},
    {
      "icon": Icons.cleaning_services,
      "labelKey": "categories.maintenance".tr(),
    },
    {"icon": Icons.chair, "labelKey": "categories.furniture".tr()},

    // 🚗 Transportation
    {"icon": Icons.directions_car, "labelKey": "categories.transport".tr()},
    {"icon": Icons.ev_station, "labelKey": "categories.fuel".tr()},
    {"icon": Icons.train, "labelKey": "categories.public_transport".tr()},
    {"icon": Icons.car_repair, "labelKey": "categories.car_maintenance".tr()},
    {"icon": Icons.local_parking, "labelKey": "categories.parking".tr()},
    {"icon": Icons.local_taxi, "labelKey": "categories.business_travel".tr()},

    // 💅 Shopping & Personal Care
    {"icon": Icons.shopping_bag, "labelKey": "categories.shopping".tr()},
    {"icon": Icons.style, "labelKey": "categories.clothing".tr()},
    {"icon": Icons.spa, "labelKey": "categories.beauty".tr()},
    {"icon": Icons.watch, "labelKey": "categories.accessories".tr()},

    // 💊 Health & Wellness
    {"icon": Icons.health_and_safety, "labelKey": "categories.health".tr()},
    {"icon": Icons.local_pharmacy, "labelKey": "categories.medicine".tr()},
    {"icon": Icons.fitness_center, "labelKey": "categories.fitness".tr()},
    {"icon": Icons.psychology, "labelKey": "categories.mental_health".tr()},

    // 🎓 Education
    {"icon": Icons.school, "labelKey": "categories.education".tr()},
    {"icon": Icons.menu_book, "labelKey": "categories.books".tr()},
    {"icon": Icons.computer, "labelKey": "categories.courses".tr()},
    {"icon": Icons.brush, "labelKey": "categories.art_supplies".tr()},

    // ✈️ Travel & Leisure
    {"icon": Icons.flight, "labelKey": "categories.travel".tr()},
    {"icon": Icons.hotel, "labelKey": "categories.accommodation".tr()},
    {"icon": Icons.map, "labelKey": "categories.tours".tr()},
    {"icon": Icons.beach_access, "labelKey": "categories.vacation".tr()},

    // 🎮 Entertainment & Subscriptions
    {"icon": Icons.movie, "labelKey": "categories.entertainment".tr()},
    {"icon": Icons.music_note, "labelKey": "categories.music".tr()},
    {"icon": Icons.videogame_asset, "labelKey": "categories.games".tr()},
    {"icon": Icons.tv, "labelKey": "categories.streaming".tr()},
    {"icon": Icons.event, "labelKey": "categories.events".tr()},

    // 🐾 Pets
    {"icon": Icons.pets, "labelKey": "categories.pets".tr()},

    // 💰 Finance & Savings
    {"icon": Icons.savings, "labelKey": "categories.savings".tr()},
    {"icon": Icons.account_balance, "labelKey": "categories.investments".tr()},
    {"icon": Icons.credit_card, "labelKey": "categories.debt_payment".tr()},

    // 🎁 Gifts & Donations
    {"icon": Icons.card_giftcard, "labelKey": "categories.gifts".tr()},
    {"icon": Icons.volunteer_activism, "labelKey": "categories.donations".tr()},
    {"icon": Icons.church, "labelKey": "categories.religious".tr()},

    // 👶 Family & Kids
    {"icon": Icons.child_care, "labelKey": "categories.childcare".tr()},
    {"icon": Icons.toys, "labelKey": "categories.toys".tr()},
    {"icon": Icons.school, "labelKey": "categories.kids_education".tr()},

    // 🏢 Work & Business
    {"icon": Icons.work, "labelKey": "categories.work".tr()},
    {"icon": Icons.computer, "labelKey": "categories.office_supplies".tr()},
    {"icon": Icons.payments, "labelKey": "categories.taxes".tr()},

    // 🌍 Miscellaneous
    {
      "icon": Icons.miscellaneous_services,
      "labelKey": "categories.services".tr(),
    },
    {"icon": Icons.security, "labelKey": "categories.insurance".tr()},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final String label = category["labelKey"];
        final IconData icon = category["icon"];
        final isSelected = selectedCategory == label;

        return GestureDetector(
          onTap: () => onCategorySelected(label, icon.codePoint),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade100
                      : const HSLColor.fromAHSL(1.0, 0, 0, 0.95).toColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Tooltip(
                message: label,
                waitDuration: const Duration(milliseconds: 500),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
