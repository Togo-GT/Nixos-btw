{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Infrastructure as Code
    ansible packer terraform
    
    # Containerization
    docker docker-compose podman
    
    # Programming Languages
    go nodejs perl python3 python3Packages.pip pipx rustup
    
    # Build Tools
    cmake gcc
  ];
}
