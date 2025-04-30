#!/usr/bin/env bash

set -e

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl build-essential xclip

echo "==> Cloning Neovim source into ~/.neovim..."
if [ -d "$HOME/.neovim" ]; then
  echo "   - Directory ~/.neovim already exists. Skipping clone."
else
  git clone https://github.com/neovim/neovim "$HOME/.neovim"
fi

echo "==> Building Neovim from source..."
cd "$HOME/.neovim"
make CMAKE_BUILD_TYPE=Release

echo "==> Installing Neovim..."
sudo make install

# add nvim to the path
CUSTOM_NVIM_PATH="/opt/nvim-linux64/bin"

if ! grep -q "$CUSTOM_NVIM_PATH" "$HOME/.bashrc"; then
  echo "==> Adding Neovim path to ~/.bashrc..."
  echo "" >> "$HOME/.bashrc"
  echo "# Add custom Neovim path" >> "$HOME/.bashrc"
  echo "export PATH=\"\$PATH:$CUSTOM_NVIM_PATH\"" >> "$HOME/.bashrc"
else
  echo "==> Neovim path already in ~/.bashrc. Skipping."
fi

echo "==> Sourcing ~/.bashrc to apply changes..."
source "$HOME/.bashrc"

echo "😈😈 Neovim installation complete. 😈😈"

