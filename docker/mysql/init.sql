-- MySQL Initialization Script
-- This script runs automatically when MySQL container is first created

-- Grant all privileges to magento user including trigger creation
GRANT ALL PRIVILEGES ON *.* TO 'magento'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Set log_bin_trust_function_creators for trigger support
SET GLOBAL log_bin_trust_function_creators = 1;
