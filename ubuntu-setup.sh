#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# ==========================================
# 0. Helper Functions & Formatting
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for Sudo
if [ "$EUID" -ne 0 ]; then 
    warn "Please run this script with sudo or allow sudo permissions during execution."
fi

info "🚀 Starting System Setup..."

# ==========================================
# 1. System Update & Dependencies
# ==========================================
info "📦 Updating system repositories and installing base dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip build-essential software-properties-common ca-certificates gnupg lsb-release

# ==========================================
# 2. PHP Setup (Ondrej PPA)
# ==========================================
info "🐘 Installing PHP, Composer, and Extensions..."
# Add Ondrej PPA for latest PHP versions
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Install PHP 8.3 (Stable) and extensions
# Note: php-mysql works for both MySQL and MariaDB
sudo apt install -y php8.3 php8.3-cli php8.3-common \
    php8.3-mysql php8.3-pgsql php8.3-sqlite3 php8.3-mongodb \
    php8.3-curl php8.3-mbstring php8.3-xml php8.3-zip php8.3-bcmath php8.3-intl php8.3-gd

# Install Composer
if ! command -v composer &> /dev/null; then
    info "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
else
    success "Composer is already installed."
fi

# ==========================================
# 3. NodeJS & NVM
# ==========================================
info "🟢 Installing NVM and NodeJS..."

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    # Install NVM (Latest stable script)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    
    # Load NVM for this session to install Node
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    success "NVM is already installed."
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install latest LTS Node version
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# ==========================================
# 4. Python Setup
# ==========================================
info "🐍 Installing Python, Pip, and Venv..."
sudo apt install -y python3 python3-pip python3-venv

# ==========================================
# 5. Databases
# ==========================================
info "🗄️ Installing Database Engines..."

# 5.1 SQLite
sudo apt install -y sqlite3

# 5.2 PostgreSQL
info "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# 5.3 MySQL Server
info "Installing MySQL Server..."
# DEBIAN_FRONTEND=noninteractive prevents the installer from popping up a UI asking for password
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

# Ensure MySQL service is running (Essential for WSL)
if ! pgrep mysqld > /dev/null; then
    info "Starting MySQL Service..."
    sudo service mysql start || warn "Could not start MySQL automatically. You may need to run 'sudo service mysql start'."
fi

# 5.4 MongoDB (Official Repo)
info "Installing MongoDB..."
if ! command -v mongod &> /dev/null; then
    # Import public key (Ubuntu 22.04 Jammy / 24.04 Noble supported by 7.0+)
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg --yes
    # Create list file (Adjusting codename automatically)
    CODENAME=$(lsb_release -sc)
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu $CODENAME/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt update
    sudo apt install -y mongodb-org
else
    success "MongoDB is already installed."
fi

# ==========================================
# 6. Docker
# ==========================================
info "🐳 Installing Docker Engine..."
if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Post-install: Allow running docker without sudo
    sudo usermod -aG docker $USER || true
    warn "You may need to log out and back in for Docker group permissions to take effect."
else
    success "Docker is already installed."
fi

# ==========================================
# 7. Zsh & Oh My Zsh Configuration
# ==========================================
info "🎨 Setting up Zsh, Oh My Zsh, and Plugins..."

# Install Zsh
sudo apt install -y zsh

# Install Oh My Zsh (Unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Define Custom Directory
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install Plugins (from your list)
info "Cloning Zsh plugins..."

# 1. Autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 2. Syntax Highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install Theme: Spaceship
info "Cloning Spaceship Theme..."
if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# ==========================================
# 8. Symlink Dotfiles
# ==========================================
info "🔗 Linking configuration files..."

REPO_DIR=$(pwd)
ZSHRC_FILE="$REPO_DIR/.zshrc"

if [ -f "$ZSHRC_FILE" ]; then
    # Backup existing .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%s)"
        warn "Existing .zshrc was backed up."
    fi
    
    # Create Symlink
    ln -s "$ZSHRC_FILE" "$HOME/.zshrc"
    success ".zshrc linked successfully!"
else
    error "Could not find .zshrc in the current directory. Please run this script from the root of your dotfiles repo."
fi

# ==========================================
# 9. Final Default Shell Change
# ==========================================
# Check if Zsh is default
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

echo ""
success "🎉 Installation Complete!"
info "Please restart your terminal or log out/log in to see all changes."
info "To verifying DB services status, try: sudo service mysql status"
