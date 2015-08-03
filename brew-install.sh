#!/usr/bin/env bash
#
# brew-install.sh
# Copyright (C) 2013 KuoE0 <kuoe0.tw@gmail.com>
#
# Distributed under terms of the MIT license.

set -x

function get-package-name {
	echo -e "$1" | cut -d':' -f1 | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
}

function get-parameters {
	CNT=$(echo -e "$1" | grep -o ':' | wc -l)
	if (( $CNT == 1 )); then
		echo -e "$1" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
	fi
}

function tolower {
	echo $1 | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

# create temporal directory & log directory
TMP_DIR=/tmp/BREW-$(date +%Y%m%d-%H%M%S)
LOGDIR="$TMP_DIR/log"
IFS=$'\n'

if [ -d $TMP_DIR ] || [ -f $TMP_DIR ]; then
	rm -r $TMP_DIR
fi
mkdir -p $TMP_DIR
mkdir -p $LOGDIR

# brew does not exist
if ! which brew &> /dev/null; then
	# remove homebrew directory /usr/local/Cellar
	if [ -d /usr/local/Cellar ] || [ -f /usr/local/Cellar ]; then
		rm -rf /usr/local/Cellar
	fi

	# remove homebrew directory /usr/local/.git
	if [ -d /usr/local/.git ] || [ -f /usr/local/.git ]; then
		rm -rf /usr/local/.git
	fi

	# install homebrew
	echo "Install Homebrew..."
	# send ENTER keystroke to install automatically
	echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

fi

# homebrew install failed
if ! which brew &> /dev/null; then
	echo "Homebrew install failed!"
	exit 255
fi

# add taps to homebrew
tap_list=(caskroom/cask caskroom/versions caskroom/fonts homebrew/dupes homebrew/science homebrew/versions)

for TAP_NAME in ${tap_list[*]}; do
	echo "Add tap $TAP_NAME to Homebrew..."
	brew tap $TAP_NAME
done


# brew status check
echo "Diagnose Homebrew..."
brew doctor 2>&1 | tee "$LOGDIR/brew-doctor.log"

# install packages and applications
if [ "$?" = "0" ]; then

	# use llvm to build
	brew --env --use-llvm

	# update brew database
	brew update

	# install & upgrade brew-cask
	brew install brew-cask
	brew upgrade brew-cask

	# install applications from homebrew-cask
	# Install from homebrew-cask first, because there are some package need XQuartz
	while read APP; do
		echo "Installing $APP..."
		PKG=$(tolower $APP)
		brew cask install "$PKG" --appdir=/Applications 2>&1 | tee "$LOGDIR/$PKG.log"
	done < brew-cask.list

	# install packages from homebrew
	while read LINE; do
		PKG=$(get-package-name "$LINE")
		PARAM=$(get-parameters "$LINE")
		echo "PKG:   \"$PKG\""
		echo "PARAM: \"$PARAM\""
		bash -c "brew install $PKG $PARAM 2>&1 | tee $LOGDIR/$PKG.log"
	done < brew.list
fi

