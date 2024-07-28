{
  description = "my minimal flake";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11

    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim nightly overlay
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in {
    darwinConfigurations.Zihans-MacBook-Pro = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
      };
      modules = [
        ({ pkgs, ... }: {
          # here go the darwin preferences and config items
nixpkgs.overlays = overlays;
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          programs.zsh.enable = true;
          environment = {
            shells = [ pkgs.bash pkgs.zsh ];
            loginShell = pkgs.zsh;
            systemPackages = [ pkgs.coreutils ];
            systemPath = [ "/opt/homebrew/bin" ];
            pathsToLink = [ "/Applications" ];
          };

          fonts = {
            fontDir.enable = true;
            fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; }) ];
          };

          services.nix-daemon.enable = true;
          system = {
            keyboard = {
              enableKeyMapping = true;
              remapCapsLockToEscape = true;
            };
            defaults = {
              finder = {
                AppleShowAllExtensions = true;
                _FXShowPosixPathInTitle = true;
                ShowPathbar = true;
              };
              dock = {
                autohide = true;
                show-recents = false;
              };
              NSGlobalDomain = {
                AppleShowAllExtensions = true;
                InitialKeyRepeat = 14;
                KeyRepeat = 1;
              };
            };
            # backwards compat; don't change
            stateVersion = 4;
          };
          users.users.zihanjin = {
            name = "zihanjin";
            home = "/Users/zihanjin";
          };

          homebrew = {
            enable = true;
            caskArgs.no_quarantine = true;
            global.brewfile = true;
            brews = [ "gh" "composer" "pngpaste" ];
          };
        })
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.zihanjin.imports = [
              ({ pkgs, ... }: {
                # Don't change this when you change package input. Leave it alone.
                home = {
                  stateVersion = "22.11";
                  # specify my home-manager configs
                  packages = [
                    pkgs.ripgrep
                    pkgs.fd
                    pkgs.curl
                    pkgs.less
                    pkgs.zoxide
                    pkgs.cargo
                    pkgs.nixpkgs-fmt
                    pkgs.lazygit
                    pkgs.python312
                    pkgs.nodejs_21
                    pkgs.go_1_22
                    pkgs.jq
                    pkgs.bun
                    pkgs.php
                    pkgs.imagemagick
                  ];
                  sessionVariables = {
                    PAGER = "less";
                    CLICLOLOR = 1;
                    EDITOR = "nvim";
                    GOPATH = "$HOME/go";
                  };
                };

                programs = {
                  tmux = {
                    enable = true;
                    prefix = "C-Space";
                    terminal = "screen-256color";
                    mouse = true;
                    newSession = true;
                    keyMode = "vi";
                    sensibleOnTop = true;
                    shell = "/bin/zsh";
                    plugins = [
                    pkgs.tmuxPlugins.yank
                    pkgs.tmuxPlugins.vim-tmux-navigator
                    pkgs.tmuxPlugins.catppuccin
                    ];
                    extraConfig = builtins.readFile ./config/tmux/tmux.conf;
                  };
                  bat = {
                    enable = true;
                    config.theme = "TwoDark";
                  };
                  fzf = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  eza = {
                    enable = true;
                    enableAliases = true;
                    icons = true;
                    git = true;
                  };
                  git = {
                    enable = true;
                    userName = "Zihan Jin";
                    userEmail = "admin@zihanjin.com";
                  };
                  zsh = {
                    enable = true;
                    enableCompletion = true;
                    enableAutosuggestions = true;
                    enableSyntaxHighlighting = true;
                    # shellAliases = {ls = "ls --color=auto -F";};
                    shellAliases = {
                      c = "clear";
                      t = "touch";
                      q = "exit";
                      cd = "z";
                      lg = "lazygit";
                      tm = "tmux";
                      img = "wezterm imgcat";
                    };
                  };
                  starship = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  alacritty = {
                    enable = true;
                    settings.font.normal.family = "MesloLGS Nerd Font Mono";
                    settings.font.size = 16;
                    settings.import =  [
                      "~/.config/alacritty/themes/themes/catppuccin_mocha.toml"
                    ];
                  };
                  neovim = {
                    enable = true;
                    extraLuaPackages = luaPkgs: with luaPkgs; [ magick ];
                    extraPackages =  [ pkgs.imagemagick ];
                    extraLuaConfig = builtins.readFile ./config/nvim/init.lua;
                    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
                    defaultEditor = true;
                    viAlias = true;
                    vimAlias = true;
                    vimdiffAlias = true;
                  };

                  wezterm = {
                    enable = true;
                    enableZshIntegration = true;
                    enableBashIntegration = true;
                    extraConfig = builtins.readFile ./config/wezterm/wezterm.lua;
                  };

                  zoxide = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                };

                home.file.".inputrc".text = ''
                  set show-all-if-ambiguous on
                  set completion-ignore-case on
                  set mark-directories on
                  set mark-symlinked-directories on
                  set match-hidden-files off
                  set visible-stats on
                  set keymap vi
                  set editing-mode vi-insert
                '';

                home.sessionPath = ["$HOME/go/bin" "$HOME/.composer/vendor/bin"];
              })
            ];
          };
        }
      ];
    };
  };
}
