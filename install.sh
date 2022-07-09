#!/bin/bash

set -eu

Color_Off='\033[0m'
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'

print_info() {
    printf "${Blue}$1$Color_Off\n"
}

print_err() {
    printf "${Red}$1$Color_Off\n"
}

print_success() {
    printf "${Green}$1$Color_Off\n"
}

print_help() {
    echo "AndroidIDE build tools installer"
    echo "This script helps you easily install build tools in AndroidIDE."
    echo ""
    echo "Usage:"
    echo "${0} -s 33.0.1 -c -j 17"
    echo "This will install Android SDK 33.0.1 with command line tools and JDK 17."
    echo ""
    echo "Options :"
    echo "-i   Set the installation directory. Defaults to \$HOME."
    echo "-s   Android SDK version to download."
    echo "-c   Download Android SDK with command line tools."
    echo "-j   Choose whether to install JDK 11 or JDK 17. Please note that JDK 17 must be preferred. This option will be removed in future."
    echo "-m   Manifest file URL. Defaults to 'manifest.json' in 'androidide-build-tools' GitHub repository."
    echo ""
    echo "For testing purposes:"
    echo "-a   CPU architecture. Extracted using 'uname -m' by default."
    echo "-p   Package manager. Defaults to 'pkg'."
    echo "-l   Name of curl package that will be installed before starting installation process. Defaults to 'libcurl'."
    echo ""
    echo "-h   Prints this message."
}

download_and_extract() {
    # Display name to use in print messages
    name=$1

    # URL to download from
    url=$2

    # Directory in which the downloaded archive will be extracted
    dir=$3

    # Destination path for downloading the file
    dest=$4

    if [ ! -d $dir ]; then
        mkdir -p $dir
    fi

    cd $dir

    do_download=true
    if [ -f $dest ]; then
        name=$(basename $dest)
        print_info "File ${name} already exists."
        printf "Do you want to skip the download process? ([y]es/[n]o): "
        read skip
        if [[ "$skip" = "yes" || "$skip" = "y" ]]; then
            do_download=false
        fi
        echo ""
    fi

    if [ "$do_download" = "true" ]; then
        print_info "Downloading $name..."
        curl -L -o $dest $url
        print_success "$name has been downloaded."
        echo ""
    fi

    if [ ! -f $dest ]; then
        print_err "The downloaded file $name does not exist. Cannot proceed..."
        exit 1
    fi

    # Extract the downloaded archive
    print_info "Extracting downloaded archive..."
    tar xvJf $dest
    print_info "Extracted successfully"

    echo ""

    # Delete the downloaded file
    rm -vf $dest

    # cd into the previous working directory
    cd -
}

arch=$(uname -m)
install_dir=$HOME
sdk_version=33.0.1
with_cmdline=false
jdk_version=17
manifest="https://raw.githubusercontent.com/itsaky/androidide-build-tools/main/manifest.json"
pkgm="pkg"
pkg_curl="libcurl"

OPTIND=1
while getopts "uch?i:s:j:m:a:p:l:" opt; do
  case "$opt" in
    h|\?)
      print_help
      exit 0
      ;;
    i) install_dir=$OPTARG
      ;;
    s) sdk_version=$OPTARG
      ;;
    c) with_cmdline=true
      ;;
    j) jdk_version=$OPTARG
      ;;
    m) manifest=$OPTARG
      ;;
    a) arch=$OPTARG
      ;;
    p) pkgm=$OPTARG
      ;;
    l) pkg_curl=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [ "$arch" = "armv7l" ]; then
    arch="arm"
fi
# 64-bit CPU in 32-bit mode
if [ "$arch" = "armv8l" ]; then
    arch="arm"
fi

sdk_version="_${sdk_version//'.'/'_'}"

echo "------------------------------------------"
echo "Installation directory    : ${install_dir}"
echo "SDK version               : ${sdk_version}"
echo "JDK version               : ${jdk_version}"
echo "With command line tools   : ${with_cmdline}"
echo "------------------------------------------"
printf "Confirm configuration ([y]es/n[o]): "
read correct

