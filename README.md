# AI Companion 🤖

A powerful Flutter Android application featuring multiple AI-powered tools, built with Google's Gemini 2.5 Flash. Beautiful gradient UI with dark/light themes, multimodal support (text, images, files), and ChatGPT-style interface.

## ✨ Features

### 🎯 Core Features
- **💬 AI Chat** - Intelligent chatbot with conversation history and context memory
- **📧 Email Generator** - Generate professional emails in 5 tones (Professional, Casual, Formal, Friendly, Persuasive)
- **💻 Code Generator** - Generate code in 14+ programming languages with syntax highlighting
- **📝 Quiz Generator** - Create interactive quizzes with structured questions
- **🎥 YouTube Summarizer** - Extract and summarize video transcripts
- **🐦 Tweet Crafter** - Create engaging tweets with character count validation
- **📸 Instagram Caption** - Generate creative captions with hashtag suggestions
- **🌐 Translator** - Translate text between 20+ languages

### 🎨 UI/UX
- **ChatGPT-Style Interface** - Modern, clean chat UI with pill-shaped input
- **Gradient Themes** - Beautiful purple-blue gradients in light and dark modes
- **Smooth Animations** - 200ms theme transitions with optimized performance
- **Bottom Navigation** - Easy access to all features
- **Markdown Rendering** - Rich text formatting with code blocks and copy buttons

### 🖼️ Multimodal Support
- **Image Upload** - Camera and gallery support with preview
- **File Upload** - PDF, TXT, DOC, DOCX support (up to 50MB)
- **Vision AI** - Analyze images and documents with Gemini
- **File Preview** - Smart previews with file size display

### ⚡ Performance
- **Debounced Input** - Smooth typing without lag
- **Batch State Updates** - Optimized rebuilds
- **Background Operations** - Non-blocking storage saves
- **Efficient Scrolling** - Large cache with smooth scrolling
- **Post-Frame Callbacks** - Jank-free UI updates

## 📱 Screenshots

> Add your app screenshots here

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio / VS Code
- Android device or emulator (API 21+)
- Google Gemini API Key ([Get it here](https://makersuite.google.com/app/apikey))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ai_companion.git
   cd ai_companion
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Copy `.env.example` to `.env`
   ```bash
   cp .env.example .env
   ```
   - Open `.env` and add your Gemini API key:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔑 API Key Setup

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key and paste it in `.env` file
5. **Important:** Never commit `.env` file to version control

## 📦 Tech Stack

### Core
- **Flutter** - UI framework
- **Dart** - Programming language
- **Google Generative AI** - Gemini 2.5 Flash API

### State Management
- **Riverpod** - Modern reactive state management
- **SharedPreferences** - Local storage for chat history and settings

### UI Components
- **Flutter Markdown** - Rich text rendering
- **Image Picker** - Camera and gallery access
- **Native File Picker** - Document selection

### Permissions
- **Permission Handler** - Runtime permission management (Android 13+ compatible)

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
│       ├── gradient_button.dart     # Reusable gradient button
│       ├── message_bubble.dart      # Chat message UI
│       ├── thinking_indicator.dart  # AI thinking animation
│       └── custom_text_field.dart   # Styled input fields
├── features/
│   ├── chat/                        # AI Chat feature
│   ├── email_generator/             # Email generation
│   ├── code_generator/              # Code generation
│   ├── quiz_generator/              # Quiz creation
│   ├── youtube_summarizer/          # Video summarization
│   ├── tweet_crafter/               # Tweet generation
│   ├── instagram_caption/           # Caption creation
│   ├── translator/                  # Language translation
│   ├── home/                        # Home screen with navigation
│   └── settings/                    # App settings
├── providers/
│   ├── gemini_provider.dart         # Gemini service provider
│   ├── theme_provider.dart          # Theme state management
│   └── ai_model_provider.dart       # AI model configuration
├── services/
│   ├── gemini_service.dart          # Gemini API integration
│   ├── storage_service.dart         # Local data persistence
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

### 1. AI Chat
- Persistent conversation history
- Context-aware responses
- Image and file analysis
- Markdown formatting
- Code syntax highlighting
- Copy buttons for messages
- Scroll-to-bottom FAB
- Thinking indicator

### 2. Email Generator
**Tones Available:**
- Professional
- Casual
- Formal
- Friendly
- Persuasive

### 3. Code Generator
**Languages Supported:**
Python, JavaScript, Java, C++, C#, Go, Rust, TypeScript, PHP, Swift, Kotlin, Ruby, Dart, HTML/CSS

### 4. Quiz Generator
- Multiple choice questions
- Customizable number of questions
- Structured JSON output
- Interactive UI

### 5. YouTube Summarizer
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

Your Name
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Name](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Google Gemini AI for the powerful API
- Flutter team for the amazing framework
- Riverpod for state management
- All contributors and testers

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Contact: your.email@example.com

---

**Built with ❤️ using Flutter and Gemini AI**

⭐ Star this repo if you find it helpful!
