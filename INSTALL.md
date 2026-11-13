# Fresh Arch Linux install — mini PC

Target: AMD Ryzen 7 + Radeon graphics, 32 GB RAM, one Arch SSD, wired Ethernet,
single boot now (Windows later on a second SSD), no encryption.

## Recommended layout

| Partition | Size | GPT type | Filesystem | Mount |
|---|---|---|---|---|
| 1 | **1 GiB** | `ef00` (EFI) | FAT32 | `/boot` |
| 2 | **rest** | `8300` (Linux) | ext4 | `/` |

- **ext4** on a single root; no separate `/home`.
- **No swap partition** — use zram (32 GB RAM does not need disk swap for normal use).
- **No LUKS** — encryption is not required for a home mini PC. If the machine
  lives somewhere untrusted, reinstall with LUKS2 on root and an unencrypted
  `/boot`; GRUB needs `cryptsetup luksFormat --pbkdf pbkdf2`.
- **GRUB UEFI** — matches the dotfiles and handles the later Windows SSD with
  `os-prober`.
- **1 GiB ESP** — two kernels + initramfs + microcode fit comfortably.
- **Windows later on the second SSD** — let Windows create its own ESP. Do not
  share or wipe this ESP. Select the OS from the firmware boot menu, or chainload
  Windows from GRUB with `os-prober`.

## 1. USB

Download the Arch ISO, verify it against `sha256sums.txt` / the GPG signature,
then write it to a USB stick:

```bash
sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

`/dev/sdX` is the whole USB device, not a partition. Ventoy works too.

## 2. Boot the installer

- UEFI mode, Secure Boot disabled.
- Wired Ethernet connected.
- `timedatectl set-ntp true`.
- Identify the target disk, and make sure you do **not** touch the SSD reserved
  for Windows:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS
```

The examples below use `/dev/nvme0n1`; replace it with the real Arch SSD.

## 3. Partition and format

```bash
sgdisk --zap-all /dev/nvme0n1
sgdisk --new=1:0:+1G --typecode=1:ef00 --change-name=1:EFI  /dev/nvme0n1
sgdisk --new=2:0:0   --typecode=2:8300 --change-name=2:root /dev/nvme0n1
partprobe /dev/nvme0n1

mkfs.fat -F32 -n EFI /dev/nvme0n1p1
mkfs.ext4 -L root /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

## 4. Base system

```bash
pacstrap -K /mnt \
  base base-devel linux linux-firmware \
  linux-lts linux-lts-headers linux-headers \
  amd-ucode grub efibootmgr networkmanager sudo git nano \
  mesa vulkan-radeon vulkan-icd-loader libva-mesa-driver \
  zram-generator
```

Why these extras:

- `amd-ucode` — CPU microcode must be installed before `grub-mkconfig`.
- `vulkan-radeon` + `vulkan-icd-loader` — Vulkan for voxtype on the Radeon iGPU.
- `libva-mesa-driver` — VA-API hardware video decode.
- `zram-generator` — compressed RAM swap.
- `linux-headers` — out-of-tree modules/DKMS for the non-LTS kernel.

## 5. fstab and chroot

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

## 6. System configuration

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Uncomment en_US.UTF-8 in /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo 'minibox' > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
::1 localhost
127.0.1.1 minibox.localdomain minibox
EOF

passwd
useradd -m -G wheel -s /bin/bash alpha
passwd alpha
EDITOR=nano visudo    # uncomment: %wheel ALL=(ALL:ALL) ALL
```

Use user `alpha`: the Brain_Shell keybinds and one systemd symlink hardcode
`/home/alpha`.

Hostname is `minibox` for the mini PC (the laptop stays `archbox`). If both
machines share a LAN, you now have two distinct hostnames, which avoids
mDNS/NetBIOS collisions.

## 7. zram

