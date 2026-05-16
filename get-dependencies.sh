#!/bin/sh
set -eu
ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
#Needed
sudo pacman -S --noconfirm --needed libadwaita gtksourceview5 hunspell ncurses libxml2-legacy libspelling hunspell-en_us hunspell-en_gb hunspell-en_au hunspell-en_ca hunspell-de hunspell-fr hunspell-es_es hunspell-es_any hunspell-it hunspell-nl hunspell-pl hunspell-ro hunspell-ru hunspell-el hunspell-hu

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Installing swift building packages..."
echo "---------------------------------------------------------------"

sudo ln -s /usr/lib/libncursesw.so.6 /usr/lib/libncurses.so.6

echo "Getting swift compiler..."
echo "---------------------------------------------------------------"
SWIFT_VERSION="6.2"
if [ "$ARCH" = "aarch64" ]; then
    URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2204-aarch64/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04-aarch64.tar.gz"
else
    URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2204/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04.tar.gz"
fi
if [ ! -d "/opt/swift" ]; then
    echo "Downloading official Swift toolchain for $ARCH..."
    curl -L "$URL" -o swift.tar.gz
    sudo mkdir -p /opt/swift
    sudo tar -xzf swift.tar.gz -C /opt/swift --strip-components=1
fi
export PATH="/opt/swift/usr/bin:$PATH"

echo "Installing swiftynotes from source packages..."
echo "---------------------------------------------------------------"
git clone https://github.com/makoni/swifty-notes-gtk.git && (
    cd swifty-notes-gtk
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version
    mkdir -p Sources/CSpelling/include
    cp /usr/include/libspelling-1/libspelling.h Sources/CSpelling/include/
    export SWIFT_FLAGS="-Xcc -I$(pwd)/Sources/CSpelling/include"
    chmod +x packaging/release/assemble-install-root.sh
    ./packaging/release/assemble-install-root.sh --prefix /usr --dest build-root
    sudo cp -rv build-root/usr/* /usr/
)

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi
