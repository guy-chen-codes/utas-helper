# Check if 'utas_helper_user_name' is unset and the group name is 'staff'
if [[ -z "$utas_helper_user_name" && "$(id -gn)" == "staff" ]]; then
    echo "Please set up \$utas_helper_user_name beforehand for VM environment"
    echo "For exmaple:"
    echo "$ export utas_helper_user_name='GuyChen'"
    exit 0
fi

# Determine the username to use
username="${utas_helper_user_name:-$(whoami)}"
host_501="ictteach.its.utas.edu.au"
host_502="ictteach-www.its.utas.edu.au"
ssh_kit502="ssh ${username}@${host_502}"

# Write the aliases and functions to the .profile
tee "$HOME/.profile" <<EOF >/dev/null
alias b='brew'
alias wl-copy='pbcopy'
alias utas="echo -n ${username}@utas.edu.au | wl-copy"
alias kit501="ssh ${username}@${host_501}"
alias kit502="${ssh_kit502}"
alias kit502-ssh="echo ${ssh_kit502} | wl-copy" # copy kit502 ssh command for vscode remote debug configuration
alias ll='ls -laF'
alias t='tmux'
alias awake='caffeinate -d' # Keeping awake

export BASH_SILENCE_DEPRECATION_WARNING=1

keygen() {
    [[ -d "$HOME/.ssh" ]] || \
        ssh-keygen -b 4096 -C "${username}@utas.edu.au" -t ed25519
}

ZSH_MODULE_DIR="$HOME/.config/zsh"

if [[ ! -d "$ZSH_MODULE_DIR" ]]; then
  return 1
fi

echo "⚙️  Loading Zsh profile modules from '$ZSH_MODULE_DIR'..."

# --- Load all alias and function files ---
for module_file in "$ZSH_MODULE_DIR"/aliases*.zsh "$ZSH_MODULE_DIR"/functions*.zsh; do
  if [[ -f "$module_file" ]]; then
    source "$module_file"
    echo "  -> Loaded $(basename "$module_file")"
  fi
done

echo "✅ Zsh profile loaded successfully."

EOF

# Configure Git
git config --global alias.fu 'fetch upstream'
git config --global alias.fo 'fetch origin'
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.cm commit
git config --global alias.st status
git config --global alias.cp cherry-pick
git config --global alias.po "push -u origin HEAD"
git config --global alias.cl "clean -d -f"
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global push.default current
git config --global remote.pushDefault origin
git config --global pull.rebase false

# Create necessary directories and install Homebrew
mkdir -p ~/.local/Homebrew ~/Applications
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.local/Homebrew

# Create a symbolic link for brew in ~/.local/bin
mkdir -p ~/.local/bin
ln -sf ~/.local/Homebrew/bin/brew ~/.local/bin

# Update PATH and set Homebrew Cask options
cat <<'EOF' >>~/.profile
[ -d "$HOME/.local/bin" ] &&
export PATH="$PATH:$HOME/.local/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"
EOF

# Copy profile to zshrc and source the files
cp ~/.profile ~/.zshrc
source ~/.profile
source ~/.zshrc

# Clone UTAS Helper repository
git clone https://github.com/Guy-Chan/utas-helper.git ~/repos/utas-helper

# Install GitHub CLI and Raycast
# Lock iTerm2 version to 3.4.23 via customized tap
brew install gh raycast guy-chen-codes/tap/iterm2

# Install Zoom by fetching the package and extracting it manually
# It won't work as for enabling zoom accessing camera still requires sudo
# brew fetch zoom
# xar -xf ~/Library/Caches/Homebrew/Cask/zoom--*.pkg
# cpio -i --file zoomus.pkg/Payload
# mv zoom.us.app ~/Applications

# Install VSCode extensions
code --install-extension GitHub.copilot
code --install-extension ms-python.debugpy
code --install-extension ms-python.python
code --install-extension KevinRose.vsc-python-indent
code --install-extension charliermarsh.ruff
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension foxundermoon.shell-format

# Install additional useful utilities
brew install jid jq zip dua-cli
# brew install tlrc jid pandoc jq zip dua-cli visualboyadvance-m altserver

# Personal setup, requires function `customization` to be defined beforehand.
if [ -n "$(type -t customization)" ] && [ "$(type -t customization)" = function ]; then
    customization
fi

# KIT718 dependencies
# brew install spark
# ~/.local/bin/pip3 install --break-system-packages sparkmagic matplotlib==3.7.5 scikit-learn pandas scikit-image PyArrow pyspark findspark grpcio google 
# cd ~/Library/Python/*/lib/python/site-packages
# jupyter-kernelspec install sparkmagic/kernels/pysparkkernel
#
# jupyter pyspark init:
# ```python
# import os
# import glob
#
# java_home_pattern = os.path.join(os.getenv("HOME"), ".local/Cellar/openjdk@*/*/")
# java_home_dirs = glob.glob(java_home_pattern)
#
# os.environ["JAVA_HOME"] = java_home_dirs[0]
#
# import findspark
# findspark.init()
# from pyspark import SparkContext
# from pyspark.sql import SparkSession
# sc = SparkContext("local", "KIT718")
# spark = SparkSession.builder.appName("KIT718").getOrCreate()
# ```

# KIT717 sense-hat-emulator
# brew install pipx pygobject3 gtk+3
# pipx install --system-site-packages sense-emu
# echo 'source ~/Library/Application\ Support/pipx/venvs/sense-emu/bin/activate && code && sense_emu_gui' > ~/.local/bin/hat-emulator
# chmod +x ~/.local/bin/hat-emulator
