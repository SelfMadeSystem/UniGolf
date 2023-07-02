#!/usr/bin/env bash

EXPORT_PATH="./exports"
PACKAGE_PATH=$EXPORT_PATH/package

mkdir -p $PACKAGE_PATH
rm -rf $PACKAGE_PATH/*

# Copy Android apk
cp "$EXPORT_PATH/android/UniGolf.apk" "$PACKAGE_PATH/"

# Make Linux tar
tar -czvf $PACKAGE_PATH/UniGolfLinux.tar.gz $EXPORT_PATH/linux

# Make Windows zip
zip -r $PACKAGE_PATH/UniGolfWindows.zip $EXPORT_PATH/win

