#!/usr/bin/env bash
set -euo pipefail

# Zaod OS live ISO build script
# This is a practical starter template for a Debian-based lightweight ISO.
# It creates a minimal live system intended for older x86 laptops.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/tmp/zaod-live-build"
DISTRO="noble"
ARCH="amd64"
MIRROR="http://archive.ubuntu.com/ubuntu"
SECURITY_MIRROR="http://security.ubuntu.com/ubuntu"

if ! command -v lb >/dev/null 2>&1; then
  echo "live-build is not installed. Install it with:"
  echo "sudo apt update && sudo apt install -y live-build xorriso syslinux squashfs-tools debootstrap ubuntu-keyring"
  exit 1
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

rm -rf ./*

lb clean || true

lb config \
  --distribution "$DISTRO" \
  --architectures "$ARCH" \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live config locales=en_US.UTF-8 keyboard-layouts=us timezone=UTC" \
  --archive-areas "main universe multiverse" \
  --apt-recommends false \
  --linux-flavours amd64 \
  --debian-installer false \
  --mirror-bootstrap "$MIRROR" \
  --mirror-chroot "$MIRROR" \
  --mirror-binary "$MIRROR" \
  --mirror-chroot-security "$SECURITY_MIRROR" \
  --mirror-binary-security "$SECURITY_MIRROR" \
  --security true

mkdir -p config/package-lists config/includes.chroot/etc config/includes.chroot/usr/local/share/zaod

cat > config/package-lists/zaod.list <<'EOF'
xfce4
xfce4-goodies
lightdm
task-xfce-desktop
firefox
chromium
vlc
network-manager
network-manager-gnome
sudo
curl
wget
git
python3
python3-venv
xserver-xorg
xinit
xterm
EOF

cat > config/includes.chroot/etc/hostname <<'EOF'
zaod
EOF

cat > config/includes.chroot/usr/local/share/zaod/README.txt <<'EOF'
Zaod OS
Lightweight white-themed desktop for older laptops.
Target: 2GB RAM minimum, 8GB storage minimum, Intel/AMD integrated graphics.
EOF

mkdir -p config/hooks
cat > config/hooks/zaod-theme.hook <<'EOF'
#!/bin/bash
set -e
# Minimal system hook to prepare a lightweight desktop environment.
# This is a starter hook for customization and theming.
# Add customizations here for branding, wallpapers, and launcher setup.
EOF
chmod +x config/hooks/zaod-theme.hook

lb build

echo "ISO build complete. Check the output directory for the resulting .iso file."
