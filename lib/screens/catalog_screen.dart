import 'package:flutter/material.dart';
import 'package:momentum/models/business_model.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/widgets/business_container.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int selectedButtonIndex = 0;
  int selectedFilterIndex = -1;

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> buttons = [
    {'text': 'Tots', 'icon': Icons.list_alt},
    {'text': 'Favorits', 'icon': Icons.favorite},
  ];

  final List<String> filters = [
    'Tipus de servei',
    'Ciutat',
    'Distància',
    'Disponibilitat',
    'Valoració',
  ];

  final List<locationServiceType> serviceTypes = locationServiceType.values;
  Set<locationServiceType> selectedServices = {};

  // Simulació de llista de BusinessWithLocations
  final List<BusinessWithLocations> businesses = [
    BusinessWithLocations(
      id: '1',
      name: 'Empresa A',
      locations: [
        ILocation(
          id: 'loc1',
          nombre: 'Gimnàs Barcelona',
          address: 'Carrer X, Barcelona',
          phone: '123456789',
          rating: 4.8,
          ubicacion: GeoJSONPoint(type: 'Point', coordinates: [2.15, 41.38]),
          serviceType: [locationServiceType.GYM_SESSION, locationServiceType.YOGA_CLASS],
          schedule: [],
          business: '1',
          workers: [],
          isDeleted: false,
        ),
        ILocation(
          id: 'loc2',
          nombre: 'Restaurant Girona',
          address: 'Carrer Y, Girona',
          phone: '987654321',
          rating: 4.2,
          ubicacion: GeoJSONPoint(type: 'Point', coordinates: [2.82, 41.98]),
          serviceType: [locationServiceType.RESTAURANT_BOOKING],
          schedule: [],
          business: '1',
          workers: [],
          isDeleted: false,
        ),
      ],
      isDeleted: false,
    ),
    BusinessWithLocations(
      id: '2',
      name: 'Empresa B',
      locations: [
        ILocation(
          id: 'loc3',
          nombre: 'Hotel Madrid Centre',
          address: 'Gran Via, Madrid',
          phone: '111222333',
          rating: 4.7,
          ubicacion: GeoJSONPoint(type: 'Point', coordinates: [-3.7038, 40.4168]),
          serviceType: [locationServiceType.MEDICAL_APPOINTMENT],
          schedule: [],
          business: '2',
          workers: [],
          isDeleted: false,
        ),
        ILocation(
          id: 'loc4',
          nombre: 'Spa Relax Sevilla',
          address: 'Avinguda la Paz, Sevilla',
          phone: '444555666',
          rating: 4.9,
          ubicacion: GeoJSONPoint(type: 'Point', coordinates: [-5.9845, 37.3891]),
          serviceType: [locationServiceType.MASSAGE],
          schedule: [],
          business: '2',
          workers: [],
          isDeleted: false,
        ),
      ],
      isDeleted: false,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catàleg'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botons petits
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(buttons.length, (index) {
                final isSelected = selectedButtonIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedButtonIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            buttons[index]['icon'],
                            color: isSelected ? Colors.white : Colors.black,
                            size: 24,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isSelected ? 8 : 0,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: isSelected
                                ? Text(
                                    buttons[index]['text'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Buscador
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
            const SizedBox(height: 20),
            // Row de filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(filters.length, (index) {
                  final isSelected = selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (filters[index] == 'Tipus de servei') {
                          _showServiceTypeSelector();
                        }
                        setState(() {
                          selectedFilterIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : const Color.fromARGB(127, 33, 150, 243),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color.fromARGB(178, 33, 150, 243),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Serveis seleccionats
            if (selectedServices.isNotEmpty) ...[
              const Text(
                'Serveis seleccionats:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: selectedServices
                    .map((service) => Chip(
                          label: Text(service.description),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            // 👇 Aquí comencem a mostrar la llista d'empreses
            Expanded(
              child: ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  return BusinessContainer(business: businesses[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceTypeSelector() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecciona tipus de servei',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...serviceTypes.map((service) {
                          return CheckboxListTile(
                            value: selectedServices.contains(service),
                            title: Text(service.description),
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedServices.add(service);
                                } else {
                                  selectedServices.remove(service);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    setState(() {});
  }
}
