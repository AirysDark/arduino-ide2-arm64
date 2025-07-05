#!/bin/bash
set -e

# 🧰 Arduino IDE 2.x Build Script for Raspberry Pi (64-bit)
# Target: Raspberry Pi OS ARM64 with GUI
# Author: AirysDark (optimized by ChatGPT)

echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing required packages..."
sudo apt install -y git curl build-essential \
    libgtk-3-dev libnss3 libxss1 libasound2 \
    desktop-file-utils libudev-dev \
    python3 python3-pip golang-go \
    nodejs npm xz-utils

echo "⬆️  Ensuring recent Node.js version (v18)..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

echo "📥 Installing Yarn..."
sudo npm install -g yarn

echo "📁 Cloning Arduino IDE source..."
git clone --depth 1 https://github.com/AirysDark/arduino-ide.git
cd arduino-ide

echo "📦 Installing Node.js/Electron dependencies..."
yarn install --frozen-lockfile --network-concurrency=4 --mutex network

echo "📦 Adding electron-builder..."
yarn add electron-builder --dev

echo "⬇️  Downloading arduino-cli for ARM64..."
curl -fsSL https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARM64.tar.gz | tar -xz

echo "📂 Placing arduino-cli into resources/app/bin..."
mkdir -p resources/app/bin
mv arduino-cli resources/app/bin/
chmod +x resources/app/bin/arduino-cli

echo "🛠️  Building the Arduino IDE for Linux ARM64..."
yarn electron:build --linux --arm64

echo "📦 Installing IDE to /opt/arduino-ide-arm64..."
sudo rm -rf /opt/arduino-ide-arm64
sudo cp -r dist/linux-arm64-unpacked /opt/arduino-ide-arm64

echo "🖼️  Installing icon and desktop entry..."
sudo cp resources/icons/icon.png /opt/arduino-ide-arm64/arduino-ide.png
sudo tee /usr/share/applications/arduino-ide.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Arduino IDE 2
Comment=Next-gen Arduino IDE
Exec=/opt/arduino-ide-arm64/arduino-ide
Icon=arduino-ide
Terminal=false
Type=Application
Categories=Development;IDE;Electronics;
StartupWMClass=arduino-ide
EOF

sudo ln -sf /opt/arduino-ide-arm64/arduino-ide.png /usr/share/pixmaps/arduino-ide.png
sudo update-desktop-database

echo "✅ Arduino IDE 2 has been successfully built and installed!"
echo "👉 You can launch it from the main menu or with:"
echo "   /opt/arduino-ide-arm64/arduino-ide"