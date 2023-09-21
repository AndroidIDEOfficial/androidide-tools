# Build Tools for [AndroidIDE](https://github.com/AndroidIDEOfficial/AndroidIDE).
<a href="https://github.com/AndroidIDEOfficial/AndroidIDE"><img src="https://androidide.com/github/img/androidide.php?part&for-the-badge"/></a><br>

This repository includes JDK 11 (now _**deprecated**_), Android SDK and tools for AndroidIDE. An installation script is also available which you can use to easily install the tools.
```
AndroidIDE build tools installer
This script helps you easily install build tools in AndroidIDE.

Usage:
./scripts/idesetup -s 34.0.4 -c -j 17
This will install Android SDK 34.0.4 with command line tools and JDK 17.

Options :
-i   Set the installation directory. Defaults to $HOME.
-s   Android SDK version to download.
-c   Download Android SDK with command line tools.
-m   Manifest file URL. Defaults to 'manifest.json' in 'androidide-tools' GitHub repository.
-j   OpenJDK version to install. Values can be '17' or '21'

For testing purposes:
-a   CPU architecture. Extracted using 'uname -m' by default.
-p   Package manager. Defaults to 'pkg'.
-l   Name of curl package that will be installed before starting installation process. Defaults to 'libcurl'.

-h   Prints this message.
```

## Installing in AndroidIDE
- Open the AndroidIDE terminal.
- Start the installation process by executing : `idesetup -c`
- After you execute the command, it'll show a summary of the configuration. Type `y` to confirm the configuration and start the installation process.

The default configuration is enough for most users. If you want to configure the installation process (like downloading a different SDK tools version), you can do so by using the options provided by the script.

Execute the script with `-h` option to see a list of options that you can use.

## Download
You can manually download and install these tools from [releases](https://github.com/AndroidIDEOfficial/androidide-build-tools/releases). A step-by-step guide is available on [our blog](https://androidide.com/blogs/getting-started/2023/07/17/manually-installing-build-tools-in-androidide/).

## Thanks to
- @Lzhiyong for [sdk-tools](https://github.com/Lzhiyong/sdk-tools).
