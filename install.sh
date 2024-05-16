#!/bin/sh

REPO_URL="https://github.com/txya900619/dotfiles"
REPO_NAME="dotfiles"

INSTALL_DIRECTORY=${INSTALL_DIRECTORY:-"$HOME/.$REPO_NAME"}
INSTALL_VERSION=${INSTALL_VERSION:-"master"}

askquestion() {
	printf "$1 [y/N] "

	read ans
	case $ans in
	[Yy*])
		return $(true)
		;;
	*)
		return $(false)
		;;
	esac
}

applyzsh() {
	# Check zsh
	if ! command -v zsh >/dev/null 2>&1; then
		echo "zsh is not installed."
		return $(false)
	fi

	if [ -f $HOME/.zshrc ]; then
		mv $HOME/.zshrc $HOME/.zshrc.bak
	fi

	# Install z4h
	if command -v curl >/dev/null 2>&1; then
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
	else
		sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
	fi

	echo "export DOTFILES=$INSTALL_DIRECTORY" >>$HOME/.zshrc
	echo "source $INSTALL_DIRECTORY/zsh/.zshrc" >>$HOME/.zshrc

	echo "DEFAULT_USER=$USER" >>$HOME/.zshrc
}

applynvim() {
	# Check nvim
	if ! command -v nvim >/dev/null 2>&1; then
		# echo "nvim is not installed."
		# return $(false)
		mkdir -p $HOME/.local/bin
		curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz | tar zxf - --strip-components 2 -C $HOME/.local/bin nvim-linux64/bin/nvim
	fi

	# install AstroNvim
	mv ~/.config/nvim ~/.config/nvim.bak
	git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
	# remove template's git connection to set up your own later
	rm -rf ~/.config/nvim/.git
}

applyzellij() {
	# Check tmux
	if ! command -v zellij >/dev/null 2>&1; then

		mkdir -p $HOME/.local/bin
		curl -fsSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar zxf - -C $HOME/.local/bin

	fi
}

applynvm() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | zsh
	export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
	nvm install --lts
}

applybat() {
	if ! command -v bat >/dev/null 2>&1; then
		if ! command -v batcat >/dev/null 2>&1; then
			echo "bat is not installed"
			return $(false)
		fi

		mkdir -p $HOME/.local/bin
		ln -s /usr/bin/batcat $HOME/.local/bin/bat
	fi
}

applyeza() {
	if ! command -v eza >/dev/null 2>&1; then
		echo "eza is not installed"
		return $(false)
	fi

	curl https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza -o $INSTALL_DIRECTORY/zsh/eza_completion
	echo "export FPATH=$INSTALL_DIRECTORY/zsh/eza_completion:$FPATH" >>~/.zshrc
}

applyzoxide() {
	if ! command -v zoxide >/dev/null 2>&1; then
		curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
	fi

	echo 'eval "$(zoxide init zsh)"' >>~/.zshrc
}

applygitcz() {
	if ! command -v npm >/dev/null 2>&1; then
		echo "node is not installed"
		return $(false)
	fi

	npm install -g commitizen
}

applyuv() {
	curl -LsSf https://astral.sh/uv/install.sh | sh
}

main() {
	# Check Git
	if ! command -v git >/dev/null 2>&1; then
		echo "You must install git before using the installer."
		return $(false)
	fi

	# Remove old one
	if [ -d $INSTALL_DIRECTORY ]; then
		rm -rf $INSTALL_DIRECTORY
	fi

	# Clone repo to local
	git clone $REPO_URL $INSTALL_DIRECTORY
	if [ $? != 0 ]; then
		echo "Failed to clone $REPO_NAME."
		return 1
	fi
	cd $INSTALL_DIRECTORY
	git checkout $INSTALL_VERSION

	# Apply the config of zsh
	if askquestion "Do you want to apply the config of zsh?"; then
		applyzsh
	fi

	# Apply the config of vim
	if askquestion "Do you want to apply the config of vim?"; then
		applyvim
	fi

	# Apply the config of neovim
	if askquestion "Do you want to apply the config of neovim?"; then
		applynvim
	fi

	# Apply the config of tmux
	if askquestion "Do you want to apply the config of zellij?"; then
		applyzellij
	fi

	if askquestion "Do you want to apply the config of nvm?"; then
		applynvm
	fi

	if askquestion "Do you want to apply the config of bat?"; then
		applybat
	fi

	if askquestion "Do you want to apply the config of eza?"; then
		applyeza
	fi

	if askquestion "Do you want to apply the config of zoxide?"; then
		applyzoxide
	fi

	if askquestion "Do you want to apply the config of git-cz?"; then
		applygitcz
	fi

	if askquestion "Do you want to apply the config of uv?"; then
		applyuv
	fi

	# Finished
	echo
	echo "Done! $REPO_NAME:$INSTALL_VERSION is ready to go! Restart your shell to use it."
}

main
