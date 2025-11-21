# 🚀 Magento 2.4.8-p3 Docker Setup

Thiết lập hoàn chỉnh Magento 2.4.8-p3 với Docker, hỗ trợ hai môi trường Dev và Production dễ dàng chuyển đổi.

## 📋 Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- RAM tối thiểu: 4GB (Dev) / 8GB (Production)
- Disk Space: 20GB trở lên

## 🏗️ Kiến trúc

### Services:
- **Nginx**: Web server (Alpine)
- **PHP 8.4-FPM**: PHP với các extensions cho Magento
- **MySQL**: Database (latest)
- **Redis**: Cache & Session storage
- **OpenSearch**: Search engine
- **phpMyAdmin**: Database management tool

### Volumes (với prefix `mgthemes_`):
- `mgthemes_mysql_data`: MySQL data
- `mgthemes_redis_data`: Redis data
- `mgthemes_opensearch_data`: OpenSearch data
- `mgthemes_composer_cache`: Composer cache (dev only)

### Network:
- `mgthemes_network`: Bridge network cho tất cả containers

## 📁 Cấu trúc thư mục

```
docker-magento/
├── docker/
│   ├── nginx/
│   │   ├── nginx.conf           # Nginx main config
│   │   └── conf.d/
│   │       └── magento.conf     # Magento vhost config
│   ├── php/
│   │   ├── Dockerfile           # PHP 8.4 image
│   │   ├── php.ini              # PHP config (dev)
│   │   ├── php.prod.ini         # PHP config (prod)
│   │   ├── php-fpm.conf         # PHP-FPM config (dev)
│   │   ├── php-fpm.prod.conf    # PHP-FPM config (prod)
│   │   └── xdebug.ini           # Xdebug config (dev)
│   ├── mysql/
│   │   └── my.cnf               # MySQL config
│   └── ssl/                     # SSL certificates (prod)
├── src/                         # Magento source code
├── docker-compose.yml           # Base configuration
├── docker-compose.override.yml  # Dev environment (auto-loaded)
├── docker-compose.prod.yml      # Production environment
├── .env.example                 # Environment variables template
├── start-dev.sh                 # Start dev environment
├── start-prod.sh                # Start prod environment
├── stop.sh                      # Stop containers
├── install-magento.sh           # Magento installation script
└── README.md                    # This file
```

## 🚀 Bắt đầu

### 1. Chuẩn bị

```bash
# Clone hoặc tạo thư mục project
cd /var/www/docker-magento

# Copy file environment
cp .env.example .env

# Chỉnh sửa .env với thông tin của bạn
nano .env
```

### 2. Cấu hình hosts file

**Development (Local):**
```bash
# Linux/Mac
sudo nano /etc/hosts

# Thêm dòng:
127.0.0.1 mgthemes.localhost
```

**Production (VPS):**
```bash
# Trỏ domain về IP VPS
157.20.83.37 mgthemes.info
```

### 3. Khởi động môi trường

#### 🛠️ Development Environment

```bash
# Khởi động dev environment
./start-dev.sh

# Hoặc thủ công:
docker compose up -d --build
```

**Đặc điểm Dev:**
- Xdebug enabled
- Volume mount với `cached` mode
- Expose ports cho truy cập local
- PHP opcache disabled
- Error reporting enabled

**Truy cập:**
- Website: http://mgthemes.localhost
- phpMyAdmin: http://localhost:8080
- OpenSearch: http://localhost:9200
- MySQL: localhost:3306

#### 🚀 Production Environment

```bash
# Khởi động prod environment
./start-prod.sh

# Hoặc thủ công:
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

**Đặc điểm Prod:**
- Xdebug disabled
- Volume mount với `delegated` mode
- Ports không expose ra ngoài (trừ web)
- PHP opcache enabled & optimized
- Error display disabled
- MySQL & Redis optimized
- Restart policy: always

**Truy cập:**
- Website: http://mgthemes.info (hoặc https với SSL)
- phpMyAdmin: http://localhost:8080 (chỉ từ localhost)

### 4. Cài đặt Magento

```bash
# Vào container PHP
docker compose exec mgthemes_php bash

# Chạy script cài đặt
cd /var/www/html
bash install-magento.sh

# Hoặc cài đặt thủ công với Composer
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.8-p3 .
```

Script `install-magento.sh` sẽ:
1. Tải Magento 2.4.8-p3 qua Composer
2. Cấu hình database, Redis, OpenSearch
3. Tạo admin user
4. Deploy static content
5. Reindex data

## 🔄 Chuyển đổi môi trường

### Dev → Production

```bash
# Stop dev environment
docker compose down

