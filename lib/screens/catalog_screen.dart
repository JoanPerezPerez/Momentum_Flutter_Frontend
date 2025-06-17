import 'package:flutter/material.dart';
import 'package:momentum/models/location_model.dart';
import 'package:momentum/routes/app_routes.dart';
import 'package:momentum/widgets/business_container.dart';
import 'package:momentum/controllers/cataleg_controller.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int ButtonAllOrFavorite = 0;
  int selectedFilterIndex = -1;
  final CatalegController catalegController = Get.find<CatalegController>();
  final AuthController authController = Get.find<AuthController>();
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
    'Accessibilitat',
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
                      if (index == 0) {
                        catalegController.getAllBusiness();
                      } else if (index == 1) {
                        catalegController.getFavoriteBusinesses(authController.currentUser.value.id);
                      }
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
                    onSubmitted: (value) {
                      setState(() {
                        ButtonAllOrFavorite = 0;
                      });
                      _onSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar empresa o botiga...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            ButtonAllOrFavorite = 0;
                          });
                          _onSearch(searchController.text);
                        },
                      ),
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
                    icon: const Icon(Icons.medical_services, color: Colors.white),
                    onPressed: () {
                      Get.toNamed(AppRoutes.medical);
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
                        } else if (filters[index] == 'Distància') {
                          _showDistanceSelector();
                        } else if (filters[index] == 'Disponibilitat') {
                          _showAvailabilitySelector();
                        } else if (filters[index] == 'Accessibilitat') {
                          setState(() {
                            catalegController.setAccessible(!catalegController.accessible.value);
                            _applyFilters();
                          });
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
            Obx(() {
              final distance = catalegController.maxDistanceKm.value;
              if (distance != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distància màxima:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: [
                        Chip(
                          label: Text('${distance.toStringAsFixed(0)} km'),
                          backgroundColor: Colors.blue[100],
                          onDeleted: () {
                            catalegController.setMaxDistanceKm(null);
                            catalegController.setUserLocation(null, null);
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
              final date1 = catalegController.selectedDate1.value;
              final date2 = catalegController.selectedDate2.value;

              if (date1 != null && date2 != null) {
                final formattedDate = "${date1.day.toString().padLeft(2, '0')}/${date1.month.toString().padLeft(2, '0')}/${date1.year}";
                final formattedStartTime = "${date1.hour.toString().padLeft(2, '0')}:${date1.minute.toString().padLeft(2, '0')}";
                final formattedEndTime = "${date2.hour.toString().padLeft(2, '0')}:${date2.minute.toString().padLeft(2, '0')}";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponibilitat:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('$formattedDate  |  $formattedStartTime → $formattedEndTime'),
                      backgroundColor: Colors.blue[100],
                      onDeleted: () {
                        catalegController.setDateRange(null, null);
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(() {
              if (catalegController.accessible.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accessibilitat:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: [
                        Chip(
                          label: const Text('Accessibilitat'),
                          backgroundColor: Colors.blue[100],
                          onDeleted: () {
                            catalegController.setAccessible(false);
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
      bottomNavigationBar: const MomentumBottomNavBar(),
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: DraggableScrollableSheet(
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
                          items: daysOfWeek.map((day) {
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

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              selectedTime?.format(context) ?? 'Selecciona hora',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.blue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
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
                      SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.blue,
                        inactiveTrackColor: Colors.blue.shade100,
                        thumbColor: Colors.white,
                        overlayColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
                        valueIndicatorColor: Colors.blue,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      ),
                      child: Slider(
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
                      )),
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

  void _showDistanceSelector() async {
    double selectedDistance = catalegController.maxDistanceKm.value ?? 10.0;

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Selecciona distància màxima',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SleekCircularSlider(
                        min: 1,
                        max: 50,
                        initialValue: selectedDistance,
                        appearance: CircularSliderAppearance(
                          size: 200,
                          customColors: CustomSliderColors(
                            progressBarColor: Colors.blue,
                            trackColor: Colors.blue.shade100,
                            dotColor: Colors.white,
                          ),
                          customWidths: CustomSliderWidths(
                            progressBarWidth: 12,
                            trackWidth: 8,
                            handlerSize: 8,
                          ),
                          infoProperties: InfoProperties(
                            modifier: (value) => '${value.toStringAsFixed(0)} km',
                            mainLabelStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onChange: (value) {
                          setModalState(() {
                            selectedDistance = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    // Obtenim la ubicació i apliquem filtres DESPRÉS de tancar el BottomSheet
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Ubicació desactivada", "Activa els serveis de localització.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permís denegat", "No es pot accedir a la ubicació sense permís.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permís permanentment denegat",
          "Vés a la configuració del dispositiu per permetre l'accés a la ubicació.",
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      catalegController.setUserLocation(position.latitude, position.longitude);
      catalegController.setMaxDistanceKm(selectedDistance);

      //print('LAT: ${catalegController.userLat.value}');
      //print('LON: ${catalegController.userLng.value}');

      _applyFilters();
      setState(() {}); // Si vols veure el Chip actualitzat

    } catch (e) {
      Get.snackbar("Error", "No s'ha pogut obtenir la ubicació actual.");
    }
  }

  void _showAvailabilitySelector() async {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: DraggableScrollableSheet(
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
                        'Filtra per disponibilitat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // DATA ÚNICA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.date_range, color: Colors.white),
                          label: Text(
                            selectedDate == null
                                ? 'Selecciona data'
                                : 'Data: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // HORA INICI
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.access_time, color: Colors.white),
                          label: Text(
                            startTime == null
                                ? 'Selecciona hora inicial'
                                : 'Hora inici: ${startTime!.format(context)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                startTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // HORA FINAL
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.access_time, color: Colors.white),
                          label: Text(
                            endTime == null
                                ? 'Selecciona hora final'
                                : 'Hora final: ${endTime!.format(context)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                endTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );

  // Aplica els filtres un cop tancat el modal
  if (selectedDate != null && startTime != null && endTime != null) {
    final d1 = DateTime.utc(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    final d2 = DateTime.utc(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    catalegController.setDateRange(d1, d2);
    _applyFilters();
  }
}


  void _applyFilters() {
    // Com que no te sentit ficar els dos filtres a la vegada, si s'ha seleccionat el de disponibilitat es cancela el d'horaris
    if (catalegController.selectedDate1.value != null 
    && catalegController.selectedDate2.value != null
    && catalegController.selectedOpenTime.value != null
    && catalegController.selectedOpenDay.value != null) {
      catalegController.selectedOpenDay.value = null;
      catalegController.selectedOpenTime.value = null;

    }
    final filters = {
      // Llistes
      if (catalegController.accessible.value)
        "accessible": true,
      if (catalegController.selectedServices.isNotEmpty)
        "serviceTypes":
            catalegController.selectedServices
                .map((s) => s.description)
                .toList(),
      if (catalegController.selectedCities.isNotEmpty)
        "cities": catalegController.selectedCities.toList(),
      if (catalegController.selectedOpenDay.value != null)
        "day": catalegController.selectedOpenDay.value,
      if (catalegController.selectedOpenTime.value != null)
        "time": catalegController.selectedOpenTime.value,
      if (catalegController.ratingMin.value != null)
        "ratingMin": catalegController.ratingMin.value,
      if (catalegController.userLat.value != null &&
          catalegController.userLng.value != null &&
          catalegController.maxDistanceKm.value != null) ...{
        "lat": catalegController.userLat.value,
        "lon": catalegController.userLng.value, 
        "maxDistance": catalegController.maxDistanceKm.value
      },
      if (catalegController.selectedDate1.value != null &&
          catalegController.selectedDate2.value != null) ...{
        "date1": catalegController.selectedDate1.value!.toIso8601String(),
        "date2": catalegController.selectedDate2.value!.toIso8601String(),
      }
    };

    //print('Filtres aplicats: $filters');
    if(ButtonAllOrFavorite == 0){
      catalegController.getFilteredBusiness(filters,authController.currentUser.value.id!);
    }else{
      if(authController.currentUser.value.id != null){
        catalegController.getFilteredFavoriteBusinesses(authController.currentUser.value.id!, filters);
      }else{
        Get.snackbar("Error", "S'ha produït un error");
      }
    }
    
  }
  void _onSearch(String query) {
    catalegController.clearFilter();
    catalegController.searchBusinessLocationByName(query);
    searchController.clear();
  }

}
