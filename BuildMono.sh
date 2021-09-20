#!/usr/bin/env bash

EMBEDDINATOR_SOURCE_PATH=""
MONO_ARM64_LIB_PATH="lib/xbuild/Xamarin/Android/lib/arm64-v8a"
XCODE_VERSION=""

if [ "${1}" != "" ]; then
    EMBEDDINATOR_SOURCE_PATH=$1
fi

git_reset () {
    git clean -dfx
    git submodule foreach --recursive git clean -xfd
    git reset --hard HEAD
    git submodule foreach --recursive git reset --hard HEAD
    git submodule init 
    git submodule update --init --recursive
}

build () {
    make prepare || exit 1
    make || exit 1
}

XCODE_VERSION=`xcodebuild -version | head -1`
XCODE_PATH=`xcode-select -p`

# Check Xcode version
if [ "${XCODE_VERSION}" != "Xcode 10.3" ]; then
    echo "This building only applicate with Xcode 10.3. Please download the Xcode 10.3 and install it as default"
    exit 1
fi

# Check Xcode path
if [ "${XCODE_PATH}" != "/Applications/Xcode.app/Contents/Developer" ]; then
    echo "Xcode 10.3 must set as default path '/Applications/Xcode.app/'. Please correct it as below"
    echo "Ex:"
    echo " - Rename the '/Applications/Xcode 10.3.app' to '/Applications/Xcode.app'"
    echo " - Run command in terminal: sudo xcode-select --switch /Applications/Xcode.app"
    exit 1
fi

# Install dependencies
brew install cmake
brew install libtool
brew install p7zip
brew install gdk-pixbuf
brew install gettext
brew install coreutils
brew install findutils
brew install gnu-tar
brew install gnu-sed
brew install gawk
brew install gnutls
brew install gnu-indent
brew install gnu-getopt
brew install intltool
brew install scons
brew install wget
brew install xz
brew install automake

# Git clean
git_reset

# Build Mono Debug mode
build

# Build Mono Release mode
sed -i'.bak' "s/CONFIGURATION = Debug/CONFIGURATION = Release/g" Makefile
build

# Install lib to Embeddinator
if [ "${1}" != "" ]; then
    cp bin/Release/$MONO_ARM64_LIB_PATH/libmonosgen-2.0.so.* $EMBEDDINATOR_SOURCE_PATH/external/Xamarin.Android/$MONO_ARM64_LIB_PATH/
else
    echo "The Embeddinator source path is not set for deploying automatically. Please copy these ARM64 libmonosgen-2.0.so.* manually"
fi

