#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

PS1='[\u@\h \W]\$ '
