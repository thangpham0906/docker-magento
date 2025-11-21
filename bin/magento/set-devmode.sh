#!/bin/bash

# Set Magento to developer mode
docker compose exec -T mgthemes_php php bin/magento  deploy:mode:set developer

# Disable Adobe IMS Two Factor Authentication module
docker compose exec -T mgthemes_php php bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth

# Disable Two Factor Authentication module
docker compose exec -T mgthemes_php php bin/magento module:disable Magento_TwoFactorAuth


# Set admin password to never expire
docker compose exec -T mgthemes_php php bin/magento config:set admin/security/password_is_forced 0
docker compose exec -T mgthemes_php php bin/magento config:set admin/security/password_lifetime 0

# Disable CAPTCHA for admin and customer forms
docker compose exec -T mgthemes_php php bin/magento config:set admin/captcha/enable 0
docker compose exec -T mgthemes_php php bin/magento config:set customer/captcha/enable 0

# Flush cache after changing mode and disabling modules
docker compose exec -T mgthemes_php php bin/magento cache:flush 
docker compose exec -T mgthemes_php php bin/magento cache:clean
echo "✅ Magento is now set to developer mode and unnecessary modules are disabled."