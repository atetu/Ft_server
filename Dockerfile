FROM debian:buster

ARG AUTOINDEX="on"

# INSTALLATIONS
RUN apt-get update 
	
RUN apt-get install -y nginx ; \
	apt-get install php php-common php-fpm php-mysql php-mbstring php-zip php-gd -y ; \
	apt-get install -y default-mysql-server ; \
	apt-get install unzip ; \
	apt-get install -y wget ; \
	apt-get install -y openssl; \
	apt-get install -y vim

# CONFIGURATION OF NGYNX
RUN rm /etc/nginx/sites-available/default 
COPY srcs/default /etc/nginx/sites-available/
RUN sed -i 's/%AUTO_INDEX%/'$AUTOINDEX'/g' /etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default 
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
COPY ./srcs/index.html /var/www/

#INSTALLATION OF SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt -subj "/C=US/ST=Utah/L=Lehi/O=Your Company, Inc./OU=IT/CN=yourdomain.com" 

# INSTALLATION OF PHPMYADMIN
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-all-languages.zip
RUN unzip phpMyAdmin-4.9.2-all-languages.zip
RUN mv phpMyAdmin-4.9.2-all-languages phpmyadmin
RUN mv phpmyadmin /var/www/
RUN rm -rf phpMyAdmin-4.9.2-all-languages.zip
RUN chmod 755 -R /var/www/phpmyadmin && chown -R www-data: /var/www/phpmyadmin
COPY srcs/config.inc.php /var/www/phpmyadmin/

#DATABASE WORDPRESS
RUN service mysql start ; \
	mysql --execute "CREATE USER 'user'@'localhost' IDENTIFIED BY '1111';CREATE DATABASE wordpress;GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';FLUSH PRIVILEGES;" 

##INSTALLATION OF WORD PRESS	
RUN wget -c http://fr.wordpress.org/latest-fr_FR.tar.gz ; \
	tar xf latest-fr_FR.tar.gz ; \
	mkdir /var/www/wordpress/ ;\
	mv wordpress/* /var/www/wordpress ; \ 
	rm latest-fr_FR.tar.gz ; \ 
	chmod 755 -R /var/www/wordpress ; \
	chown -R www-data: /var/www/wordpress
COPY srcs/wp-config.php /var/www/wordpress/

EXPOSE 80 443

CMD	service nginx start ; \
	service php7.3-fpm start ; \	
	service mysql restart ; \
	sleep infinity
