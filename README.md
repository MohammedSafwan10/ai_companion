# AI Companion 🤖✨

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?logo=google)](https://ai.google.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A powerful Flutter AI assistant application featuring **9+ intelligent tools** powered by Google's Gemini 3 Flash. Features a beautiful gradient UI, dark/light themes, multimodal support (text, images, files), real-time streaming responses, and comprehensive usage analytics with dashboard.

---

## ✨ Features

### 🎯 AI-Powered Tools

| Feature | Description | Highlights |
|---------|-------------|------------|
| � **Dashboard** | Usage analytics and activity tracking | Statistics, activity log (30 entries), insights |
| �💬 **AI Chat** | Intelligent chatbot with streaming responses | Context memory, multimodal input, markdown rendering |
| 💻 **Code Generator** | Generate code in 14+ languages | Syntax highlighting, copy to clipboard |
| ✉️ **Email Generator** | Create professional emails | 5 tone options, customizable content |
| 🌐 **Translator** | Translate between 20+ languages | Fast, accurate translations |
| 📝 **Quiz Generator** | Create interactive quizzes | Customizable difficulty and topics |
| 🐦 **Tweet Crafter** | Craft engaging tweets | Character count, hashtag suggestions |
| 📸 **Instagram Caption** | Generate creative captions | Emoji support, trending hashtags |
| 🎥 **YouTube Summarizer** | Summarize video content | Key points extraction |

### 📊 Dashboard & Analytics
- **Usage Statistics** - Track interactions across all tools
- **Activity Log** - Recent actions with timestamps (up to 30 entries)
- **Quick Actions** - Fast access to frequently used features
- **Smart Insights** - Top feature tracking and session counts
- **Pull to Refresh** - Update stats in real-time

### 🎨 Beautiful UI/UX
- **Modern Design** - ChatGPT-style interface with pill-shaped inputs
- **Gradient Themes** - Stunning purple-blue gradients in light & dark modes
- **Smooth Animations** - 200ms theme transitions, optimized performance
- **Responsive Layout** - Adapts to different screen sizes
- **Material 3** - Latest Material Design components
- **Custom Widgets** - Reusable gradient buttons, message bubbles

### 🖼️ Multimodal Support
- **Image Upload** - Camera & gallery with preview
- **File Upload** - PDF, TXT, DOC, DOCX (up to 50MB)
- **Vision AI** - Analyze images and documents
- **Smart Previews** - File type icons and size display

### ⚡ Performance
- **Streaming Responses** - Real-time AI output with character-by-character display
- **Debounced Input** - Smooth typing without lag
- **Batch Updates** - Optimized state management
- **Background Operations** - Non-blocking storage saves
- **Efficient Scrolling** - Large cache for smooth lists
- **Smart Rebuilds** - Minimal widget reconstructions

---

## 📱 Screenshots

> Coming soon!

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.0 or higher
- **Dart** 3.9.2 or higher
- **Android Studio** or **VS Code**
- **Android Device/Emulator** (API 21+)
- **Google Gemini API Key** - [Get it here](https://makersuite.google.com/app/apikey)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MohammedSafwan10/ai_companion.git
   cd ai_companion
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Open `.env` and add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build APK** (optional)
   ```bash
   flutter build apk --release
   ```

---

## 🔑 Getting a Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key
5. Paste it in your `.env` file
6. **⚠️ Important:** Never commit `.env` to version control!

---

## 📦 Tech Stack

### Core Framework
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language (3.9.2+)
- **Google Generative AI** - Gemini 2.5 Flash API

### State Management
- **Riverpod** - Modern reactive state management
- **Flutter Riverpod** - Widget integration

### Storage & Persistence
- **SharedPreferences** - Local storage for chat history, usage stats, and activity logs
- **Custom StorageService** - Structured data persistence

### UI Libraries
- **Flutter Markdown** - Rich text rendering with code highlighting
- **Flutter Syntax View** - Code syntax highlighting
- **Image Picker** - Camera and gallery access
- **Native File Picker** - Cross-platform file selection
- **Permission Handler** - Runtime permissions (Android 13+ compatible)

### Utilities
- **Flutter Dotenv** - Environment variable management
- **URL Launcher** - Open external links

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── app_constants.dart       # App-wide constants
│   │   └── env_config.dart          # Environment configuration
│   ├── theme/
│   │   └── app_theme.dart           # Light/Dark theme definitions
│   └── widgets/
│       ├── app_drawer.dart          # Navigation drawer with activity log & insights
│       ├── gradient_button.dart     # Reusable gradient button
│       ├── message_bubble.dart      # Chat message UI
│       ├── thinking_indicator.dart  # AI thinking animation
│       ├── custom_text_field.dart   # Styled input fields
│       └── loading_overlay.dart     # Loading state overlay
├── features/
│   ├── dashboard/                   # 📊 Usage analytics & statistics
│   ├── chat/                        # 💬 AI Chat with multimodal support
│   ├── email_generator/             # 📧 Email generation
│   ├── code_generator/              # 💻 Code generation (14+ languages)
│   ├── quiz_generator/              # 📝 Quiz creation
│   ├── youtube_summarizer/          # 🎥 Video summarization
│   ├── tweet_crafter/               # 🐦 Tweet generation
│   ├── instagram_caption/           # 📷 Caption creation
│   ├── translator/                  # 🌍 Language translation
│   ├── home/                        # 🏠 Home screen with feature grid
│   └── settings/                    # ⚙️ App settings & preferences
├── providers/
│   ├── gemini_provider.dart         # Gemini service provider
│   ├── theme_provider.dart          # Theme state management
│   └── ai_model_provider.dart       # AI model configuration
├── services/
│   ├── gemini_service.dart          # Gemini API integration
│   ├── storage_service.dart         # Local data persistence & activity tracking
│   └── system_prompts.dart          # AI prompt templates
└── main.dart                        # App entry point
```

## 🎯 Supported File Types

### Gemini 2.5 Flash Compatible:
- **Documents:** PDF, TXT
- **Images:** JPEG, PNG, WebP, GIF, HEIC, HEIF
- **Audio:** WAV, MP3, AIFF, AAC, OGG, FLAC
- **Video:** MP4, MPEG, MOV, AVI, FLV, MPG, WEBM, WMV

**File Size Limit:** 50MB per file

## ⚙️ Configuration

### Android Permissions
The app automatically handles:
- Camera access (for photo capture)
- Storage access (Android 12 and below)
- System photo picker (Android 13+)

### Minimum SDK
- **minSdk:** 21 (Android 5.0 Lollipop)
- **targetSdk:** Latest
- **compileSdk:** Latest

## 🎨 Features in Detail

### 1. Dashboard & Analytics
- **Usage Statistics:** Track interactions with each AI feature
- **Activity Log:** View last 30 activities with timestamps
- **Insights:** Clear activity history, view all statistics
- **Persistent Storage:** All data saved locally via StorageService
- **Navigation Drawer:** Quick access from any screen

### 2. AI Chat
- Persistent conversation history
- Context-aware responses
- Image and file analysis (photos, documents, audio)
- Markdown formatting
- Code syntax highlighting
- Copy buttons for messages
- Scroll-to-bottom FAB
- Thinking indicator
- **Multimodal Support:** Attach images, PDFs, audio files

### 3. Email Generator
**Tones Available:**
- Professional
- Casual
- Formal
- Friendly
- Persuasive

### 4. Code Generator
**Languages Supported:**
Python, JavaScript, Java, C++, C#, Go, Rust, TypeScript, PHP, Swift, Kotlin, Ruby, Dart, HTML/CSS

### 5. Quiz Generator
- Multiple choice questions
- Customizable number of questions
- Structured JSON output
- Interactive UI

### 6. YouTube Summarizer
- Paste video URL
- Extracts transcript
- Generates concise summary
- Key points extraction

## 🐛 Troubleshooting

### Issue: "MissingPluginException"
**Solution:** Run `flutter clean && flutter pub get` and rebuild

### Issue: "Permission denied" for camera/gallery
**Solution:** Ensure permissions are added in AndroidManifest.xml and app has been rebuilt

### Issue: "File picker not working"
**Solution:** Check that file size is under 50MB and file type is supported

### Issue: "API Key error"
**Solution:** Verify `.env` file exists and contains valid API key

### Issue: App lag when typing
**Solution:** Already optimized! If still experiencing lag, try:
- Clear app cache
- Restart app
- Check device performance

## 📊 Performance Optimizations

✅ **Debounced text input** - Reduces rebuilds while typing  
✅ **Batch setState calls** - Minimizes widget rebuilds  
✅ **Post-frame callbacks** - Smooth scrolling  
✅ **Background storage** - Non-blocking saves  
✅ **Large ListView cache** - Improved scroll performance  
✅ **ValueKey for messages** - Stable widget identity  
✅ **Mounted checks** - Prevents disposed widget errors  

## 🔐 Security

- ✅ API keys stored in `.env` (not committed to git)
- ✅ `.env` added to `.gitignore`
- ✅ No hardcoded credentials
- ✅ Secure permission handling

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Mohammed Safwan
- GitHub: [@MohammedSafwan10](https://github.com/MohammedSafwan10)

## 🙏 Acknowledgments

- Google Gemini AI for the powerful API
- Flutter team for the amazing framework
- Riverpod for state management
- All contributors and testers

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on [GitHub](https://github.com/MohammedSafwan10/ai_companion/issues)
- Check the [Security Policy](SECURITY.md) for vulnerability reporting
- Read [Contributing Guidelines](CONTRIBUTING.md) before submitting PRs

---

**Built with ❤️ using Flutter and Gemini AI**

⭐ Star this repo if you find it helpful!
