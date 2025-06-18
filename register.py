
import kivy
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.image import Image
from kivy.core.window import Window
from kivy.graphics import Color, RoundedRectangle
import cv2
import threading
import pyodbc
import os
import uuid
import face_recognition

# تعيين حجم النافذة وخلفية
Window.size = (600, 600)
Window.clearcolor = (16/255, 24/255, 32/255, 1)  # لون داكن

# مجلد الصور
if not os.path.exists("captured_faces"):
    os.makedirs("captured_faces")

# الاتصال بقاعدة البيانات
conn = pyodbc.connect('Driver={SQL Server};Server=DESKTOP-HD3JDRK;Database=FaceAuthDB;Trusted_Connection=yes;')
cursor = conn.cursor()

# زر بشكل جذاب
class RoundedButton(Button):
    def __init__(self, **kwargs):
        super(RoundedButton, self).__init__(**kwargs)
        self.background_normal = ''
        self.background_down = ''
        self.font_size = 18
        self.color = (1, 1, 1, 1)
        with self.canvas.before:
            Color(rgba=self.background_color)
            self.rect = RoundedRectangle(radius=[20], pos=self.pos, size=self.size)
        self.bind(pos=self.update_rect, size=self.update_rect)

    def update_rect(self, *args):
        self.rect.pos = self.pos
        self.rect.size = self.size

# مدخل الاسم 
class GlassTextInput(TextInput):
    def __init__(self, **kwargs):
        super(GlassTextInput, self).__init__(**kwargs)
        hint_text='Enter your name',
        multiline=False,
        font_size=24,
        size_hint=(1, 0.15),
        background_color=(36/255, 49/255, 69/255, 0.6),
        foreground_color=(1, 1, 1, 1),
        cursor_color=(1, 1, 1, 1),
        hint_text_color=(0.7, 0.7, 0.7, 1)
        with self.canvas.before:
            Color(rgba=(36/255, 49/255, 69/255, 0.6))
            self.rect = RoundedRectangle(radius=[15], pos=self.pos, size=self.size)
        self.bind(pos=self.update_rect, size=self.update_rect)

    def update_rect(self, *args):
        self.rect.pos = self.pos
        self.rect.size = self.size

class RegisterScreen(BoxLayout):
    def __init__(self, **kwargs):
        super(RegisterScreen, self).__init__(orientation='vertical', padding=20, spacing=15, **kwargs)

        self.avatar = Image(source='face_icon.png', size_hint=(1, 0.35))
        self.add_widget(self.avatar)

        self.name_input = GlassTextInput(
            hint_text='Enter your name',
            multiline=False,
            size_hint=(1, 0.12)
        )
        self.add_widget(self.name_input)

        self.capture_button = RoundedButton(
            text='Capture Face',
            size_hint=(1, 0.12),
            background_color=(0/255, 172/255, 237/255, 1)
        )
        self.capture_button.bind(on_press=self.capture_face)
        self.add_widget(self.capture_button)

        self.clear_button = RoundedButton(
            text='Clear',
            size_hint=(1, 0.12),
            background_color=(36/255, 69/255, 89/255, 1)
        )
        self.clear_button.bind(on_press=self.clear_input)
        self.add_widget(self.clear_button)

        self.back_button = RoundedButton(
            text='Back',
            size_hint=(1, 0.12),
            background_color=(130/255, 40/255, 50/255, 1)
        )
        self.back_button.bind(on_press=self.go_back)
        self.add_widget(self.back_button)

        self.status_label = Label(
            text='',
            size_hint=(1, 0.15),
            color=(1, 1, 1, 1),
            font_size=16
        )
        self.add_widget(self.status_label)

    def capture_face(self, instance):
        threading.Thread(target=self._capture_and_save_face, daemon=True).start()

    def _capture_and_save_face(self):
        name = self.name_input.text.strip()
        if not name:
            self.update_status("Please enter a name.")
            return

        cap = cv2.VideoCapture(0)
        if not cap.isOpened():
            self.update_status("Cannot open camera.")
            return

        self.update_status("Press SPACE to capture face, ESC to cancel.")
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            cv2.imshow('Capture Face (Press SPACE)', frame)
            key = cv2.waitKey(1)

            if key == 27:
                self.update_status("Capture cancelled.")
                break
            elif key == 32:
                filename = f"{name}_{uuid.uuid4().hex}.jpg"
                filepath = os.path.join("captured_faces", filename)
                cv2.imwrite(filepath, frame)

                face_encodings = face_recognition.face_encodings(frame)
                if face_encodings:
                    face_encoding_data = face_encodings[0].tobytes()
                    cursor.execute("INSERT INTO Users (Name, FaceImagePath, FaceEncoding) VALUES (?, ?, ?)",
                                   name, filepath, face_encoding_data)
                    conn.commit()
                    self.update_status("Face saved and registered successfully.")
                else:
                    self.update_status("No face found. Try again.")
                break

        cap.release()
        cv2.destroyAllWindows()

    def clear_input(self, instance):
        self.name_input.text = ''
        self.update_status("")

    def go_back(self, instance):
        App.get_running_app().stop()

    def update_status(self, message):
        self.status_label.text = message
        print(message)

class FaceApp(App):
    def build(self):
        self.title = "Face Registration"
        return RegisterScreen()

if __name__ == '__main__':
    FaceApp().run()
