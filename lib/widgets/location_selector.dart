// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:plant_book/provider/plantdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlantProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select City Button
        ElevatedButton.icon(
          onPressed: () {
            _showCityPicker(context, provider);
          },
          icon: const Icon(Icons.pin_drop, color: AppTheme.lightGray),
          label: const Text(
            'Select City',
            style: TextStyle(color: AppTheme.lightGray),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
        ),
        const SizedBox(height: 10),

        // Show selected location
        if (provider.selectedCity != null && provider.selectedCountry != null)
          Text(
            'Selected: ${provider.selectedCity}, ${provider.selectedCountry}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightGrayBlue,
            ),
          ),
      ],
    );
  }

  void _showCityPicker(BuildContext context, PlantProvider provider) {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, String>> allCities = [];
    List<Map<String, String>> filteredCities = [];

    // Initially fetch some popular cities or all cities
    provider.fetchCities('').then((cities) {
      allCities = cities;
      filteredCities = List.from(allCities);
    });

    showModalBottomSheet(
      backgroundColor: AppTheme.darkGray,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
                  TextField(
                    controller: searchController,
                    style: TextStyle(color: AppTheme.lightGray),
                    decoration: InputDecoration(
                      labelText: 'Search City',
                      labelStyle: TextStyle(color: AppTheme.lightGray),
                      prefixIcon: Icon(Icons.search, color: AppTheme.lightGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        setState(() => filteredCities = List.from(allCities));
                        return;
                      }
                      final results = await provider.fetchCities(value);
                      setState(() => filteredCities = results);
                    },
                  ),
                  const SizedBox(height: 10),

                  // City List
                  SizedBox(
                    height: 400, // limit height of bottom sheet
                    child: filteredCities.isEmpty
                        ? const Center(
                            child: Text(
                              'Search City',
                              style: TextStyle(color: AppTheme.lightGrayBlue),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final cityData = filteredCities[index];
                              final city = cityData['city'] ?? '';
                              final country = cityData['country'] ?? '';
                              return ListTile(
                                title: Text(
                                  '$city, $country',
                                  style: TextStyle(color: AppTheme.lightGray),
                                ),
                                onTap: () {
                                  provider.setLocation(
                                    city: city,
                                    country: country,
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
