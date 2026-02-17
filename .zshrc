# Path to my Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# --- THEME ---
ZSH_THEME="spaceship"

# --- NVM Config (Lazy Load) ---
export NVM_DIR="$HOME/.nvm"
zstyle ':omz:plugins:nvm' lazy yes
zstyle ':omz:plugins:nvm' autoload yes

# --- PLUGINS ---
# Note: Syntax Highlighting must always be the last plugin
plugins=(
  git
  z
  laravel
  composer
  npm
  nvm
  python
  pip
  docker
  docker-compose
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- ENV LANG ---
export LANG=en_US.UTF-8

# --- SYSTEM ALIASES ---
alias ll="ls -al"
alias cl="clear"
alias zshconfig="nano ~/.zshrc"
alias reload="source ~/.zshrc"

# --- DEV ALIASES ---
alias crd="composer run dev"
alias pamcm="php artisan make:command"
alias padb="php artisan db:backup"
alias tinker="php artisan tinker"
alias pest="./vendor/bin/pest"
alias npmin="npm install"
alias npmrw="npm run watch"
alias venv="source venv/bin/activate"
alias pipr="pip install -r requirements.txt"
alias nah="git reset --hard && git clean -df"
alias myip="curl http://ipecho.net/plain; echo"

# --- SPACESHIP CONFIGURATION ---
SPACESHIP_PROMPT_ORDER=(
  user
  host
  dir
  git
  node
  php
  laravel
  python
  venv
  docker
  docker_compose
  exec_time
  line_sep
  jobs
  exit_code
  char
)

# Visual Customization
SPACESHIP_USER_SHOW="always"
SPACESHIP_USER_SUFFIX=""
SPACESHIP_HOST_SHOW="always"
SPACESHIP_HOST_PREFIX="@"
SPACESHIP_NODE_PREFIX=" "
SPACESHIP_PHP_PREFIX=" "
SPACESHIP_PYTHON_PREFIX=" "
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_CHAR_SYMBOL="➜ "
SPACESHIP_CHAR_SUFFIX=" "

# Legacy Laravel Support
SPACESHIP_LARAVEL_SHOW="true"
SPACESHIP_LARAVEL_ASYNC="false"

# --- CUSTOM SECTIONS ---

# Restore Laravel section
spaceship_laravel() {
  [[ -f artisan ]] || return
  spaceship::section \
    --color "red" \
    --symbol " " \
    --prefix " " \
    --suffix " " \
    "Laravel"
}
