# Laravel Docker Deployment Guide

## Overview
This Laravel application is containerized using Docker with an external database server configuration.

## Prerequisites
- Docker installed on your server
- Docker Compose (optional, but recommended)
- Access to your external database server
- SSL certificate (recommended for production)

## Quick Start

### 1. Prepare Your Environment

Copy the production environment example:
```bash
cp .env.production.example .env
```

Edit `.env` and update the following:
- `APP_KEY` - Generate using: `php artisan key:generate` (or manually)
- `APP_URL` - Your domain URL
- `DB_HOST` - Your external database host
- `DB_DATABASE` - Your database name
- `DB_USERNAME` - Your database username
- `DB_PASSWORD` - Your database password

### 2. Build the Docker Image

```bash
docker build -t laravel-app:latest .
```

### 3. Run with Docker Compose (Recommended)

Update `docker-compose.yml` with your database credentials, then:

```bash
docker-compose up -d
```

### 4. Run with Docker (Alternative)

```bash
docker run -d \
  --name laravel-app \
  -p 8080:80 \
  -e DB_HOST=your-external-db-host.com \
  -e DB_PORT=3306 \
  -e DB_DATABASE=your_database_name \
  -e DB_USERNAME=your_db_username \
  -e DB_PASSWORD=your_db_password \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  -e APP_KEY=base64:your-app-key-here \
  -v $(pwd)/storage/app:/var/www/html/storage/app \
  -v $(pwd)/storage/logs:/var/www/html/storage/logs \
  laravel-app:latest
```

## Post-Deployment Steps

### 1. Run Database Migrations

```bash
# With Docker Compose
docker-compose exec app php artisan migrate --force

# With Docker
docker exec -it laravel-app php artisan migrate --force
```

### 2. Optimize Laravel

```bash
# With Docker Compose
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# With Docker
docker exec -it laravel-app php artisan config:cache
docker exec -it laravel-app php artisan route:cache
docker exec -it laravel-app php artisan view:cache
```

### 3. Create Storage Link (if needed)

```bash
docker-compose exec app php artisan storage:link
```

## Production Recommendations

### 1. Use HTTPS
Set up a reverse proxy (like Nginx or Traefik) with SSL certificates:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. Enable Queue Workers
Uncomment the queue worker section in `docker/supervisor/supervisord.conf` and rebuild the image.

### 3. Enable Scheduler
Uncomment the scheduler section in `docker/supervisor/supervisord.conf` and rebuild the image.

### 4. Use Redis/Memcached for Caching
Update your `.env` file and ensure Redis/Memcached is accessible:

```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=your-redis-host
REDIS_PASSWORD=your-redis-password
REDIS_PORT=6379
```

### 5. Set Up Log Rotation
The logs are stored in `storage/logs`. Set up log rotation on your host machine.

## Monitoring

### View Logs
```bash
# Application logs
docker-compose logs -f app

# Nginx access logs
docker-compose exec app tail -f /var/log/nginx/access.log

# Nginx error logs
docker-compose exec app tail -f /var/log/nginx/error.log

# Laravel logs
docker-compose exec app tail -f storage/logs/laravel.log
```

### Health Check
The container includes a health check that runs every 30 seconds:
```bash
docker-compose ps
```

## Troubleshooting

### Permission Issues
```bash
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 755 /var/www/html/storage
```

### Clear Caches
```bash
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

### Database Connection Issues
1. Verify your external database is accessible from the Docker container
2. Check if your database server allows connections from the Docker host IP
3. Verify credentials in `.env` file

### Restart Services
```bash
docker-compose restart
```

## Scaling

To run multiple instances behind a load balancer:

```bash
docker-compose up -d --scale app=3
```

Note: Ensure you use Redis for sessions when scaling horizontally.

## Backup

### Storage Directory
```bash
tar -czf storage-backup-$(date +%Y%m%d).tar.gz storage/app
```

### Database
Backup your external database according to your database provider's recommendations.

## Updates

### Update Application Code
```bash
git pull origin main
docker-compose build
docker-compose up -d
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

## Security Checklist

- [ ] Set `APP_DEBUG=false` in production
- [ ] Generate a strong `APP_KEY`
- [ ] Use HTTPS with valid SSL certificates
- [ ] Keep database credentials secure
- [ ] Regularly update dependencies
- [ ] Set up firewall rules
- [ ] Use environment variables for sensitive data
- [ ] Enable rate limiting
- [ ] Set up regular backups
- [ ] Monitor logs for suspicious activity

## Support

For issues specific to your Laravel application, check the Laravel documentation:
https://laravel.com/docs
