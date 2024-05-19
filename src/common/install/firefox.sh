#!/usr/bin/env bash
set -e

echo \
    "deb http://deb.debian.org/debian/ unstable main contrib non-free" >> \
    /etc/apt/sources.list
cat > /etc/apt/preferences.d/99pin-unstable <<EOF
Package: *
Pin: release a=stable
Pin-Priority: 900

Package: *
Pin: release a=unstable
Pin-Priority: 10
EOF

apt-get update
apt-get install -y -t unstable firefox

# VERSION="102.3.0esr"
# echo "Install Firefox $VERSION"

# FF_INST='/usr/lib/firefox'

# echo "download Firefox $FF_VERS and install it to '$FF_INST'."
# mkdir -p "$FF_INST"
# FF_URL=http://releases.mozilla.org/pub/firefox/releases/$FF_VERS/linux-x86_64/en-US/firefox-$FF_VERS.tar.bz2
# echo "FF_URL: $FF_URL"
# wget -qO- $FF_URL | tar xvj --strip 1 -C $FF_INST/
# ln -s "$FF_INST/firefox" /usr/bin/firefox