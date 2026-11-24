
import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/GroomingPriceModel.dart';

class GroomingPlanPriceController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final priceResult = Rxn<GroomingPlanPriceModel>();

  int _requestId = 0;

  Future<void> fetchPrice({
    required int serviceId,
    required int petId,
    required int sessionsPerMonth,
    required int numberOfMonths,
  }) async {
    final requestId = ++_requestId;

    isLoading.value = true;
    errorMessage.value = '';
    priceResult.value = null;

    try {
      final result = await ApiService.fetchGroomingPlanPrice(
        serviceId: serviceId,
        petId: petId,
        sessionsPerMonth: sessionsPerMonth,
        numberOfMonths: numberOfMonths,
      );

      if (requestId != _requestId) return;

      priceResult.value = result;
    } catch (e) {
      if (requestId != _requestId) return;

      errorMessage.value =
          e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (requestId == _requestId) {
        isLoading.value = false;
      }
    }
  }

  void clearPrice() {
    ++_requestId;
    priceResult.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}
