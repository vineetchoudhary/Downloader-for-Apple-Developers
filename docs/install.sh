#!/bin/sh

VERSION="2.2.0"
APPBOX_APP_NAME="Downloader.app"
APPBOX_GITHUB_FILE_NAME="Downloader.tar.gz"
GITHUB_RELEASES_BASE_URL="https://github.com/vineetchoudhary/Downloader-for-Apple-Developer/releases/download/$VERSION"
APPBOX_FULL_FILE_URL="$GITHUB_RELEASES_BASE_URL/$APPBOX_GITHUB_FILE_NAME"

APPLICATION_DIR='/Applications'

## Download AppBox & aria2c
echo "Downloading Downloader for Apple Developers $VERSION..."
curl -# -OL $APPBOX_FULL_FILE_URL

## Uninstall AppBox & aria2c
echo "Uninstalling existing AppBox & aria2c..."
rm -rf $APPLICATION_DIR/$APPBOX_APP_NAME

## Install AppBox & aria2c
mkdir "$APPLICATION_SUPPORT_DIR"

echo "Installing Downloader for Apple Developers $VERSION..."
tar -xf $APPBOX_GITHUB_FILE_NAME -C $APPLICATION_DIR

echo "Installing aria2c $VERSION..."
brew install aria2

## Cleanup
echo "Cleaning up..."
rm -rf $APPBOX_GITHUB_FILE_NAME

## Launch Downloader
echo "Starting AppBox..."
open $APPLICATION_DIR/$APPBOX_APP_NAME

echo ""
echo ""
echo "If Downloader doesn't start, please open it manually from Applications folder by right click on it and select Open."
echo ""