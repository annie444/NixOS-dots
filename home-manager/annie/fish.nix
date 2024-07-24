{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.fish;
in
{
  options.profiles.fish = {
    enable = mkEnableOption "enable fish profile";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      starship
      thefuck
      zoxide
      direnv
      neovim
    ]) ++ (with pkgs.fishPlugins; [
      fzf-fish
      gitnow
      z
      done
      autopair
      puffer
      github-copilot-cli-fish
      gitnow
    ]) ++ [
      {
        name = "spark";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "spark.fish";
          rev = "90a60573ec8a8ecb741a861e0bfca2362f297e5f";
          hash = "sha256-cRSZeqtXSaEKuHeTSk3Kpmwf98mKJ986x1KSxa/HggU=";
        };
      }
      {
        name = "getopts";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "getopts.fish";
          rev = "4b74206725c3e11d739675dc2bb84c77d893e901";
          hash = "sha256-9hRFBmjrCgIUNHuOJZvOufyLsfreJfkeS6XDcCPesvw=";
        };
      }
      {
        name = "fish-abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
          hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          hash = "sha256-Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
        };
      }
    ];
    programs = {
      fish = {
        enable = true;
        shellAbbrs = {
          du = "dust";
          g = "git";
          vim = "nvim";
          vi = "nvim";
          vimdiff = "nvim -d";
          gd = "batdiff";
          bathelp = "bat --plain --language=help $argv";
          ssh = "kitten ssh";
          note = "nvim -c ':ObsidianToday<CR>' $argv";
          trm = "trash-rm";
          tre = "trash-empty";
          trl = "trash-list";
          trc = "trash-clear";
          trr = "trash-restore";
          trp = "trash-put";
          ":q" = "exit";
        };
        shellAliases = {
          find = "bfs";
          diff = "nvim -d";
          ls = "eza -1GghmMoXr --color=always --icons=always -s created --group-directories-first --time-style long-iso --git --git-repos --hyperlink --show-symlinks -w 10";
          la = "eza -1GghmMoXrla --color=always --icons=always -s created --group-directories-first --time-style long-iso --git --git-repos --hyperlink --show-symlinks -w 100";
          cat = "bat";
          cd = "z";
          ".." = "z ..";
        };
        useBabelfish = true;
        vendor = {
          completions.enable = true;
          config.enable = true;
          functions.enable = true;
        };
        promptInit = ''
          starship init fish | source
        '';
        shellInit = ''
          set -U fish_term24bit 1
          zoxide init fish | source
          direnv hook fish | source
          set -U EDITOR nvim
          
          # Aliases
          fish_config theme choose "Dracula Official"
        
          set -gx GPG_TTY (tty)
          thefuck --alias | source
        
        
          if test "$(uname)" = "Darwin"
            alias apptainer "limactl shell apptainer"
          end
          set -gx fzf_preview_dir eza --all --color=always
          set -gx fzf_preview_file bat
          set -gx fzf_fd_opts --hidden
          set -gx fzf_diff_highlighter delta --paging=never --width=20
        
          if set -q KITTY_INSTALLATION_DIR
            source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
            set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
          end
        
          function help
            $argv --help 2>&1 | bathelp
          end
        
          set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
          set -gx MANROFFOPT "-c"
          set -gx BAT_THEME "Dracula"
          set -gx XDG_CONFIG_HOME "$HOME/.config"
          set -gx XDG_CACHE_HOME "$HOME/.cache"
          set -gx COLORTERM "truecolor"
          set -gx TERM "xterm-256color"
          set -gx EDITOR "nvim"
          
          if test -d "$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t"
            set -gx SSH_AUTH_SOCK "~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          else if test -d "$HOME/.1password"
            set -gx SSH_AUTH_SOCK "~/.1password/agent.sock"
          end
        
          if test -d "$HOME/.asdf"
            source ~/.asdf/asdf.fish
          end
        
          source ~/.config/op/plugins.sh
        '';

      } // optionalAttrs cfg.autosuggest { autosuggestions.enable = true; };
    };
    users.defaultUserShell = pkgs.zsh;
  };
}
