#!/usr/bin/env bash

########
# Path #
########

# Add brew paths
PATH="/usr/local/bin:$PATH"

# Include user specific binaries
export PATH="${HOME}/bin:${PATH}"

###########
# Aliases #
###########

# OS X 12 (Sierra) and later
alias cleardns="sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | copy && echo '=> Public key copied to pasteboard.'"

# Git
alias g="git"

# Network IP for development
alias ip='ifconfig | grep broadcast | cut -d" " -f2'

# Change mac address
alias freewifi="sudo ifconfig en0 ether `openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'`"

alias show='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hide='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

alias pro="cd ~/projects/work"
alias per="cd ~/projects/personal"

#############
# Functions #
#############


#Enter directory and list files
c() {
  cd "$@" && l
}

# Create a new directory and enter it
mkd() {
  mkdir -p "$@" && cd "$_"
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
targz() {
  local tmpFile="${@%/}.tar"
  tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1

  size=$(
    stat -f"%z" "${tmpFile}" 2> /dev/null # OS X `stat`
    stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
  )

  local cmd=""
  if (( size < 52428800 )) && hash zopfli 2> /dev/null
  then
    # the .tar file is smaller than 50 MB and Zopfli is available; use it
    cmd="zopfli"
  else
    if hash pigz 2> /dev/null
    then
      cmd="pigz"
    else
      cmd="gzip"
    fi
  fi

  echo "Compressing .tar using \`${cmd}\`…"
  "${cmd}" -v "${tmpFile}" || return 1
  [ -f "${tmpFile}" ] && rm "${tmpFile}"
  echo "${tmpFile}.gz created successfully."
}

# Determine size of a file or total size of a directory
fs() {
  if du -b /dev/null > /dev/null 2>&1
  then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]
  then
    du $arg -- "$@"
  else
    du $arg .[^.]* *
  fi
}

# Create a data URL from a file
dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ ${mimeType} == text/* ]]
  then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Compare original and gzipped file size
gz() {
  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "${gzipsize} * 100 / ${origsize}" | bc -l)
  printf "orig: %d bytes\n" "${origsize}"
  printf "gzip: %d bytes (%2.2f%%)\n" "${gzipsize}" "${ratio}"
}


# opens the given location
o() {
  if [ "$1" = "" ]
  then
    open .
  else
    open "$1"
  fi
}

###########
# General #
###########

# Stop password from promting
ssh-add -K >/dev/null 2>&1

# Load rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if type pyenv > /dev/null; then
  eval "$(pyenv init -)"
fi

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
