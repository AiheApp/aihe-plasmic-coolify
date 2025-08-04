#!/bin/bash
# Hetzner VM Setup Script for Plasmic Deployment
# Optimizes 16GB VM for Coolify deployment

set -e

echo "🚀 Setting up Hetzner VM for Plasmic deployment..."

# Add swap space (8GB) for memory-intensive operations
echo "📁 Setting up swap space..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "✅ 8GB swap space created"
else
    echo "✅ Swap space already exists"
fi

# Optimize swappiness for better performance
echo "⚙️ Optimizing memory settings..."
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Install Docker if not present
echo "🐳 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose if not present
echo "🔧 Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Configure Docker daemon for better resource management
echo "⚙️ Configuring Docker daemon..."
sudo mkdir -p /etc/docker
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  }
}
EOF

# Restart Docker to apply configuration
sudo systemctl restart docker
sudo systemctl enable docker

# Create directory for application logs
sudo mkdir -p /opt/plasmic/logs
sudo chown -R $USER:$USER /opt/plasmic

# Display system information
echo ""
echo "📊 System Information:"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Swap: $(free -h | grep Swap | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"
echo "CPU: $(nproc) cores"
echo ""

echo "🎉 Hetzner VM setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Push your code to GitHub (triggers image build)"
echo "2. In Coolify, create a new service using docker-compose.coolify.yml"
echo "3. Set environment variables in Coolify dashboard"
echo "4. Deploy and monitor resource usage"
echo ""
echo "⚠️  Important: Logout and login again to apply Docker group membership"