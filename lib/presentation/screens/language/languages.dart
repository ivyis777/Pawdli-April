import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:get_storage/get_storage.dart';

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
    "Spanish",
    "French",
    "German",
    "Portuguese",
    "Italian",
    "Dutch",
    "Russian",
    "Chinese (Simplified)",
    "Chinese (Traditional)",
    "Japanese",
    "Korean",
    "Arabic",
    "Turkish",
    "Persian",
    "Hebrew",
    "Greek",
    "Swedish",
    "Norwegian",
    "Danish",
    "Finnish",
    "Polish",
    "Czech",
    "Hungarian",
    "Romanian",
    "Bulgarian",
    "Ukrainian",
    "Slovak",
    "Croatian",
    "Serbian",
    "Slovenian",
    "Lithuanian",
    "Latvian",
    "Estonian",
    "Icelandic",
    "Irish",
    "Welsh",

    // 🇮🇳 Indian Languages
    "Hindi",
    "Kannada",
    "Tamil",
    "Telugu",
    "Malayalam",
    "Marathi",
    "Gujarati",
    "Bengali",
    "Punjabi",
    "Urdu",
    "Odia",
    "Assamese",
    "Sanskrit",
    "Konkani",
    "Manipuri",
    "Bodo",
    "Dogri",
    "Maithili",
    "Santali",
    "Kashmiri",
    "Sindhi",

    // 🌏 Asian Languages
    "Thai",
    "Vietnamese",
    "Indonesian",
    "Malay",
    "Filipino (Tagalog)",
    "Sinhala",
    "Khmer",
    "Lao",
    "Mongolian",
    "Nepali",
    "Burmese",

    // 🌍 African Languages
    "Swahili",
    "Zulu",
    "Xhosa",
    "Afrikaans",
    "Amharic",
    "Yoruba",
    "Igbo",
    "Hausa",

    // 🌎 Others
    "Latin",
    "Esperanto"
  ];

  // ✅ ADD THIS FUNCTION HERE
  String getLanguageCode(String language) {
    Map<String, String> langMap = {
      // 🌐 International
      "English": "en",
      "Spanish": "es",
      "French": "fr",
      "German": "de",
      "Portuguese": "pt",
      "Italian": "it",
      "Dutch": "nl",
      "Russian": "ru",
      "Chinese (Simplified)": "zh",
      "Chinese (Traditional)": "zh-TW",
      "Japanese": "ja",
      "Korean": "ko",
      "Arabic": "ar",
      "Turkish": "tr",
      "Persian": "fa",
      "Hebrew": "he",
      "Greek": "el",
      "Swedish": "sv",
      "Norwegian": "no",
      "Danish": "da",
      "Finnish": "fi",
      "Polish": "pl",
      "Czech": "cs",
      "Hungarian": "hu",
      "Romanian": "ro",
      "Bulgarian": "bg",
      "Ukrainian": "uk",
      "Slovak": "sk",
      "Croatian": "hr",
      "Serbian": "sr",
      "Slovenian": "sl",
      "Lithuanian": "lt",
      "Latvian": "lv",
      "Estonian": "et",
      "Icelandic": "is",
      "Irish": "ga",
      "Welsh": "cy",

      // 🇮🇳 Indian
      "Hindi": "hi",
      "Kannada": "kn",
      "Tamil": "ta",
      "Telugu": "te",
      "Malayalam": "ml",
      "Marathi": "mr",
      "Gujarati": "gu",
      "Bengali": "bn",
      "Punjabi": "pa",
      "Urdu": "ur",
      "Odia": "or",
      "Assamese": "as",
      "Sanskrit": "sa",
      "Konkani": "gom",
      "Manipuri": "mni",
      "Bodo": "brx",
      "Dogri": "doi",
      "Maithili": "mai",
      "Santali": "sat",
      "Kashmiri": "ks",
      "Sindhi": "sd",

      // 🌏 Asia
      "Thai": "th",
      "Vietnamese": "vi",
      "Indonesian": "id",
      "Malay": "ms",
      "Filipino (Tagalog)": "tl",
      "Sinhala": "si",
      "Khmer": "km",
      "Lao": "lo",
      "Mongolian": "mn",
      "Nepali": "ne",
      "Burmese": "my",

      // 🌍 Africa
      "Swahili": "sw",
      "Zulu": "zu",
      "Xhosa": "xh",
      "Afrikaans": "af",
      "Amharic": "am",
      "Yoruba": "yo",
      "Igbo": "ig",
      "Hausa": "ha",

      // Others
      "Latin": "la",
      "Esperanto": "eo",
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
        title: Text('Language'.tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterLanguages,
              decoration: InputDecoration(
                hintText: 'search_language...'.tr,
                prefixIcon: Icon(Icons.search),
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
                  title: Text(language),
                  trailing: Radio(
                    value: language,
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
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
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('continue'.tr),
            ),
          ),
        ],
      ),
    );
  }
}