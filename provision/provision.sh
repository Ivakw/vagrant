#AUTHOR : PIUSHA KALYANA
#VERSION : 0.0.1
#THIS IS PROVISSION FILE FOR BASIC ENVIORNMENT FOR THE VAGRANT SERVER
#THIS INCLUDE MYSQL 6, PHP 5.6


sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'

# Variables
APPENV=local
DBHOST=localhost
DBNAME=default_db
DBUSER=root
DBPASSWD=rootpass
 
echo -e "\n--- Updating packages list ---\n"
sudo dpkg --clear-avail
sudo apt-get -qq update

echo -e "\n--- Installing packages list ---\n"
sudo apt-get install -y make
sudo apt-get install -y vim 
sudo apt-get install -y curl
sudo apt-get install -y openssl


#Install Mysql
sudo apt-get -y remove mysql-server
sudo apt-get -y autoremove
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:ondrej/mysql-5.6
sudo apt-get -y update
sudo apt-get -y install mysql-server

#Install Apache 
echo -e "\n--- Installing Apache ---\n"
sudo apt-get -y install apache2 

#Install PHP5
sudo apt-get install software-properties-common python-software-properties -y
sudo add-apt-repository ppa:ondrej/php5-5.6 -y
sudo apt-get -y update

#Install Git
sudo apt-get install -y git 

echo -e "\n-- Installing required Module to Environment ----- \n"
sudo apt-get -y install php5-common php5-dev php5-cli php5-fpm libapache2-mod-php5 
sudo apt-get -y install php5 php-pear php5-curl php5-mysql php5-gd php5-mcrypt curl php5-json php5-imagick



#Installin Composer
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#Install Modules
sudo apt-get -y install libapache2-mod-php5 php5-memcached memcached build-essential 
echo "extension=memcached.so" | sudo tee /etc/php5/conf.d/memcache.ini
ps aux | grep memcached
echo "stats settings" | nc localhost 11211


echo -e "\n--- Restarting Apache before host configs ---\n"
sudo service apache2 restart
 
echo -e "\n--- Enabling mod-rewrite ---\n"
sudo a2enmod rewrite 
 
echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf



echo -e "\n--- Creating Project Source directory ---\n"
sudo mkdir -p /var/www/application
sudo ln -s /web/application/* /var/www/application
sudo ln -s /web/application/vendor/* /var/www/application/vendor




echo -e "\n--- Sets the permissions for the sources ---\n"
sudo chown -R $USER:$USER /var/www/
sudo chmod -R 755 /var/www
sudo chmod -R g+w /var/www
sudo chown -R :vagrant /var/www
  


sudo ln -s /web/vhosts/* /etc/apache2/sites-available/

a2ensite application.conf


echo -e "\n--- Add environment variables to Apache ---\n"
sudo cp /web/vhosts/000-default.conf /etc/apache2/sites-available/


echo "ServerName 127.0.0.1" | sudo tee -a /etc/apache2/apache2.conf

echo -e "\n--- Add environment variables locally for artisan ---\n"
cat >> /home/vagrant/.bashrc <<EOF
 
# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD
EOF



echo -e "\n--- Setting up our MySQL user and db migrations/schema.sql ---\n"
mysqladmin -u root --password=$DBPASSWD create $DBNAME

echo -e "\n--- Checking SQL migrations "
#Installing the database
if [ -f /web/migrations/schema.sql ];
then
    sudo mysql -uroot -p$DBPASSWD $DBNAME < /web/migrations/schema.sql
fi

#Import Default Values
echo -e "\n--- Importing Default values to the table---\n"
if [ -f /web/migrations/insert_default.sql ];
then
    sudo mysql -uroot -p$DBPASSWD $DBNAME < /web/migrations/insert_default.sql
fi


sudo service apache2 restart

echo -e "\n--- Installing NodeJS...... ---\n"
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential


echo -e "\n Installing Bower JS ...... ---\n "
sudo npm install -g bower


	
# Victory!
echo "You're all done!  Your  Vagrant Laraval 5.1 development server is now running."


#Install Laraval Default packages
cd /web/application
composer install

#Install Bower Components
bower install -y
