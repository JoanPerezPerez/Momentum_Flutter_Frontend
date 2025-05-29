import 'package:flutter/material.dart';
import 'package:momentum/controllers/optimization_controller.dart';
import 'package:get/get.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';

class OptimizationScreen extends StatefulWidget {
  @override
  _OptimizationScreenState createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> {
  final TextEditingController inputController = TextEditingController();
  final OptimizationController optimizationController = Get.find();
  int _selectedIndex = 5;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Optimització de calendari amb IA"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Benvengut a l'optimització de calendari amb IA!"
                          "\nEn aquesta pagina pots escriure el que vols fer durant un dia o durant un període de temps, i mitjançant IA, momentum buscarà les activitats de les que disposem per optimitzar el teu calendari amb el que has demanat. Només has de descriure que vols fer i quan vols fer-ho!",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: inputController,
                          maxLines: null,
                          minLines: 5,
                          decoration: InputDecoration(
                            hintText: "Escriu aquí...",
                            filled: true,
                            fillColor: Colors.blue.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Envia",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Obx(() {
                          if (optimizationController
                              .answerFromIA
                              .value
                              .isEmpty) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                "Resposta de la IA:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  optimizationController.answerFromIA.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _handleSubmit() {
    final userInput = inputController.text.trim();
    if (userInput.isNotEmpty) {
      optimizationController.textToSend = userInput;
      optimizationController.sendTestMesage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text enviat! Esperant resopsta...')),
      );
    }
  }
}
