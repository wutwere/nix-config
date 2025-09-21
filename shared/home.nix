{
  pkgs,
  dotfiles,
  ...
}: {
  home.file = {
    ".config/nvim" = {
      source = dotfiles + "/nvim/.config/nvim";
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    (callPackage ./wally-package-types {})

    cava
    nerdfetch
    delta
    bat
    gemini-cli
    stow
    rojo
    lua
    luau
    luau-lsp
    fd
    go
    lazygit
    nodejs_24
    alejandra
    stylua
    selene
    lua-language-server
    gopls
    nixd
    gcc
    tree-sitter

    btop # replacement of htop/nmon

    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    neofetch
    yazi # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "wutwere";
    userEmail = "62412610+wutwere@users.noreply.github.com";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      cd = "z";
      v = "nvim";
      lg = "lazygit";
      ls = "eza";
      l = "eza -al";
    };
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = tmuxPlugins.session-wizard;
        extraConfig = ''
          set -g @session-wizard 'f'
          set -g @session-wizard-height 50
          set -g @session-wizard-width 50
        '';
      }
      (tmuxPlugins.rose-pine.overrideAttrs (
        _: {
          src = pkgs.fetchFromGitHub {
            owner = "wutwere";
            repo = "rose-pine-tmux";
            rev = "ac44508cbc78824ac66288c0b8248f14a883dd15";
            sha256 = "sha256-xvZ6FxMWQDjaqswWJdoRAAuObqRNlU5+KCNvkj94buw=";
          };
        }
      ))
    ];
    extraConfig = ''
      set-option -g terminal-overrides ',xterm-256color:RGB'

      set -g prefix C-Space
      set -g base-index 1              # start indexing windows at 1 instead of 0
      set -g detach-on-destroy off     # don't exit from tmux when closing a session
      set -g escape-time 0             # zero-out escape time delay
      set -g history-limit 50000       # increase history size (from 2,000)
      set -g renumber-windows on       # renumber all windows when any window is closed
      set -g set-clipboard on          # use system clipboard
      set -g status-position top       # macOS / darwin style
      set -g mouse on
      set -g repeat-time 0
      set -g mode-style "fg=black,bg=white"
      set -gu default-command
      set -g default-shell "$SHELL"

      # only show status bar if there is more than one window
      set -g status off
      set-hook -g after-new-window      'if "[ #{session_windows} -gt 1 ]" "set status on"'
      set-hook -g pane-focus-out        'if "[ #{session_windows} -lt 2 ]" "set status off"'
      set-hook -g pane-focus-in         'if "[ #{session_windows} -lt 2 ]" "set status off"'

      setw -g mode-keys vi

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      bind -r H split-window -hb
      bind -r J split-window -v
      bind -r K split-window -vb
      bind -r L split-window -h

      bind -r b switch-client -l

      bind -r x kill-pane
      bind -r w kill-window
      bind -r t new-window
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
