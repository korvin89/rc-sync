# ===== bashrc-sync prompt (bash + zsh) =====

if [ -n "${ZSH_VERSION:-}" ]; then
  # ---------- ZSH ----------
  autoload -Uz vcs_info
  setopt PROMPT_SUBST
  zstyle ':vcs_info:git:*' enable git
  zstyle ':vcs_info:git:*' formats '(%b)'
  zstyle ':vcs_info:*' enable git
  precmd() { vcs_info }

  # %n = username, %~ = path with ~ ; colors: %F{blue} ... %f
  PROMPT='%n  %F{blue}%~%f%F{green}${vcs_info_msg_0_}%f '
else
  # ---------- BASH ----------
  # Colors with \[ \] so bash counts width correctly
  RESET="\[\e[0m\]"
  BLUE="\[\e[34m\]"
  GREEN="\[\e[32m\]"

  _prompt_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return 0
    local b
    b="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)" || return 0
    printf '(%s)' "$b"
  }

  PS1='\u  '"$BLUE"'\w'"$RESET$GREEN"'$(_prompt_git_branch)'"$RESET"' '
fi

# ===== /bashrc-sync prompt =====
