#!/usr/bin/env bash

# Name of the WordPress tarball
tarball="wordpress-5.1.1.tar.gz"

# Checks to see if User passed a variable from the command line
# If they did not, sets the default password to Drawsap
password=${1:-root}

# Install and Start Apache Web Server
install_apache () {
  echo "Install and Start Apache Web Server"
  cd $HOME
  sudo yum install httpd -y
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
  echo "Finished"
}

# Install and Start MySQL(MariaDB)
install_mysql () {
  echo "Install and Start MySQL(MariaDB)"
  cd $HOME
  sudo yum install mariadb-server mariadb -y
  sudo systemctl start mariadb
  # sudo mysql_secure_installation
  mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root';"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
  mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
  mysql -u root -e "DROP DATABASE IF EXISTS test;"
  mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
  mysql -u root -e "FLUSH PRIVILEGES;"
  sudo systemctl enable mariadb.service
  echo "Finished"
}

# Install and Start PHP
install_php () {
  echo "Install and Start PHP"
  cd $HOME
  sudo yum install php php-mysql -y
  sudo systemctl restart httpd.service
  echo "Finished"
  # Open Firewall for http/https traffic (also ensure portforwarding is done for port 80)
  sudo firewall-cmd --permanent --zone=public --add-service=http 
  sudo firewall-cmd --permanent --zone=public --add-service=https
  sudo firewall-cmd --reload
}

# Create MySQL Database and User for WordPress
set_up_sql_user () {
  echo "Create MySQL Database and User for WordPress"
  cd $HOME
  mysql -u root -p$password -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
  mysql -u root -p$password -e "CREATE USER IF NOT EXISTS wordpressuser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'password';"
  mysql -u root -p$password -e "FLUSH PRIVILEGES;"
  echo "Finished"
}

# Install WordPress
install_wordpress () {
  echo "Install WordPress"
  cd $HOME
  sudo yum install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
  sudo systemctl restart httpd
  wget https://wordpress.org/$tarball
  tar -xzf $tarball
  sudo rsync -avP ~/wordpress/ /var/www/html/
  mkdir /var/www/html/wp-content/uploads
  sudo chown -R apache:apache /var/www/html/*
  sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i s/database_name_here/wordpress/ /var/www/html/wp-config.php
  sed -i s/username_here/wordpressuser/ /var/www/html/wp-config.php
  sed -i s/password_here/root/ /var/www/html/wp-config.php
  echo "Finished"
}

# Runs the Individual Scripts
echo "Starting Script to set up WordPress"
install_apache
install_mysql
install_php
set_up_sql_user
install_wordpress
echo "Script Finished"