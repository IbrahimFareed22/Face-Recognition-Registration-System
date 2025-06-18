
import kivy
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.image import Image
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.popup import Popup
from kivy.core.window import Window
from kivy.clock import Clock
import cv2
import face_recognition
import numpy as np
import pyodbc
import datetime
import threading
import os

Window.clearcolor = (28/255, 41/255, 56/255, 1)  # Dark background

class AttendanceScreen(BoxLayout):
    def __init__(self, **kwargs):
        super(AttendanceScreen, self).__init__(orientation='vertical', spacing=20, padding=30, **kwargs)

        # User icon
        icon_path = os.path.join(os.path.dirname(__file__), "face_icon.png")
        if os.path.exists(icon_path):
            self.icon = Image(source=icon_path, size_hint=(1, 0.3))
            self.add_widget(self.icon)

        # Status label
        self.status_label = Label(
            text=" Press the button to start the camera and record attendance",
            color=(1, 1, 1, 1),
            font_size=18,
            size_hint=(1, 0.2),
            halign="center",
            valign="middle"
        )
        self.status_label.bind(size=self.status_label.setter('text_size'))
        self.add_widget(self.status_label)

        # Buttons layout
        btn_layout = BoxLayout(size_hint=(1, 0.2), spacing=20, padding=[50, 0, 50, 0])
        self.start_button = Button(text="Start Attendance", background_color=(0.26, 0.74, 1, 1), font_size=18)
        self.start_button.bind(on_press=self.start_attendance)
        btn_layout.add_widget(self.start_button)

        self.back_button = Button(text="Back", background_color=(0.5, 0, 0, 1), font_size=18)
        self.back_button.bind(on_press=self.go_back)
        btn_layout.add_widget(self.back_button)

        self.add_widget(btn_layout)

    def start_attendance(self, instance):
        threading.Thread(target=self.detect_faces, daemon=True).start()

    def show_popup(self, title, message):
        def show(*args):
            layout = BoxLayout(orientation='vertical', padding=10, spacing=10)
            msg = Label(text=message, color=(1, 1, 1, 1), halign='center')
            layout.add_widget(msg)
            close_btn = Button(text="Close", size_hint=(1, 0.3), background_color=(0.2, 0.6, 1, 1))
            layout.add_widget(close_btn)

            popup = Popup(title=title, content=layout, size_hint=(0.6, 0.4), auto_dismiss=False)
            close_btn.bind(on_press=popup.dismiss)
            popup.open()
        Clock.schedule_once(show)

    def detect_faces(self):
        try:
            conn = pyodbc.connect(
                r'DRIVER={ODBC Driver 17 for SQL Server};'
                r'SERVER=localhost;'
                r'DATABASE=FaceAuthDB;'
                r'Trusted_Connection=yes;'
            )
            cursor = conn.cursor()

            cursor.execute("SELECT Id, Name, FaceEncoding FROM Users")
            users = cursor.fetchall()

            known_encodings, user_ids, user_names = [], [], []
            for user in users:
                user_id, name, encoding_blob = user
                encoding_array = np.frombuffer(encoding_blob, dtype=np.float64)
                known_encodings.append(encoding_array)
                user_ids.append(user_id)
                user_names.append(name)

            cap = cv2.VideoCapture(0)
            self.status_label.text = "📷 Camera is running... Press ESC to close the window"

            while True:
                ret, frame = cap.read()
                if not ret:
                    break

                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                face_locations = face_recognition.face_locations(rgb_frame)
                face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

                for face_encoding in face_encodings:
                    matches = face_recognition.compare_faces(known_encodings, face_encoding, tolerance=0.5)
                    face_distances = face_recognition.face_distance(known_encodings, face_encoding)
                    best_match_index = np.argmin(face_distances) if face_distances.size > 0 else -1

                    if best_match_index != -1 and matches[best_match_index]:
                        user_id = user_ids[best_match_index]
                        user_name = user_names[best_match_index]

                        cursor.execute("SELECT TOP 1 Timestamp FROM Attendance WHERE UserId = ? ORDER BY Timestamp DESC", (user_id,))
                        last_record = cursor.fetchone()
                        now = datetime.datetime.now()

                        if not last_record or (now - last_record[0]).total_seconds() > 300:
                            cursor.execute("INSERT INTO Attendance (UserId) VALUES (?)", (user_id,))
                            conn.commit()
                            self.status_label.text = f" {user_name} attendance recorded"
                            self.show_popup("Success", f" {user_name}, your attendance was recorded!")
                        else:
                            self.status_label.text = f"⏱️ {user_name} already recorded"
                            self.show_popup("Notice", f"⏱️ {user_name}, attendance already recorded!")

                for (top, right, bottom, left) in face_locations:
                    top *= 4
                    right *= 4
                    bottom *= 4
                    left *= 4
                    cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)

                cv2.imshow('Attendance Camera', frame)
                if cv2.waitKey(1) == 27:
                    break

            cap.release()
            cv2.destroyAllWindows()
            conn.close()
            self.status_label.text = " Camera closed successfully."

        except Exception as e:
            print(" Error:", e)
            self.status_label.text = " An error occurred, check the console."
            self.show_popup("Error", "An error occurred, please try again.")

    def go_back(self, instance):
        App.get_running_app().stop()

class AttendanceApp(App):
    def build(self):
        return AttendanceScreen()

if __name__ == '__main__':
    AttendanceApp().run()
