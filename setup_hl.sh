#!/bin/bash

# Define the new username and the home directory
NEW_USER="hyperliquiduser"
NEW_USER_HOME="/home/$NEW_USER"

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Create the new user with a home directory
if ! id -u $NEW_USER > /dev/null 2>&1; then
    useradd -m -d $NEW_USER_HOME -s /bin/bash $NEW_USER
    if [ $? -ne 0 ]; then
        echo "Failed to create user $NEW_USER"
        exit 1
    fi
    echo "User $NEW_USER created successfully"
else
    echo "User $NEW_USER already exists"
fi

# Set ownership of the home directory to the new user
chown -R $NEW_USER:$NEW_USER $NEW_USER_HOME

# Switch to the new user and perform the setup
su - $NEW_USER << 'EOF'
# Set up environment
set -e

# Define the home directory
HOME_DIR="/home/hyperliquiduser"

# Save initial peers
curl https://binaries.hyperliquid.xyz/Testnet/initial_peers.json > $HOME_DIR/initial_peers.json

# Configure chain to testnet
echo '{"chain": "Testnet"}' > $HOME_DIR/visor.json

# Download the non-validator configuration
curl https://binaries.hyperliquid.xyz/Testnet/non_validator_config.json > $HOME_DIR/non_validator_config.json

# Download the visor binary and make it executable
curl https://binaries.hyperliquid.xyz/Testnet/hl-visor > $HOME_DIR/hl-visor
chmod a+x $HOME_DIR/hl-visor

echo "Setup completed successfully."

echo "Running hl-visor..."
# Start the visor
$HOME_DIR/hl-visor


EOF
