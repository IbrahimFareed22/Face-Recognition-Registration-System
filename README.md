Face Recognition Registration & Attendance System

A complete desktop application for student registration and attendance tracking using real-time face recognition.

 Overview
This system allows admins to register students by capturing their faces and later recognize them for automatic attendance. It's built as a college graduation project to showcase real-world integration between AI, database systems, and UI.

 Tech Stack
- Frontend UI: Python + Kivy
- Face Recognition: face_recognition + OpenCV
- Database: SQL Server + pyodbc
- Platform: Windows
- Language: Python 3

 Features
Registration Module:
- Capture live face using webcam
- Extract face encoding (128D vector) via face_recognition
- Store name, photo, and encoding in SQL Server

Attendance Module:
- Recognize faces in real-time from webcam
- Log attendance if match is found and no recent entry (5-minute gap)
- Feedback via Kivy UI and popups

 Database Schema
- Users (Id, Name, FaceImagePath, FaceEncoding)
- Attendance (Id, UserId, Timestamp)

 Structure
Face-Recognition-Registration-System/
├── face_registration/         # Kivy UI for face registration
├── attendance_module/         # Real-time recognition & logging
├── captured_faces/            # Saved student photos
├── face_icon.png              # UI logo
└── requirements.txt           # Python dependencies

 How to Run
1. Clone the repo
2. Install dependencies
3. Configure SQL Server
4. Run register.py and attendance.py

Author
[Ibrahim Fareed](https://github.com/IbrahimFareed22)
