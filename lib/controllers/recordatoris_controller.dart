import 'package:get/get.dart';
import 'package:momentum/controllers/auth_controller.dart';
import 'package:momentum/models/recordatoris_model.dart';
import 'package:momentum/services/recordatoris_service.dart';

class RecordatorisController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RecordatorisService recordatoriService = RecordatorisService();
  final RxList<Recordatori> recordatoris = <Recordatori>[].obs;
  final Rx<Recordatori> recordatori =
      Recordatori(
        id: '',
        title: '',
        description: '',
        userId: '',
        time: DateTime.now(),
        repeat: RepetitionType.never,
      ).obs;

  Future<void> fetchRecordatoris() async {
    try {
      final fetchedRecordatoris = await RecordatorisService.getAllRecordatoris(
        authController.currentUser.value.id as String,
      );
      recordatoris.assignAll(fetchedRecordatoris);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch recordatoris: $e');
    }
  }

  Future<void> addRecordatori() async {
    try {
      final newRecordatori = await RecordatorisService.createRecordatori(
        recordatori.value,
      );
      recordatoris.add(newRecordatori);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save recordatori: $e');
    }
  }

  Future<void> deleteRecordatori(String id) async {
    try {
      await RecordatorisService.deleteRecordatori(id);
      recordatoris.removeWhere((rec) => rec.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete recordatori: $e');
    }
  }

  Future<void> updateRecordatori() async {
    try {
      await RecordatorisService.updateRecordatori(recordatori.value);
      final index = recordatoris.indexWhere(
        (rec) => rec.id == recordatori.value.id,
      );
      if (index != -1) {
        recordatoris[index] = recordatori.value;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update recordatori: $e');
    }
  }
}
