import 'package:flutter/material.dart';
import 'package:momentum/models/business_model.dart'; 
import 'package:momentum/models/location_model.dart';
import 'package:momentum/widgets/card/location_card.dart'; 

class BusinessContainer extends StatelessWidget {
  final BusinessWithLocations business;

  const BusinessContainer({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3ECF3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            business.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: business.locations.length,
              itemBuilder: (context, index) {
                return LocationCard(location: business.locations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
