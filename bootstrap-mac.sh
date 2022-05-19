#!/usr/bin/env bash
#
# Copyright (C) 2017 KuoE0 <kuoe0.tw@gmail.com>
#
# Distributed under terms of the MIT license.


mkdir -p /Users/Adobe
mkdir -p /Users/Adobe/LightroomSync


###
### Xcode
###
xcode-select -p > /dev/null 2>&1
if [ "$?" != "0" ]; then
	echo "Installing Xcode Command Line Tools..."
	osascript installCommandLineTools.AppleScript
else
	echo "Xcode already installed."
	# Auto accept Xcode license
	sudo xcodebuild -license accept
fi

###
### Command Line Setup
###

# brew does not exist
if ! which brew &> /dev/null; then
	# install homebrew
	echo "Install Homebrew..."
	# send ENTER keystroke to install automatically
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# homebrew install failed
if ! which brew &> /dev/null; then
	echo "Homebrew failed to install!"
	exit 255
else
	brew doctor
	if [ "$?" != "0" ]; then
		echo "Something going wrong with Homebrew!"
		exit 255
	fi
fi

# Install all packages and applications
python brew-tap.py
python install.py brew
python install.py brew-cask
python install.py pip3

# Install applications from Mac App Store
if ! mas account &> /dev/null; then
	# sign in
	echo -n "Enter your Apple ID: "
	read APPLE_ID
	mas signin --dialog $APPLE_ID
fi
python install.py mas
