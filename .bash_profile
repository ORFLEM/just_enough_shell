# ~/.bash_profile
# The personal initialization file, executed for login shells.

# Source the aliases and functions.
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# Define user specific environment and startup programs.

BASH_ENV=$HOME/.bashrc
export BASH_ENV 
    [[ -z "$TMUX" && -z "$SSH_TTY" && $- == *i* ]] && cd ~
