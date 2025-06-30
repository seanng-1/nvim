#!/usr/bin/env bash

set -e

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl build-essential xclip clangd ripgrep

# install ruff
curl -LsSf https://astral.sh/ruff/install.sh | sh

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

# add custom paths e.g. ruff and neovim location
PATHS_TO_ADD="$HOME/.local/bin:/opt/nvim-linux64/bin"

if ! grep -q "$PATHS_TO_ADD" "$HOME/.bashrc"; then
  echo "==> Adding Ruff and Neovim paths to ~/.bashrc..."
  echo "" >> "$HOME/.bashrc"
  echo "# Add Ruff and custom Neovim to PATH" >> "$HOME/.bashrc"
  echo "export PATH=\"$PATHS_TO_ADD:\$PATH\"" >> "$HOME/.bashrc"
else
  echo "==> Ruff and Neovim paths already in ~/.bashrc. Skipping."
fi

echo "==> Sourcing ~/.bashrc to apply changes..."
source "$HOME/.bashrc"

echo "😈😈 Neovim installation complete. 😈😈"

