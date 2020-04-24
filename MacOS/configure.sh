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

brewBundleInstall () {
    echo "Do you wish to use the included Brewfile?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) brew bundle; break;;
            No ) break;;
        esac
    done
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
    URL="https://github.com/git/git/blob/master/contrib/completion/git-completion.bash"
    if ! test -f ~/.git-completion.bash; then\
        if ! curl "$URL" --silent --output ~/.git-completion.bash; then
            echo "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
            fail 'git-completion download failed'
        else
            success "git-completion downloaded"
        fi
    else
        info "git-completion already installed..."
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

info "--Setup started--"
#Install Packages
brewInstall
brewUpdate
brewBundleInstall
zshInstall
zshZInstall
configureGitCompletion
pl9kInstall

#Install Fonts
fontsInstall

info "--Setup complete--"