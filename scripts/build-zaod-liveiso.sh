#!/usr/bin/env bash
# Zaod OS live ISO build (Debian bookworm + XFCE, lightweight, white theme)
# Run as root on a real Linux host or VM: live-build needs mount and /dev in the chroot.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-/mnt/zaod-build}"
DIST="bookworm"
MIRROR="https://deb.debian.org/debian"
SEC="https://security.debian.org/debian-security"

echo "== Zaod OS build =="
echo "repo: $REPO"
echo "work: $WORK"

command -v lb >/dev/null || { echo "live-build missing"; exit 1; }

if [ -d "$WORK" ]; then
  find "$WORK" -depth -mindepth 1 -delete 2>/dev/null || true
fi
mkdir -p "$WORK"
cd "$WORK"

lb config \
  --mode debian \
  --distribution "$DIST" \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloaders "syslinux,grub-efi" \
  --debian-installer false \
  --archive-areas "main contrib non-free non-free-firmware" \
  --apt-recommends false \
  --linux-flavours amd64 \
  --bootappend-live "boot=live components quiet splash username=user hostname=zaod locales=en_US.UTF-8 keyboard-layouts=us timezone=UTC" \
  --mirror-bootstrap "$MIRROR" --mirror-chroot "$MIRROR" --mirror-binary "$MIRROR" \
  --mirror-chroot-security "$SEC" --mirror-binary-security "$SEC" \
  --keyring-packages debian-archive-keyring

# Zaod overlay: package list, hooks, files
cp -a "$REPO/build/live-build/config/package-lists/." config/package-lists/
mkdir -p config/hooks/live
cp -a "$REPO/build/live-build/config/hooks/." config/hooks/live/
mkdir -p config/bootloaders/syslinux
cp -a "$REPO/build/live-build/config/bootloaders/syslinux/." config/bootloaders/syslinux/
mkdir -p config/includes.chroot
cp -a "$REPO/build/live-build/includes.chroot/." config/includes.chroot/

echo "== packages =="
grep -hvE '^#|^$' config/package-lists/*.list.chroot | tr '\n' ' '; echo

echo "== lb build =="
lb build 2>&1 | tee "$WORK/build.log"

ISO="$(find "$WORK" -maxdepth 1 -type f -name '*.iso' -print -quit || true)"
if [ -z "$ISO" ]; then
  echo "ERROR: no ISO produced"
  exit 1
fi
echo "ISO: $ISO ($(du -h "$ISO" | cut -f1))"
sha256sum "$ISO" | tee "$ISO.sha256"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "iso_path=$ISO" >> "$GITHUB_OUTPUT"
fi
