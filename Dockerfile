FROM centos:7.4.1708

MAINTAINER Olivier Robert <robby57@gmail.com>

# Install necessary packages
RUN yum --setopt=tsflags=nodocs update -y && \
	curl -L -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
	curl -L -O http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
	rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm && \
	rm -f remi-release-7.rpm epel-release-latest-7.noarch.rpm && \
	yum-config-manager --enable remi-php70 && \
	yum --setopt=tsflags=nodocs install -y bzip2 httpd php php-mysql \
		php-mbstring php-cli php-xml php-gd php-imap php-ldap \
		php-opcache php-pecl-apcu php-xmlrpc && \
		yum install -y supervisor cronie && \
		yum clean all && rm -rf /var/cache/yum/*

# Get GLPI
RUN cd /tmp && curl -L -O https://github.com/glpi-project/glpi/releases/download/9.2/glpi-9.2.tgz && \
	cd /var/www/html && tar xvzf /tmp/glpi-9.2.tgz --strip 1 && chown -R apache.apache . && \
	rm -f /tmp/glpi-9.2.tgz

# Get fusioninventory
RUN cd /tmp && curl -L -O https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.2%2B1.0/glpi-fusioninventory-9.2.1.0.tar.bz2 && \
cd /var/www/html/plugins && tar xvjf /tmp/glpi-fusioninventory-9.2.1.0.tar.bz2 && \
chown -R apache.apache . && rm -f remove.txt glpi-fusioninventory-9.2.1.0.tar.bz2 /tmp/glpi-fusioninventory-9.2.1.0.tar.bz2

# Alter php.ini configuration
RUN sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php.ini && \
	sed -i 's/^;date.timezone =/date.timezone = Europe\/Paris/' /etc/php.ini

# Alter httpd.conf to allow htaccess
ADD conf/httpd.conf /etc/httpd/conf/httpd.conf

# Add cron entry for FusionInventory
ADD conf/crontab /etc/crontab

# Add supervisord configuration
ADD conf/svd_cron.ini /etc/supervisord.d/svd_cron.ini
ADD conf/svd_httpd.ini /etc/supervisord.d/svd_httpd.ini

# Change supervisord configuration to run in the foreground
RUN sed -i 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf

# Alter .htaccess for apache 2.4
ADD conf/htaccess /var/www/html/files/.htaccess

# Alter listening port
RUN sed -i 's/Listen 80/Listen 9000/' /etc/httpd/conf/httpd.conf

EXPOSE 9000
ENV PORT 9000

# Simple startup script to avoid some issues observed with container restart


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
