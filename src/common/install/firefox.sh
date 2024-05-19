#!/usr/bin/env bash
set -e

FF_VERS="126.0"
echo "Install Firefox $FF_VERS"

FF_INST='/usr/lib/firefox'

echo "download Firefox $FF_VERS and install it to '$FF_INST'."
mkdir -p "$FF_INST"
FF_URL=http://releases.mozilla.org/pub/firefox/releases/$FF_VERS/linux-x86_64/en-US/firefox-$FF_VERS.tar.bz2
echo "FF_URL: $FF_URL"
wget -qO- $FF_URL | tar xvj --strip 1 -C $FF_INST/
ln -s "$FF_INST/firefox" /usr/bin/firefox