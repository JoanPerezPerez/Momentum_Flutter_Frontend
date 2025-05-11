import 'package:flutter/material.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/widgets/business_container.dart';
import 'package:momentum/controllers/cataleg_controller.dart';
import 'package:get/get.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int ButtonAllOrFavorite = 0;
  int selectedFilterIndex = -1;
  final CatalegController catalegController = Get.find<CatalegController>();
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> buttons = [
    {'text': 'Tots', 'icon': Icons.list_alt},
    {'text': 'Favorits', 'icon': Icons.favorite},
  ];

  final List<String> filters = [
    'Tipus de servei',
    'Ciutat',
    'Obert a ...',
    'Valoració',
    'Distància',
    'Disponibilitat',
  ];

  final List<locationServiceType> serviceTypes = locationServiceType.values;

  @override
  void initState() {
    super.initState();
    catalegController.getAllBusiness();
    catalegController.getCitiesFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catàleg')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(buttons.length, (index) {
                final isSelected = ButtonAllOrFavorite == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        ButtonAllOrFavorite = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
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
                            child:
                                isSelected
                                    ? Text(
                                      buttons[index]['text'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
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
            // Fila amb buscador + botó de mapa
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.map, color: Colors.white),
                    onPressed: () {
                      Get.toNamed(AppRoutes.map);
                    },
                  ),
                ),
              ],
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
                        setState(() {
                          selectedFilterIndex = index;
                        });
                        if (filters[index] == 'Tipus de servei') {
                          _showServiceTypeSelector();
                        } else if (filters[index] == 'Ciutat') {
                          _showCitySelector();
                        } else if (filters[index] == 'Obert a ...') {
                          _showOpenAtSelector();
                        } else if (filters[index] == 'Valoració') {
                          _showRatingSelector();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.blue
                                    : const Color.fromARGB(127, 33, 150, 243),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color.fromARGB(178, 33, 150, 243),
                            fontSize: 14,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
            Obx(() {
              if (catalegController.selectedServices.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Serveis seleccionats:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          catalegController.selectedServices
                              .map(
                                (service) => Chip(
                                  label: Text(service.description),
                                  backgroundColor: Colors.blue[100],
                                  onDeleted: () {
                                    catalegController.toggleService(
                                      service,
                                      false,
                                    );
                                    _applyFilters();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            // Ciutats seleccionades
            Obx(() {
              if (catalegController.selectedCities.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ciutats seleccionades:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          catalegController.selectedCities
                              .map(
                                (city) => Chip(
                                  label: Text(city),
                                  backgroundColor: Colors.blue[100],
                                  onDeleted: () {
                                    catalegController.toggleCity(city, false);
                                    _applyFilters();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            // Obert a...
            Obx(() {
              final day = catalegController.selectedOpenDay.value;
              final time = catalegController.selectedOpenTime.value;
              if (day != null && time != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Obert a:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text('${day.capitalizeFirst}, $time'),
                          backgroundColor: Colors.blue[100],
                          onDeleted: () {
                            catalegController.setSelectedOpenDayAndTime(
                              null,
                              null,
                            );
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(() {
              final rating = catalegController.ratingMin.value;
              if (rating != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valoració mínima:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      children: [
                        Chip(
                          label: Text('$rating ★'),
                          backgroundColor: Colors.blue[100],
                          onDeleted: () {
                            catalegController.setRatingMin(null);
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            Expanded(
              child: Obx(() {
                final businesses = catalegController.businesses;

                if (businesses.isEmpty) {
                  return Center(child: Text("No s'han trobat negocis."));
                }

                return ListView.builder(
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    return BusinessContainer(business: businesses[index]);
                  },
                );
              }),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...serviceTypes.map((service) {
                          return CheckboxListTile(
                            value: catalegController.selectedServices.contains(
                              service,
                            ),
                            title: Text(service.description),
                            onChanged: (bool? value) {
                              setModalState(() {
                                catalegController.toggleService(
                                  service,
                                  value ?? false,
                                );
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
    _applyFilters();
  }

  void _showCitySelector() async {
    final TextEditingController cityController = TextEditingController();

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
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona ciutat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '')
                            return const Iterable<String>.empty();
                          return catalegController.listCities.where(
                            (String city) => city.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          );
                        },
                        onSelected: (String selected) {
                          setModalState(() {
                            catalegController.toggleCity(selected, true);
                            cityController.clear();
                          });
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onEditingComplete,
                        ) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: 'Escriu una ciutat...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onEditingComplete: onEditingComplete,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Ciutats seleccionades:'),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          children:
                              catalegController.selectedCities
                                  .map(
                                    (city) => Chip(
                                      label: Text(city),
                                      onDeleted: () {
                                        setModalState(() {
                                          catalegController.toggleCity(
                                            city,
                                            false,
                                          );
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    setState(() {});
    _applyFilters();
  }

  void _showOpenAtSelector() async {
    String? selectedDay;
    TimeOfDay? selectedTime;

    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

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
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtra per dia i hora d\'obertura',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedDay,
                        decoration: const InputDecoration(
                          labelText: 'Dia',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            daysOfWeek.map((day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(
                                  day[0].toUpperCase() + day.substring(1),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedDay = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          selectedTime?.format(context) ?? 'Selecciona hora',
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    // Només aplicar si els dos estan seleccionats
    if (selectedDay != null && selectedTime != null) {
      final String formattedTime =
          '${selectedTime?.hour.toString().padLeft(2, '0')}:${selectedTime?.minute.toString().padLeft(2, '0')}';
      catalegController.setSelectedOpenDayAndTime(selectedDay, formattedTime);
      _applyFilters();
    }
  }

  void _showRatingSelector() async {
    double selectedRating = catalegController.ratingMin.value ?? 0;

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
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona valoració mínima',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: selectedRating,
                        min: 0,
                        max: 5,
                        divisions: 20,
                        label: selectedRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setModalState(() {
                            selectedRating = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${selectedRating.toStringAsFixed(1)} ⭐ o més',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    catalegController.setRatingMin(selectedRating);
    _applyFilters();
  }

  void _applyFilters() {
    final filters = {
      // Llistes
      if (catalegController.selectedServices.isNotEmpty)
        "serviceTypes":
            catalegController.selectedServices
                .map((s) => s.description)
                .toList(),
      if (catalegController.selectedCities.isNotEmpty)
        "cities": catalegController.selectedCities.toList(),

      // Dia i hora "obert a..."
      if (catalegController.selectedOpenDay.value != null)
        "day": catalegController.selectedOpenDay.value,
      if (catalegController.selectedOpenTime.value != null)
        "time": catalegController.selectedOpenTime.value,
      if (catalegController.ratingMin.value != null)
        "ratingMin": catalegController.ratingMin.value,
    };

    print('Filtres aplicats: $filters');
    catalegController.getFilteredBusiness(filters);
  }
}
