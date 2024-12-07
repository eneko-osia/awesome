#
# ~/.bash_aliases
#

# ls
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias pacman-unused='sudo pacman -Qdtq'
alias pacman-clean='sudo pacman -Rsn $(pacman -Qdtq)'
