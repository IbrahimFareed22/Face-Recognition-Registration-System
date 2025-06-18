// // register_screen.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   File? _image;

//   // دالة لاختيار الصورة باستخدام الكاميرا
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.camera);

//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//       });
//     }
//   }

//   // دالة التسجيل
//   Future<void> _register() async {
//     if (_image == null || _nameController.text.isEmpty || _usernameController.text.isEmpty) {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('يرجى ملء كل البيانات والتقاط صورة')),
//         );
//       }
//       return;
//     }

//     final bytes = await _image!.readAsBytes();
//     final faceEncoding = base64Encode(bytes);

//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/register'), // غيّر لو عندك IP مختلف
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': _nameController.text,
//         'username': _usernameController.text,
//         'face_encoding': faceEncoding,
//       }),
//     );

//     final data = jsonDecode(response.body);
//     if (response.statusCode == 201) {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم التسجيل بنجاح')),
//         );
//       }
//     } else {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('فشل التسجيل: ${data["message"]}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل عضو جديد')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم')),
//             TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
//             const SizedBox(height: 16),
//             _image != null
//                 ? Image.file(_image!, height: 200)
//                 : const Text('لم يتم التقاط صورة'),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.camera_alt),
//               label: const Text('التقاط صورة'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _register,
//               child: const Text('تسجيل'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//111111111111111111111111111111111111111111
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:html' as html;
// import 'package:flutter/foundation.dart';  // تأكد من استيراد هذه المكتبة

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   Uint8List? _imageBytes;

//   // دالة لاختيار الصورة باستخدام الكاميرا أو فتح نافذة اختيار الصور
//   Future<void> _pickImage() async {
//     if (kIsWeb) {
//       // في حالة العمل على Flutter Web
//       final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//       uploadInput.accept = 'image/*';
//       uploadInput.click();

//       uploadInput.onChange.listen((e) async {
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(uploadInput.files!.first);
        
//         reader.onLoadEnd.listen((e) {
//           setState(() {
//             _imageBytes = reader.result as Uint8List?;
//           });
//         });
//       });
//     } else {
//       // في حالة العمل على الموبايل (أندرويد أو iOS)
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(source: ImageSource.camera);

//       if (picked != null) {
//         // تأكد من أن الكود داخل دالة async
//         final bytes = await picked.readAsBytes(); // تأكد من أن await موجود في دالة async
//         setState(() {
//           _imageBytes = Uint8List.fromList(bytes);
//         });
//       }
//     }
//   }

//   // دالة التسجيل
//   Future<void> _register() async {
//     if (_imageBytes == null || _nameController.text.isEmpty || _usernameController.text.isEmpty) {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('يرجى ملء كل البيانات والتقاط صورة')),
//         );
//       }
//       return;
//     }

//     final faceEncoding = base64Encode(_imageBytes!);

//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/register'), // غيّر لو عندك IP مختلف
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': _nameController.text,
//         'username': _usernameController.text,
//         'face_encoding': faceEncoding,
//       }),
//     );

//     final data = jsonDecode(response.body);
//     if (response.statusCode == 201) {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('تم التسجيل بنجاح')),
//         );
//       }
//     } else {
//       if (mounted) {  // تأكد من أن الـ Widget ما زال موجودًا في الشجرة
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('فشل التسجيل: ${data["message"]}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل عضو جديد')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم')),
//             TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
//             const SizedBox(height: 16),
//             _imageBytes != null
//                 ? Image.memory(_imageBytes!, height: 200)
//                 : const Text('لم يتم التقاط صورة'),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.camera_alt),
//               label: const Text('التقاط صورة'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _register,
//               child: const Text('تسجيل'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//22222222222222222222222222222222222222
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   html.VideoElement? _videoElement;
//   html.CanvasElement? _canvasElement;
//   bool _isCameraInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _videoElement = html.VideoElement()
//       ..autoplay = true
//       ..width = 640
//       ..height = 480;
//     _canvasElement = html.CanvasElement(width: 640, height: 480);

