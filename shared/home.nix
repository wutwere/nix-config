{
  pkgs,
  dotfiles,
  ...
}: {
  home.file = {
    ".config/nvim" = {
      source = dotfiles + "/nvim/.config/nvim";
    };
    ".config/nixpkgs/config.nix".text = ''
      {
        allowUnfree = true;
      }
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    selene
    stylua
    lua-language-server
    luau
    luau-lsp
    rojo
    (
      pkgs.rustPlatform.buildRustPackage rec {
        pname = "wally-package-types";
        version = "1.6.2";

        src = pkgs.fetchFromGitHub {
          owner = "JohnnyMorganz";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-ynd5z2pbhGnPTKuJQG4EJL/Zy/X9lTCjSi8Cd6nRSsA=";
        };

        cargoHash = "sha256-LjtnArnv46GzbHnpT3wFNrjCv78stfFc6Kx9RefK+U8=";

        doCheck = false;
      }
    )

    (python3.withPackages (ps: with ps; [pwntools cryptography]))
    pyright
    ruff

    nodejs_24
    vtsls
    vscode-json-languageserver

    rust-analyzer
    rustc
    cargo
    clippy
    # cargo-cross

    go
    gopls

    gcc
    clang-tools

    # frida-tools

    # cava # new update broken on mac
    nerdfetch
    fastfetch
    bat

    fd

    alejandra
    nixd

    tree-sitter

    btop

    nix-your-shell
    zsh-abbr
    gawk

    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

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

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings.user = {
      name = "wutwere";
      email = "62412610+wutwere@users.noreply.github.com";
      pull.rebase = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    history = {
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    initContent = ''
      # Nix-your-shell for seamless shell integration in nix-shell/nix develop
      if command -v nix-your-shell > /dev/null; then
        nix-your-shell zsh | source /dev/stdin
      fi

      # Source zsh-abbr for Fish-like abbreviations
      export ABBR_QUIET=1
      export ABBR_QUIETER=1
      source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh

      # Abbreviations (expand on space)
      abbr --force cd=z > /dev/null 2>&1
      abbr --force v=nvim > /dev/null 2>&1
      abbr --force ls='eza --icons --group-directories-first' > /dev/null 2>&1
      abbr --force l='eza -al --icons --group-directories-first' > /dev/null 2>&1

      # zsh-vi-mode
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      function zvm_after_init() {
        zvm_bindkey viins '^R' fzf-history-widget
      }
    '';
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
      {
        plugin = tmuxPlugins.tmux-thumbs;
        extraConfig = ''
          set -g @thumbs-unique enabled
          set -g @thumbs-command 'echo -n {} | tmux load-buffer -w -'
        '';
      }
      (tmuxPlugins.rose-pine.overrideAttrs (
        _: {
          src = pkgs.fetchFromGitHub {
            owner = "wutwere";
            repo = "rose-pine-tmux";
            rev = "763baa023e4ef771d640cda3ea45bcfc8e4bebf3";
            sha256 = "sha256-dir5K6fLSbxiBN7NTaURm3TJYD/koFOvjMEsVNpfVEA";
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
      set -g status-position bottom    # macOS / darwin style
      set -g mouse on
      set -g repeat-time 0
      set -g mode-style "fg=black,bg=white"
      set -g status-justify centre
      set -g popup-border-style "fg=red"
      set -g popup-border-lines "rounded"
      set -g default-shell "$SHELL"

      setw -g mode-keys vi

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "tmux load-buffer -w -"

      # scroll one line instead of chunks
      bind -T copy-mode-vi WheelUpPane send-keys -X scroll-up
      bind -T copy-mode-vi WheelDownPane send-keys -X scroll-down

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

      bind -r U 'copy-mode; send-keys -X halfpage-up'
      bind -r D 'copy-mode; send-keys -X halfpage-down'
    '';
  };

  programs.zoxide = {
    enable = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      mgr = {
        show_hidden = true;
        ratio = [1 3 4];
        linemode = "size_and_mtime";
      };
      preview = {
        max_width = 4000;
        max_height = 4000;
      };
    };
    plugins = {
      starship = pkgs.yaziPlugins.starship;
    };
    initLua = ''
      -- ~/.config/yazi/init.lua
      function Linemode:size_and_mtime()
      	local time = math.floor(self._file.cha.mtime or 0)
      	if time == 0 then
      		time = ""
      	elseif os.date("%Y", time) == os.date("%Y") then
      		time = os.date("%b %d %H:%M", time)
      	else
      		time = os.date("%b %d  %Y", time)
      	end

      	local size = self._file:size()
      	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
      end
      require("starship"):setup()
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gemini-cli = {
    enable = true;
    settings = {
      security = {
        auth = {
          selectedType = "oauth-personal";
        };
      };
      general = {
        previewFeatures = true;
      };
      mcpServers = {
        nixos = {
          command = "nix";
          args = ["run" "github:utensils/mcp-nixos" "--"];
        };
      };
    };
  };
}
