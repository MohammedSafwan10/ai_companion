# Contributing to AI Companion

Thank you for your interest in contributing to AI Companion! 🎉

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear title and description
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots (if applicable)
- Your environment (OS, Flutter version, etc.)

### Suggesting Features

We welcome feature suggestions! Please:
- Check if the feature has already been suggested
- Clearly describe the feature and its benefits
- Provide examples or mockups if possible

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/MohammedSafwan10/ai_companion.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add: Brief description of your changes"
   ```
   
   Use conventional commits:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for updates to existing features
   - `Docs:` for documentation changes
   - `Style:` for formatting changes
   - `Refactor:` for code refactoring

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**
   - Provide a clear description of the changes
   - Link any related issues
   - Add screenshots for UI changes

## Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Add comments for complex logic
- Run `flutter analyze` before committing

## Development Setup

1. Install Flutter SDK (3.x or higher)
2. Clone the repository
3. Run `flutter pub get`
4. Create a `.env` file with your Gemini API key
5. Run `flutter run`

## Project Structure

```
lib/
├── core/           # Core functionality (theme, widgets, config)
├── features/       # Feature modules
├── providers/      # State management
└── services/       # Business logic
```

## Questions?

Feel free to open an issue for any questions or concerns!

---

Thank you for contributing! 🚀