Create `/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

With 32 GB RAM this gives a 16 GB compressed swap device. If you prefer a fixed
size, use `zram-size = 8192` for 8 GiB. No swapfile is created, so hibernation
is not configured.

## 8. initramfs and bootloader

```bash
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
```

Optional: add `amd_pstate=active` to `GRUB_CMDLINE_LINUX_DEFAULT` in
`/etc/default/grub` before `grub-mkconfig` for better Ryzen power management.

Secure Boot is left disabled. No encryption is configured.

## 9. Reboot

```bash
exit
umount -R /mnt
reboot
```

Remove the USB.

## 10. Dotfiles

```bash
# Wired network should already be up via NetworkManager.
# Use nmtui only if needed.

git clone https://github.com/AlphaAlchiba/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles
MIRROR_COUNTRY=DE ./install.sh
```

`install.sh` installs the full package list, stows the configs, clones
Brain_Shell, enables the user services, and sets the login shell to zsh.

Then configure the graphical login:

```bash
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1
[default_session]
command = "tuigreet --cmd start-hyprland --remember --remember-user-session"
user = "alpha"
EOF
sudo systemctl enable greetd
```

Enable the system services and groups:

```bash
sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now docker firewalld libvirtd mullvad-daemon
sudo usermod -aG docker,libvirt alpha
sudo firewall-cmd --set-default-zone=home
```

Log out/in (or reboot) after the group change.

## 11. AMD / voxtype

The tracked `config/voxtype/config.toml` uses `gpu_device = 1` (the laptop's
NVIDIA dGPU). On the mini PC, set it to `0` for the Radeon iGPU:

```bash
nvim ~/.config/voxtype/config.toml   # gpu_device = 0
```

Because `~/.config/voxtype` is a symlink into the repo, this shows as a local
modification. Either commit `gpu_device = 0` if the mini PC is the primary
machine, or keep the change local. Do not set `1` here — there is no dGPU.

`vulkan-radeon` and `vulkan-icd-loader` are installed in the base step, so
voxtype can use Vulkan.

## 12. Monitor configuration

The tracked `config/hypr/modules/monitors.lua` is generic and handles any
display through the catch-all. For a specific mode, scale, position, or
workspace layout:

```bash
cp ~/.config/hypr/modules/monitors_local.lua.example \
   ~/.config/hypr/modules/monitors_local.lua
hyprctl monitors          # copy the description: line, prefix with desc:
# edit the file, then:
hyprctl reload
```

`monitors_local.lua` is gitignored and stays on this machine.
See `config/hypr/README.md` for the full monitor/workspace guide.

## 13. Non-pacman tools and secrets

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
curl --proto '=https' -sSf https://sh.rustup.rs | sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
curl -fsSL https://opencode.ai/install.sh | sh
cargo install tuxedo
uv tool install --with psycopg2-binary sqlit-tui
```

Install `uv` and `rustup` before opening a new shell. Recreate
`~/.opencode-secrets` (`CONTEXT7_API_KEY`, `BRAVE_API_KEY`, and the GCP project
ids if you use the Gemini aliases), restore SSH/GPG/pass, and copy wallpapers
to `~/Pictures/Wallpapers`.

## 14. Verify

```bash
cd ~/dotfiles
just check
just doctor
```

Open nvim and run:

```vim
:lua vim.pack.update()
```

Then reboot and confirm greetd → tuigreet → Hyprland.

## 15. Dual boot later (Windows on the second SSD)

- Install Windows on the second SSD. It will create its own ESP.
- Do not share or format the Arch ESP.
- Select the OS from the firmware boot menu, or let GRUB detect Windows:

```bash
sudo pacman -S os-prober
echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Set the preferred boot order with `efibootmgr` or the firmware setup. Disable
Windows Fast Startup and handle BitLocker recovery before/after the install.

## 16. Optional

- `lm_sensors` for temperature monitoring.
- `fwupd` for firmware updates.
- `power-profiles-daemon` if you want power profiles.
- Trim `packages/official.txt` if you do not need `freecad`, `darktable`,
  `docker`, `libvirt`, `mullvad-vpn`, `spotify`, `zen-browser`, or
  `auto-cpufreq` on the mini PC.
- `archinstall` is an alternative to this manual guide: choose the **Minimal**
  profile, manual partitioning, ext4, GRUB, NetworkManager, user `alpha`, and
  **no desktop profile or display manager**. Then run the dotfiles steps above.
