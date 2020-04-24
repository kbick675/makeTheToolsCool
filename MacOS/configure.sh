#!/bin/bash
set -eou pipefail

source ../scripts/prompt

brewInstall () {
    if test ! $(which brew); then
        if test "$(uname)" = "Darwin"; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            success 'brew installed'
        else
            info "Homebrew is for MacOS, not whatever mess you're running this on."
        fi
    else
        info 'brew is already installed'
    fi
}

brewUpdate () {
    brew update
    success 'brew updated'
}

zshInstall () {
    if test $(which zsh); then
        info "zsh already installed..."
    else
        brew install zsh zsh-completions
        success 'zsh and zsh-completions installed'
    fi
}

zshZInstall () {
    if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-z" ]; then
        info "zsh-z already exists..."
    else
        git clone https://github.com/agkozak/zsh-z ~/.oh-my-zsh/custom/plugins/zsh-z
        success 'zsh-z installed'
    fi
}

configureGitCompletion () {
    GIT_VERSION="$(git --version | awk '{ print $3 }')"
    URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
    success "git-completion for $GIT_VERSION downloaded"
    if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
        echo "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
        fail 'git completion download failed'
    fi
}

pl9kInstall () {
    PLPATH="/usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme"
    SRCSTRING="source $PLPATH"
    ZSHRC="~/.zshrc"
    if test -f "$PLPATH"; then
        info "powerlevel9k package is installed..."
        if grep -q "source $PLPATH" ~/.zshrc; then
            info "zsh is configured to use powerlevel9k..."
        else
            echo "source $PLPATH" >> ~/.zshrc
        fi
    else
        brew install powerlevel9k
        pl9kInstall
    fi
}

fontsInstall () {
    FILES=../Fonts/*.ttf
    info "Installing fonts..."
    for filename in ../Fonts/*.ttf; do
        if test -f ~/Library/Fonts/"$filename"; then
            info "$filename is already in the Fonts directory..."
        else
            cp "$filename" ~/Library/Fonts
            success "$filename successfully copied to the Fonts directory..."
        fi
    done
}

#Install Packages
brewInstall
brewUpdate
zshInstall
zshZInstall
pl9kInstall

#Install Fonts
fontsInstall