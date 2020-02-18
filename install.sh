#!/bin/sh

VERSION="1.0.2"
APP_NAME="Downloader.app"
FILE_NAME="Downloader.tar.gz"
FILE_URL="https://github.com/vineetchoudhary/Downloader-for-Apple-Developer/releases/download/$VERSION/AppBox.tar.gz"
APPLICATION_DIR='/Applications'

echo "Downloading Downloader for Apple Developers $VERSION..."
curl -OL $FILE_URL
echo "Installing Downloader for Apple Developers $VERSION..."
tar -xf $FILE_NAME -C $APPLICATION_DIR
echo "Starting Downloader for Apple Developers $VERSION..."
open $APPLICATION_DIR/$APP_NAME
