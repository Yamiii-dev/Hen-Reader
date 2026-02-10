# Hen Reader

Hen Reader is a Flutter-based, cross-platform app for browsing Hentai from multiple sources, with support for custom plugins.

![Screenshot of the app](/screenshots/1.png)

## Disclaimer

This app contains adult content intended for users 18 years and older. By using this app, you confirm that you are of legal age in your jurisdiction.

## Currently supports
- Rule34.xxx
- E-hentai
- Custom source plugins (see `example_plugins` for guidance; official plugin documentation is not available yet)

## Getting Started

To build and run the application from the source, you will need to have the Flutter SDK installed.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yamiii-dev/hen-reader.git
    cd hen-reader
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Build the application:**
    
- **Windows**
    ```bash
    flutter build windows
    ```
- **Linux**
    ```bash
    flutter build linux
    ```
- **Android**
    ```bash
    flutter build apk
    ```

## Configuration

Some sources may benefit from or require API keys for full functionality. These can be configured in the **Settings** page, which is accessible from the app's side drawer.


## License

This project is licensed under the GNU General Public License v3.0. See the `LICENSE` file for more details.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests. Please note that the codebase is currently unrefactored and may be messy in places.