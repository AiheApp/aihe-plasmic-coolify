# 🚀 Coolify Deployment Guide for Plasmic

This guide will help you deploy Plasmic to your Hetzner VM using Coolify with an external build pipeline.

## 📋 Prerequisites

- Hetzner VM: 8vCPU, 16GB RAM, 240GB disk (~€35/month)
- Coolify installed and running
- GitHub repository with push access
- GitHub Container Registry access

## 🔧 Setup Steps

### 1. Prepare Your Hetzner VM

Run the setup script on your Hetzner VM:

```bash
# Upload and run the setup script
./setup-hetzner-vm.sh
```

This script will:
- Add 8GB swap space for memory optimization
- Install Docker and Docker Compose
- Configure Docker daemon for resource efficiency
- Optimize kernel parameters for better performance

### 2. Configure GitHub Container Registry

The GitHub Actions workflow is already configured to push to GitHub Container Registry (GHCR). No additional setup needed - it uses `GITHUB_TOKEN` automatically.

### 3. Push Code to Trigger Build

```bash
git add .
git commit -m "Add Coolify deployment configuration"
git push origin main  # or your default branch
```

This will trigger the GitHub Actions workflow that:
- Builds the Docker image using `Dockerfile.build`
- Pushes the image to `ghcr.io/yourusername/aihe-plasmic-coolify/plasmic:latest`
- Takes ~30-45 minutes (but runs on GitHub's servers, not your VM)

### 4. Deploy in Coolify

1. **Create New Service**:
   - Go to your Coolify dashboard
   - Create new service → Docker Compose
   - Connect your GitHub repository

2. **Configure Docker Compose**:
   - Set compose file to: `docker-compose.coolify.yml`
   - This file uses pre-built images instead of building locally

3. **Set Environment Variables** (in Coolify dashboard):
   ```bash
   SESSION_SECRET=your-super-secure-session-secret-here
   NODE_ENV=production
   ```

4. **Deploy**:
   - Click "Deploy"
   - First deployment should complete in ~5 minutes (vs 60+ minutes with local builds)

## 📊 Resource Monitoring

### Memory Usage Expectations
- **Database**: ~1-2GB
- **Plasmic App**: ~6-10GB (with 3GB heap limit)
- **System + Others**: ~2-4GB
- **Total**: 9-16GB (fits in your 16GB VM)

### Monitoring Commands
```bash
# Check memory usage
docker stats

# Check swap usage
free -h

# Check disk usage
df -h
```

## 🔍 Troubleshooting

### Common Issues

**1. Out of Memory During Deployment**
```bash
# Check if swap is active
sudo swapon --show

# If no swap, run setup script again
./setup-hetzner-vm.sh
```

**2. Docker Image Pull Fails**
- Ensure GitHub Actions workflow completed successfully
- Check image exists: `docker pull ghcr.io/yourusername/aihe-plasmic-coolify/plasmic:latest`

**3. Database Connection Issues**
- Database takes ~30 seconds to initialize
- Check logs: `docker-compose logs db`
- Verify health check: `docker-compose ps`

**4. Application Won't Start**
```bash
# Check application logs
docker-compose logs plasmic-app

# Common issues:
# - Database not ready (wait 2-3 minutes)
# - Memory limits too strict (increase in docker-compose.coolify.yml)
# - Node.js heap size too small (increase NODE_OPTIONS)
```

## ⚡ Performance Optimizations

### If App Runs Slowly

1. **Increase Memory Limits** (if available):
   ```yaml
   # In docker-compose.coolify.yml
   deploy:
     resources:
       limits:
         memory: 14G  # Increase if you have spare RAM
   ```

2. **Optimize Database**:
   ```yaml
   environment:
     POSTGRES_SHARED_BUFFERS: 512MB  # Increase if spare RAM
     POSTGRES_EFFECTIVE_CACHE_SIZE: 4GB
   ```

3. **Monitor Resource Usage**:
   ```bash
   # Watch real-time usage
   watch docker stats
   ```

## 💰 Cost Optimization Options

### Current Setup: €35/month
- 8vCPU, 16GB RAM, 240GB disk
- Recommended for production use

### Cheaper Alternatives

**1. Hetzner CX42 - €15/month** (57% savings)
- 8vCPU, 16GB RAM, 160GB disk
- Reduce memory limits in docker-compose.coolify.yml:
  ```yaml
  NODE_OPTIONS: "--max-old-space-size=2048"  # 2GB heap
  ```

**2. Hetzner CX32 - €8/month** (77% savings)
- 4vCPU, 8GB RAM, 80GB disk
- Requires significant memory optimization
- Remove Verdaccio service to save RAM

### Testing Smaller Instances

1. Deploy with current configuration
2. Monitor actual memory usage for 1 week
3. If usage <8GB consistently, consider downgrading
4. If usage <4GB consistently, try CX32

## 🚨 Production Checklist

- [ ] Change `SESSION_SECRET` to secure random value
- [ ] Set up SSL certificates (Coolify handles this)
- [ ] Configure domain name in Coolify
- [ ] Set up database backups
- [ ] Configure monitoring and alerts
- [ ] Test disaster recovery procedures
- [ ] Set up log rotation

## 📞 Support

If you encounter issues:

1. Check this troubleshooting guide
2. Review Coolify logs in dashboard
3. Check GitHub Actions build logs
4. Monitor system resources with `htop` or `docker stats`

## 🔄 Updates and Maintenance

### Updating the Application
1. Push code changes to GitHub
2. GitHub Actions builds new image automatically
3. In Coolify, redeploy the service
4. New image will be pulled and deployed

### Database Backups
```bash
# Manual backup
docker-compose exec db pg_dump -U wab wab > backup.sql

# Restore backup
docker-compose exec -T db psql -U wab wab < backup.sql
```

---

**Remember**: This setup reduces deployment complexity and resource usage by building images externally. Your Hetzner VM only needs to run the containers, not build them.