//     try {
//       final stream = await html.window.navigator.mediaDevices?.getUserMedia({
//         'video': true,
//       });

//       if (stream != null) {
//         _videoElement!.srcObject = stream;
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       } else {
//         print("كاميرا غير متاحة");
//       }
//     } catch (e) {
//       print("Error accessing the camera: $e");
//     }
//   }

//   Future<void> _takePicture() async {
//     if (_videoElement == null || !_isCameraInitialized) return;

//     final context = _canvasElement!.context2D;
//     context.drawImage(_videoElement!, 0, 0);
//     final imageData = _canvasElement!.toDataUrl('image/png');

//     // تحويل الصورة إلى Base64
//     final faceImageBase64 = imageData.split(',')[1];

//     // إرسال الصورة إلى السيرفر
//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/attendance'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'face_image': faceImageBase64,
//       }),
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('تم تسجيل الحضور بنجاح: ${data["message"]}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('فشل تسجيل الحضور: ${data["message"]}')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _videoElement?.pause();
//     _videoElement?.srcObject = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل الحضور')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text('التقط صورة للوجه لتسجيل الحضور'),
//             const SizedBox(height: 16),
//             _isCameraInitialized
//                 ? HtmlElementView(viewType: 'videoElement')
//                 : const Text('الكاميرا غير متاحة'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _takePicture,
//               child: const Text('التقاط صورة'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


//3333333333333333333333
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   html.VideoElement? _videoElement;
//   html.CanvasElement? _canvasElement;
//   bool _isCameraInitialized = false;
//   bool _isCameraVisible = false;
//   String _name = '';
//   String _username = '';

//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _usernameController.dispose();
//     _videoElement?.pause();
//     _videoElement?.srcObject = null;
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     _videoElement = html.VideoElement()
//       ..autoplay = true
//       ..width = 640
//       ..height = 480;
//     _canvasElement = html.CanvasElement(width: 640, height: 480);

//     try {
//       final stream = await html.window.navigator.mediaDevices?.getUserMedia({
//         'video': true,
//       });

//       if (stream != null) {
//         _videoElement!.srcObject = stream;
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       } else {
//         print("كاميرا غير متاحة");
//       }
//     } catch (e) {
//       print("Error accessing the camera: $e");
//     }
//   }

//   Future<void> _takePicture() async {
//     if (_videoElement == null || !_isCameraInitialized) return;

//     final context = _canvasElement!.context2D;
//     context.drawImage(_videoElement!, 0, 0);
//     final imageData = _canvasElement!.toDataUrl('image/png');

//     // تحويل الصورة إلى Base64
//     final faceImageBase64 = imageData.split(',')[1];

//     // إرسال الصورة إلى السيرفر
//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/attendance'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'face_image': faceImageBase64,
//       }),
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('تم تسجيل الحضور بنجاح: ${data["message"]}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('فشل تسجيل الحضور: ${data["message"]}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل الحضور')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             if (!_isCameraVisible) ...[
//               const Text('يرجى إدخال بياناتك'),
//               TextField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'الاسم'),
//                 onChanged: (value) {
//                   setState(() {
//                     _name = value;
//                   });
//                 },
//               ),
//               TextField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(labelText: 'اسم المستخدم'),
//                 onChanged: (value) {
//                   setState(() {
//                     _username = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_name.isNotEmpty && _username.isNotEmpty) {
//                     setState(() {
//                       _isCameraVisible = true;
//                     });
//                     _initializeCamera();
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('الرجاء إدخال جميع البيانات')),
//                     );
//                   }
//                 },
//                 child: const Text('التسجيل'),
//               ),
//             ] else ...[
//               const Text('التقط صورة للوجه لتسجيل الحضور'),
//               const SizedBox(height: 16),
//               _isCameraInitialized
//                   ? HtmlElementView(viewType: 'videoElement')
//                   : const Text('الكاميرا غير متاحة'),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _takePicture,
//                 child: const Text('التقاط صورة'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

//44444444444444444444444444444
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   html.VideoElement? _videoElement;
//   html.CanvasElement? _canvasElement;
//   bool _isCameraInitialized = false;
//   bool _isCameraVisible = false;
//   String _name = '';
//   String _username = '';

//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _usernameController.dispose();
//     _videoElement?.pause();
//     _videoElement?.srcObject = null;
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     _videoElement = html.VideoElement()
//       ..autoplay = true
//       ..width = 640
//       ..height = 480;
//     _canvasElement = html.CanvasElement(width: 640, height: 480);

//     try {
//       final stream = await html.window.navigator.mediaDevices?.getUserMedia({
//         'video': true,
//       });

//       if (stream != null) {
//         _videoElement!.srcObject = stream;
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       } else {
//         print("كاميرا غير متاحة");
//       }
//     } catch (e) {
//       print("Error accessing the camera: $e");
//     }
//   }

//   Future<void> _takePicture() async {
//     if (_videoElement == null || !_isCameraInitialized) return;

//     final context = _canvasElement!.context2D;
//     context.drawImage(_videoElement!, 0, 0);
//     final imageData = _canvasElement!.toDataUrl('image/png');

//     // تحويل الصورة إلى Base64
//     final faceImageBase64 = imageData.split(',')[1];

//     // إرسال الصورة إلى السيرفر
//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/attendance'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'face_image': faceImageBase64,
//       }),
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('تم تسجيل الحضور بنجاح: ${data["message"]}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context as BuildContext).showSnackBar(
//         SnackBar(content: Text('فشل تسجيل الحضور: ${data["message"]}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل الحضور')),
//       body: SingleChildScrollView(  // لتجنب overflow
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               if (!_isCameraVisible) ...[
//                 const Text('يرجى إدخال بياناتك'),
//                 TextField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'الاسم'),
//                   onChanged: (value) {
//                     setState(() {
//                       _name = value;
//                     });
//                   },
//                 ),
//                 TextField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(labelText: 'اسم المستخدم'),
//                   onChanged: (value) {
//                     setState(() {
//                       _username = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_name.isNotEmpty && _username.isNotEmpty) {
//                       setState(() {
//                         _isCameraVisible = true;
//                       });
//                       _initializeCamera();
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('الرجاء إدخال جميع البيانات')),
//                       );
//                     }
//                   },
//                   child: const Text('التسجيل'),
//                 ),
//               ] else ...[
//                 const Text('التقط صورة للوجه لتسجيل الحضور'),
//                 const SizedBox(height: 16),
//                 _isCameraInitialized
//                     ? HtmlElementView(viewType: 'videoElement')
//                     : const Text('الكاميرا غير متاحة'),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _takePicture,
//                   child: const Text('التقاط صورة'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


//55555555555555555555555555555
import 'dart:html' as html;
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  html.VideoElement? _videoElement;
  bool _isCameraInitialized = false;
  bool _isCameraVisible = false;

  @override
  void dispose() {
    _videoElement?.pause();
    _videoElement?.srcObject = null;
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..width = 640
      ..height = 480;

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
      });

      if (stream != null) {
        _videoElement!.srcObject = stream;
        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        print("كاميرا غير متاحة");
      }
    } catch (e) {
      print("Error accessing the camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الحضور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isCameraVisible) ...[
              const Text('يرجى إدخال بياناتك'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCameraVisible = true;
                  });
                  _initializeCamera();
                },
                child: const Text('التسجيل'),
              ),
            ] else ...[
              const Text('التقط صورة للوجه لتسجيل الحضور'),
              const SizedBox(height: 16),
              _isCameraInitialized
                  ? Container(
                      width: 640,
                      height: 480,
                      child: HtmlElementView(viewType: 'videoElement'),
                    )
                  : const Text('الكاميرا غير متاحة'),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
