# 🚀 Coolify-Only Deployment Guide for Plasmic

**Zero context switching required!** Deploy Plasmic entirely through Coolify dashboard.

## 📋 What This Setup Does

✅ **GitHub Actions** builds Docker images (no VM resources used)  
✅ **Coolify** handles all system setup automatically  
✅ **Init container** creates swap space and optimizes system  
✅ **Pre-built images** deploy in ~5 minutes  
✅ **Resource-optimized** for your 16GB Hetzner VM  

## 🎯 One-Click Deployment Steps

### 1. Push Code to GitHub
```bash
# From your local machine
git add .
git commit -m "Add Coolify-only deployment setup"
git push origin main
```

This triggers GitHub Actions to build your Docker image (takes ~30-45 minutes, but runs on GitHub's servers).

### 2. Deploy in Coolify Dashboard

**Create New Service:**
1. Go to Coolify → **Services** → **New Service**
2. Choose **Docker Compose**
3. Connect your GitHub repository
4. Set Docker Compose file to: `docker-compose.yml`

**Environment Variables** (set in Coolify):
```bash
SESSION_SECRET=your-super-secure-random-string-here-change-this
NODE_ENV=production
```

**Deploy:**
- Click **Deploy**
- First deployment: ~5-8 minutes
- System initialization runs automatically
- No SSH or VM access needed!

## 🔧 What Happens During Deployment

### Phase 1: System Initialization (2-3 minutes)
- Creates 8GB swap space automatically
- Optimizes kernel parameters for performance
- Sets up application directories
- Runs once, then exits

### Phase 2: Database Startup (1-2 minutes)
- PostgreSQL starts with optimized settings
- Health checks ensure it's ready
- Database initialization runs automatically

### Phase 3: Application Startup (2-3 minutes)
- Pre-built Plasmic image downloads
- Complex database schema setup
- Application becomes available

## 📊 Resource Usage Expectations

| Service | Memory | CPU | Purpose |
|---------|--------|-----|---------|
| system-init | 100MB | 0.1 CPU | Runs once, then exits |
| db | 1-2GB | 0.5-1 CPU | PostgreSQL database |
| verdaccio | 256-512MB | 0.2-0.5 CPU | NPM registry |
| plasmic-app | 6-12GB | 3-6 CPU | Main application |
| **Total** | **8-15GB** | **4-8 CPU** | **Fits in 16GB VM** |

## 🎛️ Coolify Configuration Options

### To Save More Memory
**Option 1: Disable Verdaccio** (saves 512MB)
```yaml
# Comment out the verdaccio service in docker-compose.yml
# verdaccio:
#   image: verdaccio/verdaccio:5
#   ...
```

**Option 2: Reduce App Memory** (if experiencing issues)
```yaml
environment:
  NODE_OPTIONS: "--max-old-space-size=2048"  # Reduce to 2GB heap
deploy:
  resources:
    limits:
      memory: 8G  # Reduce from 12G to 8G
```

### To Use Coolify Magic Variables
Uncomment these lines in the docker-compose.yml:
```yaml
environment:
  APP_URL: "https://${SERVICE_FQDN_PLASMIC_APP}"
  DATABASE_URL: "postgresql://wab:plasmic@db:5432/wab"
```

## 🔍 Monitoring & Troubleshooting

### Check Deployment Status
In Coolify dashboard:
- **Services** → Your service → **Logs**
- Look for "🎉 System initialization complete!"
- Database should show "database system is ready to accept connections"
- App should show "Server listening on port 3003"

### Common Issues

**1. Memory Issues**
```
Symptoms: OOM kills, containers restarting
Solution: Swap space should handle this automatically
Check: Look for "✅ Swap space created" in init logs
```

**2. Slow Database Startup**
```
Symptoms: App waiting for database
Solution: Normal - database initialization takes 2-3 minutes
Check: Database logs for "ready to accept connections"
```

**3. Image Pull Failures**
```
Symptoms: Failed to pull ghcr.io/... image
Solution: Ensure GitHub Actions workflow completed
Check: GitHub repository → Actions → Latest workflow run
```

## 🚨 Production Checklist

Before going live:

- [ ] Change `SESSION_SECRET` to secure random string (in Coolify environment variables)
- [ ] Set up custom domain in Coolify
- [ ] Enable SSL certificates (Coolify handles this automatically)
- [ ] Set up database backups via Coolify
- [ ] Configure monitoring alerts in Coolify
- [ ] Test application functionality

## 💰 Cost Optimization

### Current Setup: €35/month Hetzner VM
- **Recommended**: Leave as-is for production stability

### If You Want to Save Money
Monitor actual resource usage for 1 week, then:

**Option 1: Downgrade to CX42 (€15/month)**
- Same CPU/RAM, less disk space
- 57% cost savings

**Option 2: Downgrade to CX32 (€8/month)**  
- 4vCPU, 8GB RAM - requires removing Verdaccio
- 77% cost savings

## 🔄 Updates & Maintenance

### Updating the Application
1. **Push changes to GitHub**
2. **GitHub Actions builds new image**
3. **In Coolify**: Click "Deploy" to update
4. **Zero downtime** with proper health checks

### Database Backups
Coolify handles this automatically if you enable database backups in the dashboard.

---

## 🎉 That's It!

**No SSH required. No VM access needed. No context switching.**

Just push to GitHub → Deploy in Coolify → Your Plasmic application is live!

The system initialization container handles all the complex VM setup automatically, so you never need to leave the Coolify dashboard.