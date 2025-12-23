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

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # (python3.withPackages (ps: with ps; [pwntools cryptography]))
    # pyright

    # nodejs_24

    # rust-analyzer
    # rustc
    # cargo
    # clippy
    # cargo-cross

    # go
    # gopls

    # frida-tools

    # cava # new update broken on mac
    nerdfetch
    fastfetch
    bat

    fd

    alejandra
    nixd

    gcc
    clang-tools

    tree-sitter

    btop

    blesh
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
    enableBashIntegration = true;
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
    enableBashIntegration = false;
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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Source ble.sh for syntax highlighting, autosuggestions, and more
      if [[ $- == *i* ]]; then
        source ${pkgs.blesh}/share/blesh/ble.sh --noattach
      fi

      # ble-sabbrev provides Fish-like abbreviations that expand on space
      if [[ ''${_ble_version-} ]]; then
        # Enable history sharing (equivalent to fish behavior)
        bleopt history_share=1

        # Increase auto-complete delay to avoid lag
        bleopt complete_auto_delay=200

        ble-sabbrev cd=z
        ble-sabbrev v=nvim
        ble-sabbrev ls='eza --icons --group-directories-first'
        ble-sabbrev l='eza -al --icons --group-directories-first'

        # Initialize Starship (must be done AFTER ble.sh)
        eval "$(starship init bash)"

        # Initialize zoxide
        eval "$(zoxide init bash)"
        ble-import -f integration/zoxide

        # Use ble.sh's native FZF integration (standard fzf-key-bindings are incompatible)
        ble-import integration/fzf-completion
        ble-import integration/fzf-key-bindings

        # Custom widget to expand abbreviations on Enter
        function ble/widget/project/accept-line {
          ble/widget/sabbrev-expand
          ble/widget/accept-line
        }
        ble-bind -f 'RET' 'project/accept-line'
        ble-bind -f 'C-m' 'project/accept-line'

        # Disable visual bell (no white line/flash)
        bleopt edit_vbell=
        # Remove white background from autocomplete ghost text
        ble-face -s auto_complete fg=242,bg=none
        ble-face -s vbell_erase bg=none

        # Attach ble.sh
        ble-attach
      fi
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
      set -g default-shell "$SHELL"

      setw -g mode-keys vi

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

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
    enableBashIntegration = true;
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
    enableBashIntegration = false;
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
