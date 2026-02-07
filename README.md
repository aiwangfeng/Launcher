# Launcher for macOS

A fast, lightweight application launcher for macOS built with SwiftUI and AppKit.

## Features

- **Blazing Fast Search**: Instantly find and launch apps.
- **Fuzzy Matching**: Smart search algorithm that handles typos and abbreviations.
- **Global Hotkey**: Press `Ctrl` + `Alt` + `L` to toggle the launcher from anywhere.
- **Recent Apps**: Quickly access your most frequently used applications.
- **Category Grouping**: Apps are automatically organized by their system categories.
- **Keyboard Navigation**: Use arrow keys to navigate and `Enter` to launch.
- **Modern UI**: Clean, native macOS design with visual effects.

## Installation

### Build from Source

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/Launcher.git
    cd Launcher
    ```

2. Build the app:

    ```bash
    ./build-app.sh
    ```

3. Move the app to your Applications folder:

    ```bash
    mv build/Launcher.app /Applications/
    ```

## Usage

1. Launch the app. A menu bar icon (🚀) will appear.
2. Press `Ctrl` + `Alt` + `L` to open the launcher.
3. Type to search for an app.
4. Press `Enter` to launch the selected app.
5. Press `Esc` to close the launcher.

## Requirements

- macOS 14.0 or later

## License

MIT License