if ! ([[ "$correct" = "yes" || "$correct" = "y" ]]); then
    print_err "Aborting."
    exit 1
fi

if [ ! -f $install_dir ]; then
    print_info "Installation directory does not exist. Creating directory..."
    mkdir -p $install_dir
fi

# Install required packages
print_info "Installing required packages.."
$pkgm install $pkg_curl jq tar
print_success "Packages installed"
echo ""

# Download the manifest.json file
print_info "Downloading manifest file..."
downloaded_manifest="$install_dir/manifest.json"
curl -L -o $downloaded_manifest $manifest
print_success "Manifest file downloaded"
echo ""

# Extract the Android SDK URL
print_info "Extracting Android SDK URL from manifest..."
sdk_obj=$(jq ".android_sdk | .${sdk_version} | .${arch}" $downloaded_manifest)
sdk_url=$(echo $sdk_obj | jq -r ".sdk")
print_success "Found SDK URL: $sdk_url"
echo ""

# Download and extract the Android SDK
download_and_extract "Android SDK" $sdk_url $install_dir "$install_dir/android-sdk.tar.xz"

if [ "$with_cmdline" = true ]; then
    # Download and extract the Command Line tools
    cmdline_url=$(jq -r ".android_sdk | .cmdline_tools" $downloaded_manifest)
    download_and_extract "Command line tools" $cmdline_url "$install_dir/android-sdk" "$install_dir/cmdline_tools.tar.xz"
fi

# Check JDK version to download and install
root_folder=$(jq -r ".jdk_11.root_folder?" $downloaded_manifest)
if [ "$jdk_version" = "17" ]; then
    # Install JDK 17
    if [ ! command -v $pkgm &> /dev/null ]; then
        print_err "'$pkgm' command not found. Try installing 'termux-tools' and 'apt'."
        exit 1
    fi

    print_info "Installing package: 'openjdk-17'"
    $pkgm install openjdk-17
    print_info "JDK 17 has been installed."
else
    print_info "Extracting JDK 11 download URL..."
    jdk_url=$(jq -r ".jdk_11.$arch" $downloaded_manifest)
    print_success "Found JDK URL: $jdk_url"
    echo ""

    download_and_extract "JDK 11" $jdk_url $install_dir "$install_dir/jdk11.tar.xz"
fi

jdk_dir=$(realpath "$install_dir/jdk")
if [ $jdk_version = "11" ] && [ ! -d $jdk_dir ]; then
    print_err "JDK directory '$jdk_dir' does not exist. Most probably the downloaded JDK has different root folder name."
    print_err "Cannot update ide-environment.properties"
    print_err ""
    print_err "You'll have to manually edit $SYSROOT/etc/ide-environment.properties file and set JAVA_HOME and ANDROID_SDK_ROOT."
    exit 1
fi

if [ $jdk_version = "17" ]; then
    jdk_dir="$SYSROOT/opt/openjdk"
fi

print_info "Updating ide-environment.properties..."
print_info "JAVA_HOME=$jdk_dir"
echo ""
props_dir="$SYSROOT/etc"
props="$props_dir/ide-environment.properties"

if [ ! -d $props_dir ]; then
    mkdir -p $props_dir
fi

if [ ! -e $props ]; then
    printf "JAVA_HOME=$jdk_dir" > $props
    print_success "Properties file updated successfully!"
else
    printf "$props file already exists. Would you like to overwrite it? (y/n):"
    read ans
    if [[ "$ans" = "yes" || "$ans" = "y" ]]; then
        printf "JAVA_HOME=$jdk_dir" > $props
        print_success "Properties file updated successfully!"
    else
        print_err "Manually edit $SYSROOT/etc/ide-environment.properties file and set JAVA_HOME and ANDROID_SDK_ROOT."
    fi
fi
