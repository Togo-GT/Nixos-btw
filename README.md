# Nixos-btw
Lenova i7

lspci | grep -i vga

lspci | grep -i nvidia

00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06)

01:00.0 3D controller: NVIDIA Corporation GM107M [GeForce GTX 960M] (rev a2)

sudo nixos-rebuild switch --show-trace 2>&1 | tee build_log.txt

sudo nixos-rebuild switch --show-trace 2>&1 | tee ~/nixos-rebuild.log

sudo nixos-rebuild test --show-trace  2>&1 | tee build_log.txt



