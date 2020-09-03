# WordPress Installation on CentOs 7:

**Steps to follow:**
1. Create a sudo user on the server
2. Install a LAMP stack:

	WordPress will need a web server, a database, and PHP in order to correctly function.
    Setting up a LAMP stack (Linux, Apache, MySQL, and PHP) fulfills all of these 	requirements.
    
    a. Installing apache and updating the firewall:
    
    Install Apache using CentOs’s package manager, yum:
    
		$ sudo yum update
		$ sudo yum install httpd -y
        $ sudo service apache2 start
        
    Setting up the firewall to allow HTTP/HTTPs traffic (UFW(uncomplicated firewall: the default firewall configuration tool for Ubuntu) 
    
    	$ sudo yum install firewalld 
        $ sudo firewall-cmd --permanent --add-service=http
        $ sudo firewall-cmd --permanent --add-service=https
        $ sudo firewall-cmd --reload
        
    Also ensure **Port Forwarding** rule is set for Port 80 on VM's Network settings 
        
   b. Installing mariadb server:
   		
        $ sudo yum install mariadb-server mariadb -y
  		$ sudo systemctl start mariadb
  		# mysql_secure_installation
        # 'password' variable contains the password user wants to set for root
        # Set a password for the database “root” user (different from the Linux root user!), which is blank by default.
  		$ mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root';"
  		# Delete “anonymous” users, i.e. users with the empty string as user name.
        $ mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
  		# Ensure the root user can not log in remotely.
        $ mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
  		# Remove the database named “test” and the priviledges.
  		$ mysql -u root -e "DROP DATABASE IF EXISTS test;"
  		$ mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
  		# Flush the privileges tables, i.e. ensure that the changes to user access applied in the previous steps are committed immediately.
  		$ mysql -u root -e "FLUSH PRIVILEGES;"
  		# Enabe mariadb server
        $ sudo systemctl enable mariadb.service
   
   c. Installing PHP:
   
   PHP will process code to display dynamic content. It can run scripts, connect to MySQL databases to get information, and hand the processed content over to your web server to display.
   
   		$ sudo yum install php php-mysql -y
        $ sudo systemctl restart httpd.service
   
	Optional: { Currently, if a user requests a directory from the server, Apache will first look for a index.html file. We want to tell the web server to prefer PHP files over others, so make Apache look for an index.php file first.
   
   		$ sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php/DirectoryIndex index.php index.html index.cgi index.pl/g' /etc/apache2/mods-enabled/dir.conf
	}     
    
3. Create MySQL Database and User for WordPress
		
    	$ mysql -u root -p$password -e "CREATE DATABASE IF NOT EXISTS db_name;"
  		$ mysql -u root -p$password -e "CREATE USER IF NOT EXISTS db_user@localhost IDENTIFIED BY 'db_user_password';"
  		# Give user permissions to access the database
        $ mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON db_name.* TO db_user@localhost IDENTIFIED BY 'db_user_password';"
	Replace db_name,db_user and db_user_password with your database name, database user and desired password(within '')
    
  		# flush MySQL so that it is made aware of above changes
        $ mysql -u root -p$password -e "FLUSH PRIVILEGES;"

4. Install WordPress:

		$ sudo yum install wget -y
        $ cd ~
        $ sudo systemctl restart httpd.service
        $ wget http://wordpress.org/latest.tar.gz
        # Unzip the tar file
        $ tar -xzvf latest.tar.gz
	
WordPress 5.2 onwards(or latest) require PHP version 5.6 or more. Since php 5.6 or more is not available in yum yet, we are going for installing WordPress 5.1 which is compatible with php 5.4 in yum.

		$ wget http://wordpress.org/wordpress-5.1.1.tar.gz
  		# Unzip the tar file
		$ tar -xzvf wordpress-5.1.1.tar.gz
	
          
   This should create a file named WordPress in the home directory. Now, move that file and its contents to our public_html folder, so that it can serve up the content for our website. We want to keep the same file permission, so we use the following rsync command. 
   
   		$ sudo rsync -avP ~/wordpress/ /var/www/html/
   
   For WordPress to be able to upload files, we need to create an uploads directory
   
   		$ mkdir /var/www/html/wp-content/uploads
        
   Update the Apache permissions for new WordPress files 
   
   		$ sudo chown -R apache:apache /var/www/html/*
        
5. Configure Wordpress:
   
   Go to /var/www/html and create a wp-config.php file by copying the sample file WordPress has provided.
   
   		$ sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        
   Now, edit the new wp-config.php file with the correct database information
   
   		$ sed -i s/database_name_here/db_name/ /var/www/html/wp-config.php
		$ sed -i s/username_here/db_user/ /var/www/html/wp-config.php
  		$ sed -i s/password_here/db_user_password/ /var/www/html/wp-config.php
        
	Replace db_name,db_user and db_user_password with your database name, database user and desired password
    
6. Include these steps in a shell script.
    
7. Run the Ansible script to install EC2 Instance(CentOs) and git clone the shell scripts to EC2 created.

8. Once the shell script has run successfully, Copy the public IP of the EC2 and paste it on a webbrowser and it should open up the WordPress set up webpage. Hence we have successfully verified the WordPress installed is working.   
	

 
