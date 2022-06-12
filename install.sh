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
    echo "-a   CPU architecture. Extracted using 'uname -i' by default."
    echo "-p   Package manager. Defaults to 'pkg'."
    echo "-u   Use sudo whenever necessary [sudo]. Not specified by default."
    echo ""
    echo "-h   Prints this message."
}

arch=$(uname -i)
install_dir=$HOME
sdk_version=33.0.1
with_cmdline=false
jdk_version=17
manifest="https://raw.githubusercontent.com/itsaky/androidide-build-tools/main/manifest.json"
pkgm="pkg"
m_sudo=""

OPTIND=1
while getopts "uch?i:s:j:m:a:p:" opt; do
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
    u) m_sudo="sudo"
      ;;
  esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

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
$m_sudo $pkgm install libcurl jq tar
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
if [ "$with_cmdline" = true ]; then
    sdk_url=$(echo $sdk_obj | jq -r ".sdk_with_cmdline")
fi
print_success "Found SDK URL: $sdk_url"
echo ""

# Check if android sdk has already been downloaded
downloaded_sdk="$install_dir/android-sdk.tar.xz"
use_downloaded=false
if [ -f $downloaded_sdk ]; then
    echo "Looks like the Android SDK has already been downloaded."
    printf "Would you like to use the already downloaded SDK? Downloaded SDK will be DELETED if you select 'no'. (y/n): "
    read ans
    if [[ "$ans" = "yes" || "$ans" = "y" ]]; then
        use_downloaded=true
    fi
    echo ""
fi

if [ ! "$use_downloaded" = "true" ]; then
    if [ -f $downloaded_sdk ]; then
        rm -vf $downloaded_sdk
    fi

    # Download the Android SDK
    print_info "Downloading Android SDK..."
    curl -L -o $downloaded_sdk $sdk_url
    print_success "Android SDK has been downloaded."
    echo ""
fi

if [ ! -f $downloaded_sdk ]; then
    print_err "Downloaded SDK does not exist."
    exit 1
fi

print_info "Extracting SDK..."
cd $install_dir
tar xvJf $(basename $downloaded_sdk)
cd -
print_success "SDK extracted successfully!"
echo ""

# Check JDK version to download and install
root_folder=$(jq -r ".jdk_11.root_folder?" $downloaded_manifest)
if [ "$jdk_version" = "17" ]; then
    # Install JDK 17
    if [ ! command -v $pkgm &> /dev/null ]; then
        print_err "'$pkgm' command not found. Try installing 'termux-tools' and 'apt'."
        exit 1
    fi

    print_info "Installing package: 'openjdk-17'"
    $m_sudo $pkgm install openjdk-17
    print_info "JDK 17 has been installed."
else
    print_info "Extracting JDK 11 download URL..."
    jdk_url=$(jq -r ".jdk_11.$arch" $downloaded_manifest)
    print_success "Found JDK URL: $jdk_url"
    echo ""

    downloaded_jdk="$install_dir/jdk11.tar.xz"
    use_downloaded=false

    if [ -f "$downloaded_jdk" ]; then
        echo "Looks like the JDK has already been downloaded."
        printf "Would you like to use the already downloaded JDK? Downloaded JDK will be DELETED if you select 'no'. (y/n): "
        read ans
        if [[ "$ans" = "yes" || "$ans" = "y" ]]; then
            use_downloaded=true
        fi
    echo ""
    fi

    if [ ! "$use_downloaded" = "true" ]; then
        if [ -f $downloaded_jdk ]; then
            rm -vf $downloaded_jdk
        fi

        # Download the JDK
        print_info "Downloading JDK 11..."
        curl -L -o $downloaded_jdk $jdk_url
        print_success "JDK has been downloaded."
        echo ""
    fi

    if [ ! -f $downloaded_jdk ]; then
        print_err "Downloaded JDK does not exist."
        exit 1
    fi

    print_info "Extracting JDK..."
    cd $install_dir
    tar xvJf $(basename $downloaded_jdk)
    cd -
    print_success "JDK extracted successfully!"
    echo ""
fi

jdk_dir=$(realpath "$install_dir/jdk")
if [ $jdk_version = "11" ] && [ ! -d $jdk_dir ]; then
    print_err "JDK directory '$jdk_dir' does not exist. Most probably the downloaded JDK has different root folder name."
    print_err "Cannot update ide-environment.properties"
    print_err ""
    print_err "You'll have to manually edit $SYSROOT/etc/ide-environment.properties file and set JAVA_HOME and ANDROID_SDK_ROOT."
    exit 1
fi

if [ $jdk_dir = "17" ]; then
    jdk_dir="$SYSROOT/opt/openjdk"
fi

print_info "Updating ide-environment.properties..."
print_info "JAVA_HOME=$jdk_dir"
echo ""
props_dir="$SYSROOT/etc"
props="$props_dir/ide-environment.properties"

if [ ! -d $props_dir ]; then
    $m_sudo mkdir -p $props_dir
fi

if [ ! -e $props ]; then
    $m_sudo printf "JAVA_HOME=$jdk_dir" > $props
    print_success "Properties file updated successfully!"
else
    printf "$props file already exists. Would you like to overwrite it? (y/n):"
    read ans
    if [[ "$ans" = "yes" || "$ans" = "y" ]]; then
        $m_sudo printf "JAVA_HOME=$jdk_dir" > $props
        print_success "Properties file updated successfully!"
    else
        print_err "Manually edit $SYSROOT/etc/ide-environment.properties file and set JAVA_HOME and ANDROID_SDK_ROOT."
    fi
fi
