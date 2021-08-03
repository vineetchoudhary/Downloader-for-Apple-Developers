#!/bin/sh

VERSION="2.2.0"
APP_NAME="Downloader.app"
FILE_NAME="Downloader.tar.gz"
FILE_URL="https://github.com/vineetchoudhary/Downloader-for-Apple-Developer/releases/download/$VERSION/$FILE_NAME"
APPLICATION_DIR='/Applications'

echo "Downloading Downloader for Apple Developers $VERSION..."
curl -OL $FILE_URL
echo "Installing Downloader for Apple Developers $VERSION..."
tar -xf $FILE_NAME -C $APPLICATION_DIR
echo "Starting Downloader for Apple Developers $VERSION..."
open $APPLICATION_DIR/$APP_NAME
