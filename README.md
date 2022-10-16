# Build Tools for [AndroidIDE](https://github.com/AndroidIDEOfficial/AndroidIDE).
<a href="https://github.com/AndroidIDEOfficial/AndroidIDE"><img src="https://androidide.com/github/img/androidide.php?part&for-the-badge"/></a><br>

This repository includes JDK 11, Android SDK and tools for AndroidIDE. An installation script is also available which you can use to easily install the tools.
```
AndroidIDE build tools installer
This script helps you easily install build tools in AndroidIDE.

Usage:
./install.sh -s 33.0.1 -c -j 17
This will install Android SDK 33.0.1 with command line tools and JDK 17.

Options :
-i   Set the installation directory. Defaults to $HOME.
-s   Android SDK version to download.
-c   Download Android SDK with command line tools.
-j   Choose whether to install JDK 11 or JDK 17. Please note that JDK 17 must be preferred. This option will be removed in future.
-m   Manifest file URL. Defaults to 'manifest.json' in 'androidide-build-tools' GitHub repository.

For testing purposes:
-a   CPU architecture. Extracted using 'uname -m' by default.
-p   Package manager. Defaults to 'pkg'.
-l   Name of curl package that will be installed before starting installation process. Defaults to 'libcurl'.

-h   Prints this message.
```

## Installing in AndroidIDE
- Open the AndroidIDE terminal.
- Get the installation script with :
```bash
wget https://raw.githubusercontent.com/AndroidIDEOfficial/androidide-build-tools/main/install.sh
```
- Give executable permissions to the installation script with:
```bash
chmod +x ./install.sh
```
- Start the installation process by executing the script with : `./install.sh`
- After you execute the script, it'll show a summary of the configuration. Type `y` to confirm the configuration and start the installation process.

Once the installation is finished, the `ide-environment.properties` file will also be updated. If the file already exists, you'll be asked to confirm if you want to rewrite the properties file.

The default configuration is enough for most users. If you want to configure the installation process (like downloading JDK 11 instead of the default JDK 17), you can do so by using the options provided by the script.

Execute the script with `-h` option to see a list of options that you can use.

## Download
You can manually download and install these tools from [Releases](https://github.com/AndroidIDEOfficial/androidide-build-tools/releases).

## Thanks to
- @Lzhiyong for [sdk-tools](https://github.com/Lzhiyong/sdk-tools).
