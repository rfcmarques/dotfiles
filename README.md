# Dotfiles & Development Environment Setup

This repository contains my personal configuration files (`dotfiles`) and an automated setup script to instantly configure a fresh development machine (Ubuntu or WSL).

## 🛠 What's Included?

The `ubuntu-setup.sh` script automates the installation of the following stack:

| Category | Tools Installed |
| :--- | :--- |
| **Language: PHP** | PHP 8.3, Composer, Extensions (MySQL, PgSQL, Mongo, SQLite, XML, Curl, etc.) |
| **Language: JS** | NodeJS (LTS), NVM (Node Version Manager) |
| **Language: Python** | Python 3, Pip, Venv |
| **Databases** | MySQL Server 8.0+, PostgreSQL, MongoDB, SQLite |
| **Containerization** | Docker Engine, Docker Compose |
| **Shell** | Zsh, Oh My Zsh |
| **Theme** | Spaceship Prompt (with Nerd Fonts support) |
| **Plugins** | Autosuggestions, Syntax Highlighting, Git, Laravel, Docker, etc. |

---

## 📋 Prerequisites

Before running the script, ensure you have:

1.  **Ubuntu 22.04 / 24.04** or **WSL 2** running Ubuntu.
2.  **Git** installed (usually pre-installed, but the script checks it).
3.  **Internet Connection** to download packages.
4.  **(Windows Users Only)**: Install the **FiraCode Nerd Font** on Windows to see icons correctly in VS Code/Terminal.
    * [Download FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip)

---

## 🚀 Installation Guide

### Step 1: Clone the Repository
Open your terminal and clone this repo to your home directory:

```bash
cd ~
git clone [https://github.com/rfcmarques/dotfiles.git](https://github.com/rfcmarques/dotfiles.git)
cd dotfiles
```

### Step 2: Make the Script Executable
Give execution permissions to the setup file:

```bash
chmod +x setup.sh
```

### Step 3: Run the Setup
Run the script. It will ask for your `sudo` password to install system packages.

```bash
./setup.sh
```
> **Note:** The script creates a symbolic link between the repository's `.zshrc` and your system's `~/.zshrc`. This means any change you make to the file in this folder allows you to commit and push updates easily.

## ⚠️ Important Notes
### MySQL on WSL
The script installs **MySQL Server**.

- On WSL, system services don't always start automatically. If you get a connection error, run:

```bash
sudo service mysql start
```

- The default installation uses `auth_socket` plugin, meaning `sudo mysql` works without a password. To set up a password for root or create a new user, you may need to run `sudo mysql_secure_installation`.

### Docker on WSL
If you are using WSL, the script installs the Docker Engine inside Ubuntu.

- Ideally, verify if the service is running: `sudo service docker start`.

- Alternatively, you can install **Docker Desktop on Windows** and enable WSL integration.

### Fonts not showing?
If you see squares `[]` instead of icons:

1. Install **FiraCode Nerd Font** on your host OS (Windows/Mac).

2. Configure your terminal (VS Code or Windows Terminal) to use `FiraCode Nerd Font Reg` or `FiraCode NF`.

## 🔄 How to Update
To update your configuration or scripts in the future:

```bash
cd ~/dotfiles
git pull origin main
reload  # Aliased to 'source ~/.zshrc'
```
