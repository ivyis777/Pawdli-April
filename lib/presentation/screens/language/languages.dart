import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:get_storage/get_storage.dart';

double getResponsiveFont(BuildContext context, double size) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 360) {
    return size * 0.85;
  } else if (screenWidth < 400) {
    return size;
  } else if (screenWidth < 600) {
    return size * 1.1;
  } else {
    return size * 1.3;
  }
}

class LanguageSelectionPage extends StatefulWidget {
  @override
  _LanguageSelectionPageState createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final GetStorage box = GetStorage();
  String selectedLanguage = "English";

  List<String> languages = [
    // 🌐 International
    "English",

    "German",

    // 🇮🇳 Indian Languages
    "Hindi",
    "Kannada",
    "Tamil",
    "Telugu",
    "Malayalam",
    
  ];

  // ✅ ADD THIS FUNCTION HERE
  String getLanguageCode(String language) {
    Map<String, String> langMap = {
      // 🌐 International
      "English": "en",
 
      "German": "de",

      // 🇮🇳 Indian
      "Hindi": "hi",
      "Kannada": "kn",
      "Tamil": "ta",
      "Telugu": "te",
      "Malayalam": "ml",
      
    };

    return langMap[language] ?? "en";
  }

  List<String> filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    filteredLanguages = languages;
  }

  void filterLanguages(String query) {
    setState(() {
      filteredLanguages = languages
          .where((lang) =>
              lang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language'.tr,
          style: TextStyle(
            fontSize: getResponsiveFont(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: TextStyle(
                fontSize: getResponsiveFont(context, 14),
              ),
              onChanged: filterLanguages,
              decoration: InputDecoration(
                hintText: 'search_language...'.tr,
                  hintStyle: TextStyle(
                    fontSize: getResponsiveFont(context, 14),
                  ),
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📜 Language List
          Expanded(
            child: ListView.builder(
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                String language = filteredLanguages[index];
                return ListTile(
                  title: Text(
                    language,
                    style: TextStyle(
                      fontSize: getResponsiveFont(context, 15),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 1.0,
                    child: Radio(
                      value: language,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedLanguage = language;
                    });
                  },
                );
              },
            ),
          ),

          // ✅ Continue Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                String langCode = getLanguageCode(selectedLanguage);

                // ✅ SAVE LANGUAGE
                box.write('lang', langCode);

                // ✅ APPLY LANGUAGE
                Get.updateLocale(Locale(langCode));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                'continue'.tr,
                style: TextStyle(
                  fontSize: getResponsiveFont(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}