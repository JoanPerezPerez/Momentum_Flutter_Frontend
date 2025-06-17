import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momentum/controllers/xat_controller.dart';
import 'package:momentum/models/worker_model.dart' as myWorker;

class StartChatCard extends StatefulWidget {
  final String locationName;
  final String locationId;
  final String businessId;

  const StartChatCard({
    super.key,
    required this.locationName,
    required this.locationId,
    required this.businessId,
  });

  @override
  State<StartChatCard> createState() => _StartChatCardState();
}

class _StartChatCardState extends State<StartChatCard> {
  final XatController xatController = Get.find<XatController>();
  myWorker.Worker? selectedWorker;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      print('Start xat with business');
                      await xatController.startXatUserAndBusiness(
                        widget.businessId,
                      );
                    },
                    child: const Text(
                      'Xat with business',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await xatController.startXatByUser(
                        widget.locationId,
                        "location",
                        widget.locationName,
                      );
                    },
                    child: const Text(
                      'Xat with location',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() {
              final workers = xatController.workers;
              return Row(
                children: [
                  Expanded(
                    child: DropdownButton<myWorker.Worker>(
                      isExpanded: true,
                      value: selectedWorker,
                      hint: const Text(
                        'Select worker',
                        style: TextStyle(fontSize: 12),
                      ),
                      items:
                          workers.map((worker) {
                            return DropdownMenuItem<myWorker.Worker>(
                              value: worker,
                              child: Text(
                                worker.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                      onChanged: (worker) {
                        setState(() {
                          selectedWorker = worker;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed:
                        selectedWorker != null
                            ? () async {
                              await xatController.startXatByUser(
                                selectedWorker!.id as String,
                                "worker",
                                selectedWorker!.name,
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 36),
                    ),
                    child: const Text('Xat', style: TextStyle(fontSize: 12)),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
