#!/bin/sh
set -eu

# Setup
ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/me.spaceinbox.swiftynotes.svg
export DESKTOP=/usr/share/applications/me.spaceinbox.swiftynotes.desktop
export STARTUPWMCLASS=me.spaceinbox.swiftynotes # Default to Wayland's wmclass. For X11, GTK_CLASS_FIX will force the wmclass to be the Wayland one.
export GTK_CLASS_FIX=1

# Deploy dependencies
quick-sharun \
    /usr/bin/swiftynotes \
    /usr/libexec/swifty-notes/swiftynotes \
    /usr/share/hunspell/ \
    /usr/lib/libspelling-1.so* \
    /usr/lib/libgtk-4.so* \
    /usr/lib/libadwaita-1.so* \
    /usr/lib/libgtksourceview-5.so* \
    /usr/lib/libenchant-2.so* \
    /usr/lib/libhunspell-1.7.so* \
    /usr/lib/libxml2.so.2* \
    /usr/lib/libncursesw.so.6*

# Additional changes can be done in between here
cp -r /usr/libexec/swifty-notes/swifty-notes-gtk_SwiftyNotes.resources AppDir/bin/
rm -f AppDir/shared/lib/enchant-2/enchant_aspell.so
rm -f AppDir/shared/lib/enchant-2/enchant_hspell.so
rm -f AppDir/shared/lib/enchant-2/enchant_nuspell.so
rm -f AppDir/shared/lib/enchant-2/enchant_voikko.so

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead#quick-sharun --test ./*.AppImage
