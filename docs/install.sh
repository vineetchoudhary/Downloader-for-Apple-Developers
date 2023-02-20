#!/bin/sh

VERSION="2.2.0"
APPBOX_APP_NAME="Downloader.app"
APPBOX_GITHUB_FILE_NAME="Downloader.tar.gz"
GITHUB_RELEASES_BASE_URL="https://github.com/vineetchoudhary/Downloader-for-Apple-Developer/releases/download/$VERSION"
APPBOX_FULL_FILE_URL="$GITHUB_RELEASES_BASE_URL/$APPBOX_GITHUB_FILE_NAME"

ARIA2C_APP_NAME="aria2c"
ARIA2C_GITHUB_FILE_NAME="aria2c"
ARIA2C_FULL_FILE_URL="$GITHUB_RELEASES_BASE_URL/$ARIA2C_GITHUB_FILE_NAME"

ARIA2C_PARH='Contents/Resources/aria2c'
APPLICATION_DIR='/Applications'


echo "Downloading Downloader for Apple Developers $VERSION..."
curl -OL $APPBOX_FULL_FILE_URL
echo "Installing Downloader for Apple Developers $VERSION..."
tar -xf $APPBOX_GITHUB_FILE_NAME -C $APPLICATION_DIR
echo "Download aria2c $VERSION..."
curl -OL $ARIA2C_FULL_FILE_URL
echo "Installing aria2c $VERSION..."
mv $ARIA2C_GITHUB_FILE_NAME $APPLICATION_DIR/$APPBOX_APP_NAME/$ARIA2C_PARH
echo "Launch $APPBOX_APP_NAME from your Applications directory."
