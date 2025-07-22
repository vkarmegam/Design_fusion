import 'dart:io';
import 'dart:typed_data'; // For web, we use Uint8List instead of File.
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


  void main() async {
     runApp(InteriorDesignApp());
}

class InteriorDesignApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interior Design',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InteriorDesignScreen(),
    );
  }
}

class InteriorDesignScreen extends StatefulWidget {
  @override
  _InteriorDesignScreenState createState() => _InteriorDesignScreenState();
}

class _InteriorDesignScreenState extends State<InteriorDesignScreen> {


  Uint8List? _imageData; // Use Uint8List for web-compatible image data.
  final _picker = ImagePicker();
  String? _roomSize;
  String? _roomType;
  String? _expectedStyle;
  bool _isLoading = false; // Add this variable to manage loading state

  TextEditingController _requirementsController = TextEditingController();

  final List<String> roomSizes = ['Tiny: 7 ft x 10 ft (70 square feet)', 'Small: 10 ft x 13 ft (130 square feet)', 'Medium: 12 ft x 18 ft (216 square feet)', 'Large: 15 ft x 20+ ft (300 square feet)'];
  final List<String> roomTypes = ['Living Room', 'Bedroom', 'Kitchen', 'Bathroom','Foyer/Entryway','Dining Room','Master Bedroom','Laundry Room','Guest Room','Home Office','Home Gym','Garage','Basement'];
  final List<String> styles = ['Bohemian', 'Mid-century modern', 'Scandinavian', 'Art Deco', 'Farmhouse', 'Industrial', 'Eclecticism in architecture', 'Minimalism', 'Contemporary', 'Coastal', 'Regency', 'Rustic', 'Shabby Chic', 'Traditional', 'Mediterranean', 'Modern', 'Colonial architecture', 'French country', 'Maximalism', 'Transitional', 'Country', 'Industrial style', 'Japandi', 'Asian'];
  

  
  Future<void> _pickImage() async {

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageData = await pickedFile.readAsBytes(); // Read image data as bytes
        setState(() {
          _imageData = imageData;
        });
      } else {
        _showError('No image selected.');
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _submitData() async {
    if (_imageData == null || _roomSize == null || _roomType == null || _expectedStyle == null) {
      _showError('Please fill all the fields.');
      return;
    }

    try {

         final imagesParts = <DataPart>[];

      imagesParts.add(DataPart('image/jpeg', _imageData!));
  final mainText = TextPart("give me a interior design tips for my $_roomType with the size of $_roomSize. the style which i am expecting is $_expectedStyle my specific requirements $_requirementsController. give me the proper inrterior stype and color options for this to look better. " );
    final input = [
      Content.multi([... imagesParts,mainText ])
    ];
    
    var apiKey = const String.fromEnvironment('API_KEY', defaultValue: 'key not found');
  
    if (apiKey == 'key not found') {
      apiKey ='AIzaSyCPT7k6YRtD-C83TgSKzqjsG9ofvYwNEAo';
    }
      // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
        final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

        setState(() {
          _isLoading = true; // Set loading state to true
        });
        final response = await model.generateContent(input,safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],);

    setState(() {
      _isLoading = false; // Set loading state to true
    });
       if (response.text != "") {
        _showSuccess(' ${response.text}' );
      } else {
        _showError('Failed with status: ${response.text}');
      }
    } catch (e) {
      _showError('Failed to submit data: $e');
    }
  }



  void _showError(String message) {

    setState(() {
      _isLoading = true; // Set loading state to true
    });
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interior Design'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Room Image:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: _imageData == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey[600]),
                      )
                    : Image.memory(
                        _imageData!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Room Size'),
                value: _roomSize,
                items: roomSizes.map((size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _roomSize = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Room Type'),
                value: _roomType,
                items: roomTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _roomType = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Expected Style'),
                value: _expectedStyle,
                items: styles.map((style) {
                  return DropdownMenuItem(value: style, child: Text(style));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _expectedStyle = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _requirementsController,
                decoration: InputDecoration(labelText: 'Specific Requirements'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),

                if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