# Start production environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Production → Dev

```bash
# Stop production environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Start dev environment
docker compose up -d
```

### Hoặc sử dụng scripts:

```bash
# Stop bất kỳ environment nào
./stop.sh dev    # hoặc ./stop.sh prod

# Start lại environment mong muốn
./start-dev.sh   # hoặc ./start-prod.sh
```

## 🔧 Các lệnh hữu ích

### Docker Commands

```bash
# Xem logs
docker compose logs -f                    # All services
docker compose logs -f mgthemes_php       # PHP only
docker compose logs -f mgthemes_nginx     # Nginx only

# Restart services
docker compose restart mgthemes_php
docker compose restart mgthemes_nginx

# Rebuild containers
docker compose up -d --build

# Stop all
docker compose down

# Stop và xóa volumes
docker compose down -v
```

### Magento Commands

```bash
# Vào PHP container
docker compose exec mgthemes_php bash

# Magento CLI
php bin/magento cache:flush
php bin/magento cache:clean
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f
php bin/magento indexer:reindex

# Switch modes
php bin/magento deploy:mode:set developer    # Dev mode
php bin/magento deploy:mode:set production   # Prod mode

# Permissions
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R www-data:www-data .
```

### Database Operations

```bash
# Export database
docker compose exec mgthemes_mysql mysqldump -u magento -p magento > backup.sql

# Import database
docker compose exec -T mgthemes_mysql mysql -u magento -p magento < backup.sql

# Access MySQL CLI
docker compose exec mgthemes_mysql mysql -u magento -p
```

## 🔐 Bảo mật Production

### 1. Cập nhật passwords trong `.env`

```bash
MYSQL_ROOT_PASSWORD=<strong-password>
MYSQL_PASSWORD=<strong-password>
MAGENTO_ADMIN_PASSWORD=<strong-password>
OPENSEARCH_PASSWORD=<strong-password>
```

### 2. Cấu hình SSL/HTTPS

```bash
# Tạo thư mục SSL
mkdir -p docker/ssl

# Copy certificates
cp your-cert.crt docker/ssl/
cp your-key.key docker/ssl/

# Update nginx config để enable SSL
```

### 3. Firewall

```bash
# Chỉ mở ports cần thiết
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 4. Disable phpMyAdmin (Production)

Trong `docker-compose.prod.yml`, comment service `mgthemes_phpmyadmin` hoặc giới hạn access.

## 📊 Monitoring

### Container Status

```bash
docker compose ps
docker stats
```

### Service Health Check

```bash
# Check PHP-FPM status
curl http://localhost/status

# Check PHP-FPM ping
curl http://localhost/ping

# Check OpenSearch
curl http://localhost:9200
```

## 🐛 Troubleshooting

### Container không start

```bash
# Check logs
docker compose logs

# Rebuild
docker compose down
docker compose up -d --build
```

### Permission issues

```bash
docker compose exec mgthemes_php bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

### MySQL connection error

```bash
# Check MySQL is running
docker compose ps mgthemes_mysql

# Check connection
docker compose exec mgthemes_php ping mgthemes_mysql
```

### OpenSearch memory issues

Tăng memory trong `docker-compose.yml` hoặc `.prod.yml`:
```yaml
OPENSEARCH_JAVA_OPTS: "-Xms1g -Xmx1g"
```

### Performance issues

**Development:**
- Sử dụng `cached` hoặc `delegated` volume mounts
- Tắt Xdebug khi không cần: `XDEBUG_MODE=off`

**Production:**
- Enable opcache (đã config sẵn)
- Sử dụng production mode
- Optimize MySQL buffer pool
- Tăng PHP memory limit

## 📚 Tài liệu tham khảo

- [Magento 2 DevDocs](https://devdocs.magento.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Documentation](https://www.php.net/docs.php)

## 🤝 Support

Nếu gặp vấn đề, kiểm tra:
1. Docker logs: `docker compose logs -f`
2. PHP error logs: `docker compose exec mgthemes_php tail -f /var/log/php_errors.log`
3. Nginx error logs: `docker compose exec mgthemes_nginx tail -f /var/log/nginx/error.log`
4. Magento logs: `src/var/log/`

## 📝 License

Magento 2 là phần mềm mã nguồn mở theo giấy phép OSL 3.0 và AFL 3.0.

---

**Phát triển bởi:** MGThemes Team  
**Website:** mgthemes.info  
**Email:** admin@mgthemes.info
