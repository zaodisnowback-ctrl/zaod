#!/usr/bin/env bash
# Zaod OS live ISO build (Debian bookworm + XFCE, lightweight, white theme)
# Needs root on a real Linux host or VM: live-build uses mount and /dev in the chroot.
# The script installs its own host dependencies and frees disk space, so it also works
# on a bare GitHub Actions runner.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${WORK:-/tmp/zaod-live-build}"
DIST="bookworm"
MIRROR="https://deb.debian.org/debian"
SEC="https://security.debian.org/debian-security"

log(){ printf '\n== %s ==\n' "$*"; }

log "Zaod OS build"
echo "repo: $REPO"
echo "work: $WORK"
echo "user: $(id -un)"

export DEBIAN_FRONTEND=noninteractive

# ---- host dependencies (no-op when already installed) ----
NEED=""
for pkg in live-build debootstrap xorriso squashfs-tools isolinux syslinux-common \
           syslinux-efi grub-efi-amd64-bin grub-pc-bin mtools dosfstools zstd; do
  dpkg -s "$pkg" >/dev/null 2>&1 || NEED="$NEED $pkg"
done
if [ -n "$NEED" ]; then
  log "installing host packages:$NEED"
  apt-get update -qq
  # shellcheck disable=SC2086
  apt-get install -y -qq --no-install-recommends $NEED
fi
command -v lb >/dev/null || { echo "live-build missing"; exit 1; }

# ---- free disk space (runner images ship several GB of unused toolchains) ----
for p in /usr/share/dotnet /usr/local/lib/android /opt/ghc \
         /opt/hostedtoolcache/CodeQL /usr/local/share/boost /usr/local/.ghcup \
         /usr/lib/jvm /usr/local/share/chromium; do
  if [ -d "$p" ]; then
    find "$p" -mindepth 1 -delete 2>/dev/null || true
  fi
done
apt-get clean || true
df -h / | tail -1

# ---- configure ----
if [ -d "$WORK" ]; then
  find "$WORK" -depth -mindepth 1 -delete 2>/dev/null || true
fi
mkdir -p "$WORK"
cd "$WORK"

log "lb config"
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

# ---- Zaod overlay: package list, hooks, boot splash, files ----
cp -a "$REPO/build/live-build/config/package-lists/." config/package-lists/
mkdir -p config/hooks/live config/bootloaders/syslinux config/includes.chroot
cp -a "$REPO/build/live-build/config/hooks/." config/hooks/live/
cp -a "$REPO/build/live-build/config/bootloaders/syslinux/." config/bootloaders/syslinux/
cp -a "$REPO/build/live-build/includes.chroot/." config/includes.chroot/

log "packages"
grep -hvE '^#|^$' config/package-lists/*.list.chroot | tr '\n' ' '; echo

log "lb build"
lb build 2>&1 | tee "$WORK/build.log"

ISO="$(find "$WORK" -maxdepth 1 -type f -name '*.iso' -print -quit || true)"
if [ -z "$ISO" ]; then
  echo "ERROR: no ISO produced"
  exit 1
fi
log "done"
echo "ISO: $ISO ($(du -h "$ISO" | cut -f1))"
sha256sum "$ISO" | tee "$ISO.sha256"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "iso_path=$ISO" >> "$GITHUB_OUTPUT"
fi
