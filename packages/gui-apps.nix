{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Browsers & Communication
    chromium firefox signal-desktop telegram-desktop thunderbird
    
    # Multimedia
    audacity handbrake mpv spotify vlc
    
    # Graphics & Design
    gimp inkscape krita kdePackages.okular zathura
  ];
}
