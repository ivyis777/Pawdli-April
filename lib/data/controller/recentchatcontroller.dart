import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/recentpetchatmodel.dart';
class RecentPetChatController extends GetxController {
  var recentChats = <RecentPetChat>[].obs;
  var selectedPetId = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> setSelectedPet(String petId) async {
    selectedPetId.value = petId;
    await fetchRecentChatsForPet(petId);
  }

  String fixImageUrl(String url) {
    if (url.isEmpty) return "";

    if (url.startsWith("http")) {
      return url;
    }

    return "https://app.pawdli.com$url";
  }

  Future<void> fetchRecentChatsForPet(String petId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final chats = await ApiService.fetchRecentPetChat(petId: petId);
      if (chats != null && chats.isNotEmpty) {
        final fixedChats = chats.map((chat) {
        chat.withPet?.petProfileImage =
            fixImageUrl(chat.withPet?.petProfileImage ?? "");
        return chat;
      }).toList();

      recentChats.value = fixedChats;
      } else {
        recentChats.clear();
        errorMessage.value = "No chats found.";
      }
    } catch (e) {
      recentChats.clear();
      errorMessage.value = "Failed to load chats: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChats() async {
    if (selectedPetId.isNotEmpty) {
      await fetchRecentChatsForPet(selectedPetId.value);
    }
  }
}
