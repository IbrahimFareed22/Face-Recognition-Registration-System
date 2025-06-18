// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
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

//   // دالة الحضور
//   Future<void> _markAttendance() async {
//     if (_image == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('يرجى التقاط صورة للوجه')),
//         );
//       }
//       return;
//     }

//     final bytes = await _image!.readAsBytes();
//     final faceImageBase64 = base64Encode(bytes);

//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:5000/attendance'),  // غيّر IP لو لازم
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'face_image': faceImageBase64,
//       }),
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('تم تسجيل الحضور بنجاح: ${data["message"]}')),
//         );
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('فشل تسجيل الحضور: ${data["message"]}')),
//         );
//       }
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
//             const Text('التقط صورة للوجه لتسجيل الحضور'),
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
//               onPressed: _markAttendance,
//               child: const Text('تسجيل الحضور'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:flutter/foundation.dart';  // للتأكد من البيئة (ويب أو موبايل)

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  html.VideoElement? _videoElement; // عنصر الفيديو لعرض الكاميرا
  html.MediaStream? _mediaStream; // تدفق الكاميرا
  Uint8List? _imageBytes; // لتخزين الصورة كـ Bytes

  // دالة لاختيار الصورة باستخدام الكاميرا أو فتح الكاميرا في Web
  Future<void> _startCamera() async {
    if (kIsWeb) {
      // إذا كنا نعمل على Flutter Web
      _videoElement = html.VideoElement();
      _videoElement!.width = 640;
      _videoElement!.height = 480;

      try {
        _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
          'video': true,
        });
        _videoElement!.srcObject = _mediaStream;
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في الوصول إلى الكاميرا')),
        );
      }
    } else {
      // في حالة العمل على الموبايل (أندرويد أو iOS)
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = Uint8List.fromList(bytes);
        });
      }
    }
  }

  // دالة تسجيل الحضور
  Future<void> _markAttendance() async {
    if (_imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى التقاط صورة للوجه')),
        );
      }
      return;
    }

    final faceImageBase64 = base64Encode(_imageBytes!);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/attendance'),  // غيّر IP لو لازم
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'face_image': faceImageBase64,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسجيل الحضور بنجاح: ${data["message"]}')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الحضور: ${data["message"]}')),
        );
      }
    }
  }

  @override
  void dispose() {
    // إغلاق تدفق الكاميرا عند مغادرة الشاشة
    _mediaStream?.getTracks().forEach((track) {
      track.stop();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الحضور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('التقط صورة للوجه لتسجيل الحضور'),
            const SizedBox(height: 16),
            kIsWeb
                ? _videoElement != null
                    ? SizedBox(
                        width: 640,
                        height: 480,
                        child: HtmlElementView(viewType: 'videoElement'),
                      )
                    : const Text('لم يتم فتح الكاميرا')
                : _imageBytes != null
                    ? Image.memory(_imageBytes!, height: 200)
                    : const Text('لم يتم التقاط صورة'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('فتح الكاميرا'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _markAttendance,
              child: const Text('تسجيل الحضور'),
            ),
          ],
        ),
      ),
    );
  }
}
