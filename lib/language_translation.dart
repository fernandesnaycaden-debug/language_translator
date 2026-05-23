import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class LanguageTranslationPage extends StatefulWidget {
  const LanguageTranslationPage({super.key});

  @override
  State<LanguageTranslationPage> createState() => _LanguageTranslationPageState();
}

class _LanguageTranslationPageState extends State<LanguageTranslationPage> {

  var languages = ['Hindi', 'English', 'French' , 'Japanese' , 'Spanish'];
  String? originLanguage = 'From';
  String? destinationLanguage = 'To';
  var output = '';
  TextEditingController languageController = TextEditingController();

  void translate(String arc,String dest, String input) async {
    GoogleTranslator translator = new GoogleTranslator();
    var translation = await translator.translate(input, from: arc , to:dest);
    setState(() {
      output = translation.text.toString();
    });

    if (arc =='--' || dest == '--'){
      setState(() {
        output = 'Failed to translate';
      });
    }
  }

  String getLanguageCode(String language){
    if(language=='English'){
      return 'en';
    }
    else if(language=='Hindi') {
      return 'hi';
    }
    else if (language=='French'){
      return 'fr';
    }
    else if (language=='Japanese'){
      return 'ja';
    }
    else if (language=='Spanish'){
      return 'es';
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: Text('Language Translator'),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(focusColor: Colors.purple,
                  iconDisabledColor: Colors.white,
                  iconEnabledColor: Colors.white,
                  hint: const Text( 
                  'From',style: TextStyle(color: Colors.white),                
                  ),
                  value: originLanguage,

                  dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: languages.map((String dropDownStringItem){
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (String? value){
                      setState(() {
                        originLanguage = value;

                      });
                    },
                    ),

                    SizedBox(width: 30,),
                    Icon(Icons.arrow_right_alt_outlined,color: Colors.white,),
                    SizedBox(width: 40,),


                    DropdownButton<String>(
                    focusColor: Colors.purple,
                    iconDisabledColor: Colors.white,
                    iconEnabledColor: Colors.white,
                    hint: const Text(
                    'To',style: TextStyle(color: Colors.white),                
                    ),
                    value:destinationLanguage,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: languages.map((String dropDownStringItem){
                      return DropdownMenuItem<String>(child: Text(dropDownStringItem),value: dropDownStringItem,
                      );
                    }).toList(),
                    onChanged: (String? value){
                      setState(() {
                        destinationLanguage = value;

                      });
                    },
                    ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(padding: const EdgeInsets.all(9),
              child: TextFormField(
                cursorColor: Colors.white,
                autofocus: false,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Please Enter Your Text',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1
                    )
                  ),
                  errorStyle: const TextStyle(color: Colors.red,fontSize: 16), 
                ),
                controller: languageController,
                validator: (value){
                  if(value==null || value.isEmpty){
                    return 'Please enter text to translate';
                  }
                  return null;
                }
              ),
              ),

              Padding(padding: const EdgeInsets.all(9),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                onPressed: (){
                  translate(getLanguageCode(originLanguage ?? ''), getLanguageCode(destinationLanguage ?? ''), languageController.text.toString());
                }, 
                child: const Text('Translate')
                )),
              SizedBox(height: 20,),
              Text(
                '\n$output',
                style: TextStyle(
                  color: Colors.lightGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}