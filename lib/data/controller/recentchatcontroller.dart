import 'package:get/get.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/model/recentpetchatmodel.dart';
class RecentPetChatController extends GetxController {
  var recentChats = <RecentPetChat>[].obs;
  var selectedPetId = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void setSelectedPet(String petId) {
    selectedPetId.value = petId;
    fetchRecentChatsForPet(petId);
  }

  String fixImageUrl(String url) {
  if (url.isEmpty) return url;

  String decoded = Uri.decodeFull(url);

  if (decoded.startsWith('/http')) {
    decoded = decoded.substring(1);
  }

  decoded = decoded.replaceFirst('https:/', 'https://');

  return decoded;
}

  Future<void> fetchRecentChatsForPet(String petId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final chats = await ApiService.fetchRecentPetChat(petId: petId);
      if (chats != null && chats.isNotEmpty) {
        final fixedChats = chats.map((chat) {
        if (chat.withPet?.petProfileImage != null &&
            chat.withPet!.petProfileImage!.isNotEmpty) {
          chat.withPet!.petProfileImage =
              fixImageUrl(chat.withPet!.petProfileImage!);
        }
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
