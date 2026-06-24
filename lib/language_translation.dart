import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

class LanguageTranslationPage extends StatefulWidget {
  const LanguageTranslationPage({super.key});

  @override
  State<LanguageTranslationPage> createState() => _LanguageTranslationPageState();
}

class _LanguageTranslationPageState extends State<LanguageTranslationPage> {

  static const Map<String, String> _languageMap = {
    'English': 'en',
    'Hindi': 'hi',
    'French': 'fr',
    'Japanese': 'ja',
    'Spanish': 'es',
  };

  final List<String> languages = _languageMap.keys.toList();
  String? originLanguage;
  String? destinationLanguage;
  var output = '';
  TextEditingController languageController = TextEditingController();

  void translate(String srcCode, String destCode, String input) async {
    if (srcCode == '--' || destCode == '--' || input.trim().isEmpty) {
      setState(() {
        output = 'Please select both languages and enter some text.';
      });
      return;
    }

    try {
      final translator = GoogleTranslator();
      var translation = await translator.translate(input, from: srcCode, to: destCode);
      setState(() {
        output = translation.text.toString();
      });
    } catch (e) {
      setState(() {
        output = 'Failed to translate: ${e.toString()}';
      });
    }
  }

  String getLanguageCode(String? language) {
    if (language == null) return '--';
    return _languageMap[language] ?? '--';
  }

  Future<void> _scanTextFromImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing image and scanning text...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      setState(() {
        languageController.text = recognizedText.text;
        output = ''; // Clear prior output
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read text: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      await textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'LinguaTranslate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.translate_rounded, color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1D1B26), // Dark deep slate/purple
              Color(0xFF0F0E14), // Pure deep dark background
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Language Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // From Language Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: originLanguage,
                            hint: const Text(
                              'From',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            dropdownColor: const Color(0xFF1D1B26),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: languages.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                originLanguage = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Swap Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              final temp = originLanguage;
                              originLanguage = destinationLanguage;
                              destinationLanguage = temp;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    // To Language Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: destinationLanguage,
                            hint: const Text(
                              'To',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            dropdownColor: const Color(0xFF1D1B26),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            items: languages.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                destinationLanguage = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Input Text Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: languageController,
                        maxLines: 5,
                        minLines: 3,
                        cursorColor: const Color(0xFF6C63FF),
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                        decoration: InputDecoration(
                          hintText: 'Type your text here...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          suffixIcon: languageController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                                  onPressed: () {
                                    languageController.clear();
                                    setState(() {
                                      output = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Scan Image:',
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Scan using Camera',
                            onPressed: () => _scanTextFromImage(ImageSource.camera),
                          ),
                          IconButton(
                            icon: const Icon(Icons.image_search_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Scan from Gallery',
                            onPressed: () => _scanTextFromImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Translate Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6C63FF), // Indigo
                        Color(0xFF8B5CF6), // Purple
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      translate(
                        getLanguageCode(originLanguage),
                        getLanguageCode(destinationLanguage),
                        languageController.text,
                      );
                    },
                    child: const Text(
                      'Translate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                
                // Output Card (shown conditionally)
                if (output.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Translation',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: output));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Copied to clipboard'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF6C63FF),
                                      duration: const Duration(seconds: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          output,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}