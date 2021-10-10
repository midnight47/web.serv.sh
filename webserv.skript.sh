#!/bin/bash
# Вывод цветных сообщений.
BLACK='\033[0;30m'     #  ${BLACK}   # чёрный цвет знаков
RED='\033[0;31m'       #  ${RED}     # красный цвет знаков
GREEN='\033[0;32m'     #  ${GREEN}   # зелёный цвет знаков
YELLOW='\033[0;33m'    #  ${YELLOW}  # желтый цвет знаков
BLUE='\033[0;34m'      #  ${BLUE}    # синий цвет знаков
MAGENTA='\033[0;35m'   #  ${MAGENTA} # фиолетовый цвет знаков
CYAN='\033[0;36m'      #  ${CYAN}    # цвет морской волны знаков
GRAY='\033[0;37m'      #  ${GRAY}    # серый цвет знаков
NORMAL='\033[0m'       #  ${NORMAL}  # все атрибуты по умолчанию
WHITE='\033[1;37m'     #  ${WHITE}

clear
p=`pwd`

function razryadnost_versia_OS {
#Данное условие проверяет разрядность системы 32/64  bit
if [ "$(uname -m)" == 'x86_64' ]
        then
        razrayd=64
        else
        razrayd=32
fi
veriaos=`cat /etc/redhat-release | awk -F 'release' '{print $2}' | awk -F '.' '{print $1}'`
if [[ "$veriaos" == ' 6'  ]]; then
        versiaOS=centos6
fi
if [[ "$veriaos" == ' 7' ]]; then
        versiaOS=centos7
fi
}

function proverka_ustanovlennogo_PO {
razryadnost_versia_OS
rpm -qa | grep -E 'httpd|nginx|mysql|maria|php|proftp|samba|openvpn|telnet|wget|vim|docker|php-fpm|php54-php-fpm|php55-php-fpm|php56-php-fpm|php70-php-fpm|php71-php-fpm|php72-php-fpm|yum-utils|net-tools|ansible' > $p/ustanovlennoe_PO
apache=`cat $p/ustanovlennoe_PO | grep httpd | awk -F '-' '{print $1}' | head -1`
nginx=`cat $p/ustanovlennoe_PO | grep nginx | awk -F '-' '{print $1}' | head -1`
mysql=`cat $p/ustanovlennoe_PO | grep -E 'mysql|maria' | grep server  | awk -F '-' '{print $1}' | head -1`
php=`cat $p/ustanovlennoe_PO | grep php | awk -F '-' '{print $1}' | head -1`
proftpd=`cat $p/ustanovlennoe_PO | grep proftp | awk -F '-' '{print $1}' | head -1`
samba=`cat $p/ustanovlennoe_PO | grep samba | head -1 | awk -F '-' '{print $1}'`
openvpn=`cat $p/ustanovlennoe_PO | grep openvpn | awk -F '-' '{print $1}' | head -1`
telnet=`cat $p/ustanovlennoe_PO | grep telnet | awk -F '-' '{print $1}' | head -1`
wget=`cat $p/ustanovlennoe_PO | grep wget | awk -F '-' '{print $1}' | head -1`
ansible=`cat $p/ustanovlennoe_PO | grep ansible | awk -F '-' '{print $1}' | head -1`
vim=`cat $p/ustanovlennoe_PO | grep vim |grep -v minimal| awk -F '-' '{print $1}' | head -1`
docker=`cat $p/ustanovlennoe_PO | grep docker | awk -F '-' '{print $1}' | head -1`
php_fpm=`cat $p/ustanovlennoe_PO | grep ^php-fpm | awk -F '-' '{print $1"-"$2}' | head -1`
yum_utils=`cat $p/ustanovlennoe_PO | grep ^yum-utils | awk -F '-' '{print $1"-"$2}' | head -1`
net_tools=`cat $p/ustanovlennoe_PO | grep net-tools | awk -F '-' '{print $1"-"$2}' | head -1`
php54_php_fpm=`cat $p/ustanovlennoe_PO | grep php54-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
php55_php_fpm=`cat $p/ustanovlennoe_PO | grep php55-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
php56_php_fpm=`cat $p/ustanovlennoe_PO | grep php56-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
php70_php_fpm=`cat $p/ustanovlennoe_PO | grep php70-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
php71_php_fpm=`cat $p/ustanovlennoe_PO | grep php71-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
php72_php_fpm=`cat $p/ustanovlennoe_PO | grep php72-php-fpm | awk -F '-' '{print $1"-"$2"-"$3}' | head -1`
rm -f $p/ustanovlennoe_PO

if [ "$apache" == 'httpd' ]
        then
        ap=y #апач установлен
                else
                ap=n
fi
if [ "$nginx" == 'nginx' ]
        then
        ng=y
                else
                ng=n
fi
if [[ "$nginx" == 'nginx' && "$ap" == 'y' ]];
        then
        port_nginx=80
        port_apache=8080
        fr_bk_end=y #frontend и backend установлены
                else
                fr_bk_end=n
                port_apache=80
fi
if [ "$mysql" == 'mysqld' ] || [ "$mysql" == 'mysql' ] || [ "$mysql" == 'mariadb' ];
        then
        mys=y #mysql установлен
                else
                mys=n
fi
if [ "$php" == 'php' ]
        then
        ph=y #php установлен
                else
                ph=n
fi


if [ "$wget" != 'wget' ]
        then
        yum -y install wget
fi

if [ "$vim" != 'vim' ]
        then
        yum -y install vim
fi

if [ "$telnet" != 'telnet' ]
        then
        yum -y install telnet
fi

if [ "$yum_utils" != 'yum-utils' ]
	then
	yum -y install yum-utils
fi
if [ "$net_tools" != 'net-tools' ]
        then
        yum -y install net-tools
fi

}

function podkluchenie_repozitoria_epel_centos6 {
razryadnost_versia_OS
Epel=`yum repolist | grep epel | head -1 | awk -F '*' '{print $2}' | awk -F ':' '{print $1}' | sed s/' '//g`

if [ "$Epel" != 'epel' ]; then
        yum -y install yum-utils yum-priorities
        if [ "$razrayd" == '64' ]; then
           echo -e "${YELLOW}Подключаем репозиторий Epel${NORMAL}"
           rpm --import http://elrepo.org/RPM-GPG-KEY-elrepo.org
           rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
              else
              echo -e "${YELLOW}Подключаем репозиторий Epel${NORMAL}"
              rpm --import http://elrepo.org/RPM-GPG-KEY-elrepo.org
              rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
        fi
fi
}

function podkluchenie_repozitoria_epel_centos7 {
razryadnost_versia_OS
Epel=`yum repolist | grep epel | head -1 | awk -F '*' '{print $2}' | awk -F ':' '{print $1}' | sed s/' '//g`
if [ "$Epel" != 'epel' ]; then
        yum -y install yum-utils yum-priorities
        yum -y install epel-release
fi
}

function podkluchenie_repozitoria_remi_centos6 {
razryadnost_versia_OS
rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`
if [ "$rem" != 'remi-safe' ]
        then
        rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
        rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
fi
}

function podkluchenie_repozitoria_remi_centos7 {
razryadnost_versia_OS
rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`
if [ "$rem" != 'remi-safe' ]
        then
        rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
        rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
fi
}


function ustanovka_apache_centos6 {
razryadnost_versia_OS
proverka_ustanovlennogo_PO
if [ "$ap" == 'n' ]
        then
        echo -e "${GREEN}Apache не установлен, установить?  y/n ?${NORMAL}"
        read otv_apach
                if [ "$otv_apach" == 'y' ]
                        then
                        podkluchenie_repozitoria_epel_centos6
                        echo ""
                        echo ""
                        echo -e "${RED}Мы ОТКЛЮЧИЛИ SELINUX чтобы можно было устаовить mod_fcgid${NORMAL}"
                        echo ""
                        echo ""
                        echo -e "${RED}После отключения SELINUX нужно перезагрузить сервер, чтобы изменения вступили в силу ${NORMAL}"
                        echo ""
                        echo ""
                        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

                        # В файле /etc/selinux/config была заменена строка SELINUX=enforcing на SELINUX=disabled

                        yum -y install httpd mod_fcgid
                        sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:80|' /etc/httpd/conf/httpd.conf
                        sed -i 's|#NameVirtualHost \*:80|NameVirtualHost \*:80|' /etc/httpd/conf/httpd.conf
                        sed -i 's|ServerTokens OS|ServerTokens ProductOnly|' /etc/httpd/conf/httpd.conf
                        sed -i 's|ServerSignature On|ServerSignature Off|' /etc/httpd/conf/httpd.conf
                        # ставим mod_rpaf, чтобы в логе Apache отображались корректные IP, а не 127.0.0.1

#                        yum -y install httpd-devel gcc
#                        echo "178.236.176.177 stderr.net" >> /etc/hosts
#                        wget http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz
#                        tar zxvf mod_rpaf-0.6.tar.gz
#                        rm -rf mod_rpaf-0.6.tar.gz
#                        sed -i '/178.236.176.177 stderr.net/ d' /etc/hosts
#                        cd mod_rpaf-0.6
#                        apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c

                        yum -y install httpd-devel gcc gcc-c++ unar
                        wget wget http://seak.ru/filez/mod_rpaf_2.0c_apache2.4.7.rar
#                        wget http://abcname.com.ua/torrent/mod_rpaf.tar.gz
#                        tar xzf mod_rpaf.tar.gz
			unar mod_rpaf_2.0c_apache2.4.7.rar
#                        rm -rf mod_rpaf.tar.gz
			rm -rf mod_rpaf_2.0c_apache2.4.7.rar
#                        cd mod_rpaf-0.6
			cd mod_rpaf_2.0c
                        apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
echo "LoadModule rpaf_module modules/mod_rpaf-2.0.so
# mod_rpaf configuration
RPAFenable On
RPAFsethostname On
RPAFproxy_ips 127.0.0.1
RPAFheader X-Forwarded-For" > /etc/httpd/conf.d/mod_rpaf.conf
                        chkconfig httpd on
                        service httpd start
                                else
                                exit 1;
                fi
fi
}

function ustanovka_apache_centos7 {
razryadnost_versia_OS
proverka_ustanovlennogo_PO
if [ "$ap" == 'n' ]
        then
        echo -e "${GREEN}Apache не установлен, установить?  y/n ?${NORMAL}"
        read otv_apach
                if [ "$otv_apach" == 'y' ]
                        then
                        podkluchenie_repozitoria_epel_centos7
                        echo ""
                        echo ""
                        echo -e "${RED}Мы ОТКЛЮЧИЛИ SELINUX чтобы можно было устаовить mod_fcgid${NORMAL}"
                        echo ""
                        echo ""
                        echo -e "${RED}После отключения SELINUX нужно перезагрузить сервер, чтобы изменения вступили в силу ${NORMAL}"
                        echo ""
                        echo ""
                        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

                        # В файле /etc/selinux/config была заменена строка SELINUX=enforcing на SELINUX=disabled

                        yum -y install httpd mod_fcgid
                        sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:80|' /etc/httpd/conf/httpd.conf
                        sed -i 's|#NameVirtualHost \*:80|NameVirtualHost \*:80|' /etc/httpd/conf/httpd.conf
                        sed -i 's|ServerTokens OS|ServerTokens ProductOnly|' /etc/httpd/conf/httpd.conf
                        sed -i 's|ServerSignature On|ServerSignature Off|' /etc/httpd/conf/httpd.conf
                        # ставим mod_rpaf, чтобы в логе Apache отображались корректные IP, а не 127.0.0.1

                        yum -y install httpd-devel gcc gcc-c++ unar


                        wget wget http://seak.ru/filez/mod_rpaf_2.0c_apache2.4.7.rar
                        unar mod_rpaf_2.0c_apache2.4.7.rar
                        cd mod_rpaf_2.0c
                        apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
#			wget http://abcname.com.ua/torrent/mod_rpaf.tar.gz
#                        tar xzf mod_rpaf.tar.gz
#                        rm -rf mod_rpaf.tar.gz
			sed -i 's|remote_ip|client_ip|g' $p/mod_rpaf_2.0c/mod_rpaf.c
			sed -i 's|remote_ip|client_ip|g' $p/mod_rpaf_2.0c/mod_rpaf-2.0.c	
			sed -i 's|remote_addr|client_addr|g' $p/mod_rpaf_2.0c/mod_rpaf.c
                        sed -i 's|remote_addr|client_addr|g' $p/mod_rpaf_2.0c/mod_rpaf-2.0.c
			cd $p/mod_rpaf_2.0c
			apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
echo "LoadModule rpaf_module modules/mod_rpaf-2.0.so
# mod_rpaf configuration
RPAFenable On
RPAFsethostname On
RPAFproxy_ips 127.0.0.1
RPAFheader X-Forwarded-For" > /etc/httpd/conf.d/mod_rpaf.conf
                        systemctl enable httpd
                        systemctl start httpd
                                else
                                exit 1;
                fi
fi
}

function ustanovka_nginx_centos6 {
razryadnost_versia_OS
proverka_ustanovlennogo_PO
if [[ "$ap" == 'y' && "$ng" == 'n' ]];
        then
        echo -e "${GREEN}Nginx не установлен, установить?  y/n ?${NORMAL}"
        read otv_nginx
                if [ "$otv_nginx" == 'y' ]
                        then
                        ng_rep=`yum repolist | grep nginx | awk '{print $1}'`
                                if [ "$ng_rep" != 'nginx' ]
                                        then
                                        rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
                                        ng_rep=`yum repolist | grep nginx | awk '{print $1}'`
                                fi
                                if [ "$ng_rep" == 'nginx' ]
                                        then
                                        yum -y install nginx
                                        #Создаём резервную копию конфиг файлов apache и nginx

                                        cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
                                        mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bkp

                                        #Меняем порты
                                        sed -i 's|^Listen 80$|Listen 8080|' /etc/httpd/conf/httpd.conf
                                        sed -i 's|^#ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
                                        sed -i 's|^#NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
                                        sed -i 's|^ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
                                        sed -i 's|^NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
echo "user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

        access_log  /var/log/nginx/access.log  main;
        error_log /var/log/nginx/error.log;

        client_max_body_size 50m;

        sendfile on;
        tcp_nopush on;
        server_tokens off;
        keepalive_timeout 65;
#gzip on;
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

    include /etc/nginx/conf.d/*.conf;

        server {
    listen 80 default;
    location ~ /.ht {
        deny all;
    }
    location / {
       proxy_pass http://127.0.0.1:8080;
    }
    error_page 404 /404.html;
       location = /404.html {
       root /usr/share/nginx/html;
    }
    error_page 500 502 503 504 /50x.html;
       location = /50x.html {
       root /usr/share/nginx/html;
    }
}
}" > /etc/nginx/nginx.conf
                                        chkconfig nginx on
                                        service httpd restart
                                        service nginx start
                                fi
                                #Закоменченные else exit 1; нужны для того, чтобы можно было работать как при связке apache nginx так и на голом apache
                                #else
                                #exit 1;
                fi
fi
}


function ustanovka_nginx_centos7 {
razryadnost_versia_OS
proverka_ustanovlennogo_PO
if [[ "$ap" == 'y' && "$ng" == 'n' ]];
        then
        echo -e "${GREEN}Nginx не установлен, установить?  y/n ?${NORMAL}"
        read otv_nginx
                if [ "$otv_nginx" == 'y' ]
                        then
			podkluchenie_repozitoria_epel_centos7
                        yum -y install nginx
                        #Создаём резервную копию конфиг файлов apache и nginx
                        cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
                        mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bkp
                        #Меняем порты
                        sed -i 's|^Listen 80$|Listen 8080|' /etc/httpd/conf/httpd.conf
                        sed -i 's|^#ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
                        sed -i 's|^#NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
                        sed -i 's|^ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
                        sed -i 's|^NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
echo "user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

        access_log  /var/log/nginx/access.log  main;
        error_log /var/log/nginx/error.log;

        client_max_body_size 50m;

        sendfile on;
        tcp_nopush on;
        server_tokens off;
        keepalive_timeout 65;
#gzip on;
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

    include /etc/nginx/conf.d/*.conf;

        server {
    listen 80 default;
    location ~ /.ht {
        deny all;
    }
    location / {
       proxy_pass http://127.0.0.1:8080;
    }
    error_page 404 /404.html;
       location = /404.html {
       root /usr/share/nginx/html;
    }
    error_page 500 502 503 504 /50x.html;
       location = /50x.html {
       root /usr/share/nginx/html;
    }
}
}" > /etc/nginx/nginx.conf
                                systemctl enable nginx
                                systemctl restart httpd
                                systemctl restart nginx
                                fi
                                #Закоменченные else exit 1; нужны для того, чтобы можно было работать как при связке apache nginx так и на голом apache
                                #else
                                #exit 1;
fi

}

function ustanovka_mysql_centos6 {
razryadnost_versia_OS
if [ "$mys" == 'n' ]
        then
        echo -e "${GREEN}Mysql не установлен, установить?  y/n ?${NORMAL}"
        read otv_mysql
                if [ "$otv_mysql" == 'y' ]
                        then
                        clear
                        echo -e "${YELLOW}Какую версию MYSQL Вы хотите установить:${NORMAL}"
                        echo -e "${WHITE}\"1\"${NORMAL} = ${RED}5.1${NORMAL}"
                        echo -e "${WHITE}\"2\"${NORMAL} = ${RED}5.5${NORMAL}"
                                read otv_ver_mysql
                                case $otv_ver_mysql in
                                1)
                                sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo 2>/dev/null
                                yum -y install mysql mysql-server
                                chkconfig mysqld on
                                service mysqld start
                                ;;
                                2)
                                podkluchenie_repozitoria_remi_centos6
                                sed -i '10c\enabled=1\' /etc/yum.repos.d/remi.repo
                                yum -y install mysql mysql-server
                                chkconfig mysqld on
                                service mysqld start
                                sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo
                                ;;
                                esac
                        echo ""
                        echo -e "${YELLOW}Произведём первоначальную настройку${NORMAL}"
                        echo ""
                        service mysqld restart
                        /usr/bin/mysql_secure_installation
                        else
                        #exit 1;
			echo ""
                fi
fi
}


function ustanovka_mysql_centos7 {
razryadnost_versia_OS
if [ "$mys" == 'n' ]
        then
        echo -e "${GREEN}Mysql не установлен, установить?  y/n ?${NORMAL}"
        read otv_mysql
                if [ "$otv_mysql" == 'y' ]
                        then
                        clear
                        echo -e "${YELLOW}Какую версию MYSQL Вы хотите установить:${NORMAL}"
                        echo -e "${WHITE}\"1\"${NORMAL} = ${RED}mariadb-5.5${NORMAL}"
                        echo -e "${WHITE}\"2\"${NORMAL} = ${RED}mysql-5.7${NORMAL}"
                                read otv_ver_mysql
                                case $otv_ver_mysql in
                                1)
                                yum -y install mysql mariadb-server
                                systemctl enable mariadb
                                systemctl start mariadb
				echo -e "${GREEN}При запросе пароля, нажмите ENTER:${NORMAL}"
                                ;;
                                2)
                                wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
				rpm -ivh mysql57-community-release-el7-9.noarch.rpm
				yum install -y mysql mysql-server
				systemctl enable mysqld
                                systemctl start mysqld
				echo -e "${GREEN}Временный пароль указанный при создании:${NORMAL}"
				sleep 2
				grep 'temporary password is generated' /var/log/mysqld.log | awk '{print $11}'
                                ;;
                                esac
                        echo ""
                        echo -e "${YELLOW}Произведём первоначальную настройку${NORMAL}"
                        echo ""
                        /usr/bin/mysql_secure_installation
                        else
#                        exit 1;
			echo ""
                fi
fi
}

function ustanovka_PHP_centos6 {
razryadnost_versia_OS
#proverka_ustanovlennogo_PO
if [ "$ph" == 'n' ]
        then
        echo -e "${GREEN}PHP не установлен, установить?  y/n ?${NORMAL}"
        read otv_php
                if [ "$otv_php" == 'y' ]
                        then
                        echo ""
                        echo -e "${YELLOW}Какую версию PHP Вы хотите установить:${NORMAL}"
                        echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}PHP.5.3${NORMAL}"
                        echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}PHP.5.4${NORMAL}"
                        echo -e "${WHITE}\"3\"${NORMAL} = ${YELLOW}PHP.5.5${NORMAL}"
                        echo -e "${WHITE}\"4\"${NORMAL} = ${YELLOW}PHP.5.6${NORMAL}"
			echo -e "${WHITE}\"5\"${NORMAL} = ${YELLOW}PHP.7.0${NORMAL}"
			echo -e "${WHITE}\"6\"${NORMAL} = ${YELLOW}PHP.7.1${NORMAL}"
			echo -e "${WHITE}\"7\"${NORMAL} = ${YELLOW}PHP.7.2${NORMAL}"
                        read otv_ver
                        case $otv_ver in
                        1)
			podkluchenie_repozitoria_epel_centos6
                        rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`
                        # Данное условие нужно, в случае если репозиторий remi уже был подключен и какую-то версию PHP уже ставили
                        if [ "$rem" == 'remi-safe' ]
                        then
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        fi
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        2)
                        podkluchenie_repozitoria_epel_centos6
                        podkluchenie_repozitoria_remi_centos6

                        #установка php5.4
                        sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '10c\enabled=1\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
			yum-config-manager --enable remi-php54
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        3)
                        podkluchenie_repozitoria_epel_centos6
			podkluchenie_repozitoria_remi_centos6

                        #установка php5.5
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=1\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
			yum-config-manager --enable remi-php55
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        4)
			podkluchenie_repozitoria_epel_centos6
                        podkluchenie_repozitoria_remi_centos6

                        #установка php5.6
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=1\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
			yum-config-manager --enable remi-php56
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
			;;
			5)
			podkluchenie_repozitoria_epel_centos6
                        podkluchenie_repozitoria_remi_centos6
			#установка php7.0
			sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
			yum-config-manager --enable remi-php70
			yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
			6)
			podkluchenie_repozitoria_epel_centos6
                        podkluchenie_repozitoria_remi_centos6
			#установка php7.1
			sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php71
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
			7)
			podkluchenie_repozitoria_epel_centos6
                        podkluchenie_repozitoria_remi_centos6
                        #установка php7.2
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php72
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
			;;
                        esac
                                        echo ""
                                        echo -e "${YELLOW}В каком режиме PHP должен работать?${NORMAL}"
                                        echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}Как модуль apache${NORMAL}"
                                        echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Как Fastcgi${NORMAL} ${RED}(Рекомендуется)${NORMAL}"
                                        read otv_rez_rab
                                        if [ "$otv_rez_rab" == '2' ]
                                                then
                                                yum -y install php-cgi mod_fcgid
                                                mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp
echo " # This is the Apache server configuration file for providing FastCGI support
# through mod_fcgid
#
# Documentation is available at
# http://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
LoadModule fcgid_module modules/mod_fcgid.so
# Use FastCGI to process .fcg .fcgi & .fpl scripts
AddHandler fcgid-script fcg fcgi fpl
# Sane place to put sockets and shared memory file
FcgidIPCDir /var/run/mod_fcgid
FcgidProcessTableFile /var/run/mod_fcgid/fcgid_shm
DirectoryIndex index.php
PHP_Fix_Pathinfo_Enable 1
FcgidMaxRequestLen 50000000" > /etc/httpd/conf.d/fcgid.conf
                                                sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
                                                echo ""
                                                echo "Wrapper будет добавлен при создании домена, так как владелец должен соответсвовать пользователю под которым будет работать сайт"
                                                echo ""
                                                else
                                                mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp #переименовываем так как в виртуалхосте всё равно будем подключать php5_module
                                                echo ""
                                                echo "OK PHP  будет работать как модуль apache"
                                                echo ""
                                        fi
                                else
                                exit 1;
                fi
fi
}


function ustanovka_PHP_centos7 {
razryadnost_versia_OS
#proverka_ustanovlennogo_PO
if [ "$ph" == 'n' ]
        then
        echo -e "${GREEN}PHP не установлен, установить?  y/n ?${NORMAL}"
        read otv_php
                if [ "$otv_php" == 'y' ]
                        then
                        echo ""
                        echo -e "${YELLOW}Какую версию PHP Вы хотите установить:${NORMAL}"
                        echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}PHP.5.4${NORMAL}"
                        echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}PHP.5.5${NORMAL}"
                        echo -e "${WHITE}\"3\"${NORMAL} = ${YELLOW}PHP.5.6${NORMAL}"
                        echo -e "${WHITE}\"4\"${NORMAL} = ${YELLOW}PHP.7.0${NORMAL}"
                        echo -e "${WHITE}\"5\"${NORMAL} = ${YELLOW}PHP.7.1${NORMAL}"
                        echo -e "${WHITE}\"6\"${NORMAL} = ${YELLOW}PHP.7.2${NORMAL}"
                        read otv_ver
                        case $otv_ver in
                        1)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7

                        #установка php5.4
                        sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '10c\enabled=1\' /etc/yum.repos.d/
remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/re
mi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php54
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        2)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7

                        #установка php5.5
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=1\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php55
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        3)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7

                        #установка php5.6
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=1\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php56
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        4)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7
                        #установка php7.0
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php70
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        5)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7
                        #установка php7.1
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php71
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        6)
                        podkluchenie_repozitoria_epel_centos7
                        podkluchenie_repozitoria_remi_centos7
                        #установка php7.2
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        yum-config-manager --enable remi-php72
                        yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc mod_fcgid
                        ;;
                        esac
                                        echo ""
                                        echo -e "${YELLOW}В каком режиме PHP должен работать?${NORMAL}"
                                        echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}Как модуль apache${NORMAL}"
                                        echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Как Fastcgi${NORMAL} ${RED}(Рекомендуется)${NORMAL}"
                                        read otv_rez_rab
                                        if [ "$otv_rez_rab" == '2' ]
                                                then
                                                yum -y install php-cgi mod_fcgid
                                                mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp
echo " # This is the Apache server configuration file for providing FastCGI support
# through mod_fcgid
#
# Documentation is available at
# http://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
LoadModule fcgid_module modules/mod_fcgid.so
# Use FastCGI to process .fcg .fcgi & .fpl scripts
AddHandler fcgid-script fcg fcgi fpl
# Sane place to put sockets and shared memory file
FcgidIPCDir /var/run/mod_fcgid
FcgidProcessTableFile /var/run/mod_fcgid/fcgid_shm
DirectoryIndex index.php
PHP_Fix_Pathinfo_Enable 1
FcgidMaxRequestLen 50000000" > /etc/httpd/conf.d/fcgid.conf
                                                sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
                                                echo ""
                                                echo "Wrapper будет добавлен при создании домена, так как владелец должен соответсвовать пользователю под которым будет работать сайт"
                                                echo ""
                                                else
                                                mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp #переименовываем так как в виртуалхосте всё равно будем подключать php5_module
                                                echo ""
                                                echo "OK PHP  будет работать как модуль apache"
                                                echo ""
                                        fi
                                else
                                exit 1;
                fi
fi
}


function virthost_apache_dobavlenie {
proverka_ustanovlennogo_PO
clear
if [ "$ng" == 'n' ] # если ранее nginx был установлен и порт был изменён то условие ниже вернёт апач на 80 порт
then
sed -i 's|^Listen 8080$|Listen 80|' /etc/httpd/conf/httpd.conf
sed -i 's|^ServerName www.example.com:8080$|ServerName www.example.com:80|' /etc/httpd/conf/httpd.conf
sed -i 's|^NameVirtualHost \*:8080$|NameVirtualHost \*:80|' /etc/httpd/conf/httpd.conf
sed -i 's|^#ServerName www.example.com:8080$|ServerName www.example.com:80|' /etc/httpd/conf/httpd.conf
sed -i 's|^#NameVirtualHost \*:8080$|NameVirtualHost \*:80|' /etc/httpd/conf/httpd.conf
fi

if [ "$ng" == 'y' ]
then
sed -i 's|^Listen 80$|Listen 8080|' /etc/httpd/conf/httpd.conf
sed -i 's|^ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
sed -i 's|^NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
sed -i 's|^#ServerName www.example.com:80$|ServerName www.example.com:8080|' /etc/httpd/conf/httpd.conf
sed -i 's|^#NameVirtualHost \*:80$|NameVirtualHost \*:8080|' /etc/httpd/conf/httpd.conf
fi

echo -e "${CYAN}Введите домен${NORMAL}"
read domen
echo ""
echo -e "${CYAN}Введите пользователя под которым будет работать сайт${NORMAL}"
read user
homedir="/var/www/$user"
proverka_usera=`awk -F ":" '{print $1}' /etc/passwd | grep "^$user$"`

if [ "$proverka_usera" != "$user" ]
        then
        echo ""
        echo -e "${RED}Извините, но такого пользователя нет, добавьте его${NORMAL}"
	echo ""
	echo -e "Добавить ${RED} $user ${NORMAL} y/n ??"
	read otv
		if [[ "$otv" == 'y' ]];
			then
			adduser $user
				else
				echo "ОК добавь сам и перезапусти скрипт $0"
			        exit 1;
		fi
fi
                echo ""
                echo -e "${CYAN}Выберите, PHP для сайта "$domen" будет работать как модуль APACHE или как FASTCGI?${NORMAL}"
                echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}модуль Apache ${NORMAL}"
                echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Fastcgi ${NORMAL}"
                read otv_rezima_raboti
                case $otv_rezima_raboti in
                                1)
php7=`php -v | head -1 | awk '{print $2}' | awk -F '.' '{print $1}'`
if [[ "$php7" != '7' ]];
then
echo "<VirtualHost *:$port_apache>
ServerAdmin webmaster@$domen
DocumentRoot $homedir/site/$domen
ServerName $domen
ServerAlias www.$domen
ErrorLog $homedir/logs/$domen.error.log
CustomLog $homedir/logs/$domen.access.log common
        <IfModule prefork.c>
          LoadModule php5_module modules/libphp5.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php5_module modules/libphp5-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>" > /etc/httpd/conf.d/$domen.conf
else
echo "<VirtualHost *:$port_apache>
ServerAdmin webmaster@$domen
DocumentRoot $homedir/site/$domen
ServerName $domen
ServerAlias www.$domen
ErrorLog $homedir/logs/$domen.error.log
CustomLog $homedir/logs/$domen.access.log common
        <IfModule prefork.c>
          LoadModule php7_module modules/libphp7.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php7_module modules/libphp7-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>" > /etc/httpd/conf.d/$domen.conf
fi

# ниже перечисленные условия, проверяют созданы ли директории/файлы и если не созданы, то создают
if ! [ -d $homedir/site/$domen/ ]; then
mkdir -p $homedir/site/$domen
fi

if ! [ -d $homedir/logs/ ]; then
mkdir $homedir/logs
fi

if ! [ -f $homedir/logs/$domen.error.log ]; then
touch $homedir/logs/$domen.error.log
fi

if ! [ -f $homedir/logs/$domen.access.log ]; then
touch $homedir/logs/$domen.access.log
fi
chown -R $user:$user $homedir

echo ""
echo -e "${WHITE}Проверям синтаксис apache, если ошибок нет apache будет перезагружен${NORMAL}"
echo ""
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax| grep 'Syntax OK'`
if [ "$apachSyntax" == 'Syntax OK' ]
	then
	if [[ "$versiaOS" == "centos6" ]];
        	then
		service httpd restart
	fi
	if [[ "$versiaOS" == "centos7" ]];
	        then
		systemctl restart httpd
	fi
fi
rm $p/peremen.syntax
                        ;;
                        2)
# если при установке PHP было указано, что PHP должен работать как модуль apache, а при добавлении домена решили установить его как Fastcgi, то условие ниже всё поправит.
                        if [ -f /etc/httpd/conf.d/php.conf ] || [ -f /etc/httpd/conf.d/php.conf.bkp ] ; then
                                if [ "$(rpm -qa | grep php-cli | awk -F "-" '{print $1"-"$2}')" != 'php-cli' ]; then
                                yum -y install php-cgi mod_fcgid
                                fi
                        if [ -f /etc/httpd/conf.d/php.conf ] ; then
                        mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp
                        fi
echo " # This is the Apache server configuration file for providing FastCGI support
# through mod_fcgid
#
# Documentation is available at
# http://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
LoadModule fcgid_module modules/mod_fcgid.so
# Use FastCGI to process .fcg .fcgi & .fpl scripts
AddHandler fcgid-script fcg fcgi fpl
# Sane place to put sockets and shared memory file
FcgidIPCDir /var/run/mod_fcgid
FcgidProcessTableFile /var/run/mod_fcgid/fcgid_shm
DirectoryIndex index.php
PHP_Fix_Pathinfo_Enable 1
FcgidMaxRequestLen 50000000" > /etc/httpd/conf.d/fcgid.conf
                         sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
                        fi
# условие завершено

echo "<VirtualHost *:$port_apache>
ServerAdmin webmaster@$domen
DocumentRoot $homedir/site/$domen
ServerName $domen
ServerAlias www.$domen
ErrorLog $homedir/logs/$domen.error.log
CustomLog $homedir/logs/$domen.access.log common
        <IfModule mod_fcgid.c>
        SuexecUserGroup $user $user
        <Directory $homedir/site/$domen>
        Options +ExecCGI
        AllowOverride All
        AddHandler fcgid-script .php
        FCGIWrapper $homedir/php-cgi/php.cgi .php
        Order allow,deny
        Allow from all
        </Directory>
        </IfModule>
</VirtualHost>" > /etc/httpd/conf.d/$domen.conf

# ниже перечисленные условия, проверяют созданы лы директории/файлы и если не созданы, то создают
if ! [ -d $homedir/site/$domen/ ]; then
mkdir -p $homedir/site/$domen
fi

if ! [ -d $homedir/logs/ ]; then
mkdir $homedir/logs
fi

if ! [ -d $homedir/php-cgi/ ]; then
mkdir $homedir/php-cgi/
fi

if ! [ -f $homedir/logs/$domen.error.log ]; then
touch $homedir/logs/$domen.error.log
fi

if ! [ -f $homedir/logs/$domen.access.log ]; then
touch $homedir/logs/$domen.access.log
fi

if ! [ -f $homedir/php-cgi/php.cgi ]; then
touch $homedir/php-cgi/php.cgi
echo "#!/bin/sh
PHPRC=$homedir/php-cgi/
export PHPRC
export PHP_FCGI_MAX_REQUESTS=500
exec /usr/bin/php-cgi" > $homedir/php-cgi/php.cgi

#В данном месте мы копируем php.ini, для того чтобы у каждого пользователя был свой (путь до php.ini указывается через параметр PHPRC, в FCGIWrapper -  php.cgi)
cp /etc/php.ini $homedir/php-cgi/
chmod +x $homedir/php-cgi/php.cgi
fi

chown -R $user:$user $homedir
echo ""
echo -e "${WHITE}Проверям синтаксис apache, если ошибок нет apache будет перезапущен${NORMAL}"
echo ""
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax| grep 'Syntax OK'`
if [ "$apachSyntax" == 'Syntax OK' ]
	then
	if [[ "$versiaOS" == "centos6" ]];
	        then
		service httpd restart
	fi
	if [[ "$versiaOS" == "centos7" ]];
	        then
		systemctl restart httpd
	fi
fi
rm $p/peremen.syntax
                        ;;
                        *)
                        ex='exit' # Данная переменная нужна для проверки, при добавлении домена.
                        echo "БЛЯТЬ по Русcки же написано 1 или 2, хренли ты мне тут пишешь $otv_rezima_raboti"
                        ;;
                        esac
}


function virthost_nginx_dobavlenie {
proverka_ustanovlennogo_PO
if [[ "$fr_bk_end" == 'y' && "$ng" == 'y' ]];
        then
        echo ""
        echo -e "${YELLOW}Включить gzip сжатие, на Nginx? y/n${NORMAL}"
        read otv_gzip
        case $otv_gzip in
                n)

echo "
server {
listen $port_nginx;
server_name $domen www.$domen;
access_log  $homedir/logs/$domen.nginx.access.log combined;
error_log   $homedir/logs/$domen.nginx.error.log error;
client_max_body_size 20m;
location ~* \.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|swf|js|html|htm|)$ {
root $homedir/site/$domen;
}
location / {
proxy_pass http://127.0.0.1:$port_apache;
proxy_set_header Host \$http_host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_pass_header Set-Cookie;
}
}" > /etc/nginx/conf.d/$domen.conf

# ниже перечисленные условия, проверяют созданы лы директории/файлы и если не созданы, то создают
if ! [ -d $homedir/site/$domen/ ]; then
mkdir -p $homedir/site/$domen
fi

if ! [ -d $homedir/logs/ ]; then
mkdir $homedir/logs
fi

if ! [ -f $homedir/logs/$domen.nginx.error.log ]; then
touch $homedir/logs/$domen.nginx.error.log
fi

if ! [ -f $homedir/logs/$domen.nginx.access.log ]; then
touch $homedir/logs/$domen.nginx.access.log
fi

chown -R $user:$user $homedir
                ;;
                y)

echo "
server {
listen $port_nginx;
server_name $domen www.$domen;
access_log  $homedir/logs/$domen.nginx.access.log combined;
error_log   $homedir/logs/$domen.nginx.error.log error;
client_max_body_size 20m;
gzip on;
gzip_buffers 16 8k;
gzip_comp_level 4;
gzip_min_length 1024;
gzip_types text/css text/plain text/json text/x-js text/javascript text/xml application/json application/x-javascript application/xml application/xml+rss application/javascript;
gzip_vary on;
gzip_http_version 1.0;
gzip_disable "msie6";
location ~* \.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|swf|js|html|htm|)$ {
root $homedir/site/$domen;
}
location / {
proxy_pass http://127.0.0.1:$port_apache;
proxy_set_header Host \$http_host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_pass_header Set-Cookie;
}
}" > /etc/nginx/conf.d/$domen.conf

# ниже перечисленные условия, проверяют созданы лы директории/файлы и если не созданы, то создают
if ! [ -d $homedir/site/$domen/ ]; then
mkdir -p $homedir/site/$domen
fi

if ! [ -d $homedir/logs/ ]; then
mkdir $homedir/logs
fi

if ! [ -f $homedir/logs/$domen.nginx.error.log ]; then
touch $homedir/logs/$domen.nginx.error.log
fi

if ! [ -f $homedir/logs/$domen.nginx.access.log ]; then
touch $homedir/logs/$domen.nginx.access.log
fi
chown -R $user:$user $homedir
                ;;
        esac
echo ""
echo -e "${WHITE}Проверям синтаксис nginx если ошибок нет, nginx будет перезапущен${NORMAL}"
echo ""
nginx -t  2> $p/peremen.ng
#echo "$ng1"
if [[ "$(cat $p/peremen.ng  | awk -F 'nginx.conf' '{print $2}' | head -1  | sed 's/^ //')" == 'syntax is ok' && "$(cat $p/peremen.ng  | awk -F 'nginx.conf' '{print $2}' | tail -1  | sed 's/^ //')"  == 'test is successful' ]];
	then
	if [[ "$versiaOS" == "centos6" ]];
	        then
		service nginx restart
	fi
	if [[ "$versiaOS" == "centos7" ]];
	        then
		systemctl restart nginx
	fi
fi
rm $p/peremen.ng
fi
}


function virthost_udalenie {
echo -e "${CYAN}Введите домен который хотите удалить${NORMAL}"

read domen
apach_conf=`find /etc/httpd/conf.d/ -name "$domen.conf" |grep -v docker`
nginx_conf=`find /etc/nginx/conf.d/ -name "$domen.conf"`
apache_conf_docker=`find /etc/httpd/conf.d/ -name "$domen.conf" |grep docker`
nginx_php_fpm_conf=`find /etc/nginx/conf.d/ -name "$domen"*"" | grep -i php_fpm`
if [ "$fr_bk_end" == 'y' ]
then
        if [ -f "$apach_conf" ] || [ -f "$nginx_conf" ] || [ -f "$apache_conf_docker" ] || [ -f "$nginx_php_fpm_conf" ];
                then
                echo ""
                echo -e "${WHITE}Вы уверены, что хотите удалить конфиги домена $domen ${NORMAL}"
                echo "$apach_conf"
                echo "$nginx_conf"
		echo "$apache_conf_docker"
		echo "$nginx_php_fpm_conf"
                echo ""
                echo -e "${WHITE}y/n ?${NORMAL}"
                read otv_p
                       if [ "$otv_p" == 'y' ]
                          then
                          rm -rf $apach_conf $nginx_conf $apache_conf_docker $nginx_php_fpm_conf 2>/dev/null
                          echo "Готово"
                       fi
        else
        echo -e "${WHITE}Такой домен отсутствует, проверьте верно ли Вы его указали${NORMAL}"
        fi
fi

#Данное условие нужно, в случае если nginx не был установлен
if [[ "$fr_bk_end" == 'n' && "$ap" == 'y' ]]; then
        if [ -f "$apach_conf" ]; then
        echo -e "${WHITE}Вы уверены, что хотите удалить конфиг домена $domen ${NORMAL}"
        echo "$apach_conf"
        echo ""
        echo -e "${WHITE}y/n ?${NORMAL}"
        read otv_p
                 if [ "$otv_p" == 'y' ]; then
                    rm -rf $apach_conf
                    echo "Готово"
                 fi
        else
        echo -e "${WHITE}Такой домен отсутствует, проверьте верно ли Вы его указали${NORMAL}"
        fi
fi
}

function rabota_s_bazoi {
if [[ "$mys" == 'y' ]] ;
then
echo -e "${CYAN}Создать/удалить базу данных или изменить пароль для пользователя?${NORMAL}"
echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}Создать ${NORMAL}"
echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Удалить ${NORMAL}"
echo -e "${WHITE}\"3\"${NORMAL} = ${YELLOW}Изменить ${NORMAL}"
echo -e "${WHITE}\"4\"${NORMAL} = ${YELLOW}Показать базы ${NORMAL}"
echo -e "${WHITE}\"5\"${NORMAL} = ${YELLOW}Ничего не делать ${NORMAL}"
read otv_base
case $otv_base in
        1)
        echo -e "${CYAN}Введите имя создаваемой базы${NORMAL}"
        read db1
        echo -e "${CYAN}Введите имя пользователя базы${NORMAL}"
        read username_db
        echo -e "${CYAN}Укажите пароль для пользователя $username_db базы $db ${NORMAL}"
        read pass_user
        user=`echo $username_db`
        pass=`echo $pass_user`
        db=`echo $db1`
        zapr="CREATE DATABASE $db;"
        zapr2="CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';"
        zapr3="GRANT ALL PRIVILEGES ON $db.* TO $user@localhost;"
        echo ""
        echo -e "${CYAN}Введите пароль от ROOT mysql${NORMAL}"
mysql -u root -p << EOF
$zapr
$zapr2
$zapr3
FLUSH PRIVILEGES ;
EOF
        ;;
        2)
        zapr1="show databases;"
        echo -e "${CYAN}Ниже предоставлен список всех баз${NORMAL}"
        echo ""
mysql -u root -p << EOF
$zapr1
EOF
        echo ""
        echo -e "${CYAN}Введите имя удаляемой базы${NORMAL}"
        read db1
        echo ""
        echo -e "${CYAN}Ниже предоставлен список всех пользователей${NORMAL}"
        echo ""
        zapr3="SELECT User,Host FROM mysql.user;"
mysql -u root -p << EOF
$zapr3
EOF
        echo ""
        echo -e "${CYAN}Введите имя пользователя базы${NORMAL}"
        read username_db
        user=`echo $username_db`
        db=`echo $db1`
        zapr="DROP DATABASE $db;"
        zapr2="DROP USER '$user'@'localhost';"
        echo -e "${CYAN}Введите пароль от ROOT mysql${NORMAL}"
mysql -u root -p << EOF
$zapr
$zapr2
FLUSH PRIVILEGES ;
EOF
        ;;
        3)
        echo -e "${CYAN}Введите имя пользователя базы${NORMAL}"
        read username_db
        user=`echo $username_db`
        echo -e "${CYAN}Укажите новый пароль для пользователя $username_db ${NORMAL}"
        read pass_user
        pass=`echo $pass_user`
        zapr="update mysql.user set password=PASSWORD('$pass') where User='$user';"
        echo -e "${CYAN}Введите пароль от ROOT mysql${NORMAL}"
mysql -u root -p << EOF
$zapr
FLUSH PRIVILEGES ;
EOF
        ;;
        4)
        zapr="show databases;"
mysql -u root -p << EOF
$zapr
EOF
        ;;
        5|*)
        echo "Ok"
        ;;
esac
#изменить пароль для пользователя update mysql.user set password=PASSWORD('NEW-PASSWORD-HERE') where User='John';
#удалить пользователя DROP USER 'testuser'@'localhost';
#удалить базу данных drop database test;
#создать пользователя CREATE USER "$username_db"@"localhost" IDENTIFIED BY "$pass_user";
#дать полные права пользователю к базе GRANT ALL PRIVILEGES ON "$db".* TO "$username_db"@"localhost";
#FLUSH PRIVILEGES;
fi
}
#############################################################

#############################################################
function razmer_zagruzaemogo_faila {
echo ""
echo -e "${YELLOW}Какой размер файла сможет загружать данный пользователь через админку сайта?${NORMAL}"
echo -e "${CYAN}Размер указывайте в Mb${NORMAL}"
read razmer
#правим php.ini пользовательский
# устанавливаем upload_max_filesize
nomer_up_max=`cat -n $homedir/php-cgi/php.ini | grep upload_max_filesize | awk '{print $1}'`
#заменяем данную строку
sed -i "${nomer_up_max}c upload_max_filesize = ${razmer}M" $homedir/php-cgi/php.ini
# устанавливаем post_max_size
nomer_post_max=`cat -n $homedir/php-cgi/php.ini | grep post_max_size | awk '{print $1}'`
sed -i "${nomer_post_max}c post_max_size = ${razmer}M" $homedir/php-cgi/php.ini


# устанавливаем client_max_body_size у nginx
if [ "$ex" != 'exit' ]
                then
                nomer_max_body=`cat -n /etc/nginx/conf.d/$domen.conf | grep client_max_body_size | awk '{print $1}'`
                sed -i "${nomer_max_body}c client_max_body_size ${razmer}m;" /etc/nginx/conf.d/$domen.conf
fi

# устанавливаем FcgidMaxRequestLen для fastcgi
nomer_Fcg=`cat -n /etc/httpd/conf.d/fcgid.conf | grep FcgidMaxRequestLen | awk '{print $1}'`
razmer2="1000000"
razmer_itog="$(($razmer * $razmer2))"
ishodnij_razmer=`cat -n /etc/httpd/conf.d/fcgid.conf | grep FcgidMaxRequestLen | awk '{print $3}'`
if [[ "$ishodnij_razmer" -gt "$razmer_itog" ]]; # если исходное значение больше устанавливаемого то не изменяем его
        then
        service nginx restart
        service httpd restart
                else
                sed -i "${nomer_Fcg}c FcgidMaxRequestLen ${razmer_itog}" /etc/httpd/conf.d/fcgid.conf
                service nginx restart
                service httpd restart
fi
}

function ustanovka_alternativnih_wersij_php {
rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`
                        # Данное условие нужно, в случае если репозиторий remi уже был подключен и какую-то версию PHP уже ставили
                        if [ "$rem" == 'remi-safe' ]
                        then
                        sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php54.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php70.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php71.repo && sed -i '9c\enabled=0\' /etc/yum.repos.d/remi-php72.repo
                        fi


mysql55=`mysql -V | awk '{print $5}' | cut -c1-3` #5.5




versiaphp=`php -v | grep cli | awk '{print $2}' | head -1 | awk -F '.' '{print $1"."$2}'`
case $versiaphp in
        5.3)
        echo ""
        ;;
        5.4)
        yum-config-manager --enable remi-php54
        ;;
	5.5)
	yum-config-manager --enable remi-php55
        ;;
        5.6)
        yum-config-manager --enable remi-php56
        ;;
        7.0)
        yum-config-manager --enable remi-php70
        ;;
        7.1)
        yum-config-manager --enable remi-php71
        ;;
        7.2)
        yum-config-manager --enable remi-php72
        ;;
esac



lst="libxml2-devel httpd-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel libcurl-devel libjpeg-devel  libvpx-devel libpng-devel freetype-devel readline-devel libtidy-devel libxslt-devel httpd-devel libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl curl-devel libjpeg libpng libpng-devel libXpm-devel freetype-devel t1lib-devel gmp-devel libicu-devel libmcrypt libmcrypt-devel aspell-devel libtidy libtidy-devel libxslt-devel libwebp-devel gcc-c++ wget gcc libxml2-devel openssl-devel libcurl-devel libpng-devel libmcrypt-devel mysql-devel libtidy-devel libtool-ltdl-devel mhash mhash-devel glibc-headers man zip unzip php-common php-mbstring php-gd php-ldap php-odbc php-pear php-xml php-soap curl curl-devel php-xmlrpc php-snmp libjpeg-turbo-devel"

rpm -qa 2>/dev/null > $p/ls.tmp
for items in $lst
do
  cmd=`grep $items $p/ls.tmp`
  if [[ "$cmd" != "" ]];
    then
      echo -e "$items installed ${WHITE}(установлен)${NORMAL}"
    else
      echo -e "$items NOT installed ${RED}(не установлен)${NORMAL}"
        yum -y install $items
  fi
done
rm -rf $p/ls.tmp

if [[ "$mysql55" == "5.5" ]] || [[ "$mysql55" == "5.6" ]];
        then
        yum --enablerepo=remi install -y mysql-devel
        else
        yum install -y mysql-devel
fi

function ustanovkaPHP5.3.9 {
if ! [ -d /opt/alt.php/php5.3.9/ ]; # начало условия (собрана пыха.5.3.9 или нет)
        then
        mkdir -p /opt/alt.php/php5.3.9/
        cd /opt/alt.php
        wget http://museum.php.net/php5/php-5.3.9.tar.gz
        tar xvfz php-5.3.9.tar.gz
        cd /opt/alt.php/php-5.3.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php5.3.9/ --with-config-file-path=/opt/alt.php/php5.3.9/ --with-config-file-scan-dir=/opt/alt.php/php5.3.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl --with-libdir=lib --with-xpm-dir=/usr
make
make install
cd ~/
rm -rf /opt/alt.php/php-5.3.9 /opt/alt.php/php-5.3.9.tar.gz
mkdir /opt/alt.php/php5.3.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php5.3.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php5.3.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php5.3.9/bin/php-cgi" > /opt/alt.php/php5.3.9/wrapper.php5.3.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php5.3.9/
cp /etc/php.ini /opt/alt.php/php5.3.9/php.d/

else
echo "Директория /opt/alt.php/php5.3.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.5.3.9 или нет)
}

function ustanovkaPHP5.4.9 {
if ! [ -d /opt/alt.php/php5.4.9/ ]; # начало условия (собрана пыха.5.4.9 или нет)
        then
        mkdir -p /opt/alt.php/php5.4.9/
        cd /opt/alt.php
        wget http://museum.php.net/php5/php-5.4.9.tar.gz
        tar xfvz php-5.4.9.tar.gz
        cd /opt/alt.php/php-5.4.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php5.4.9/ --with-config-file-path=/opt/alt.php/php5.4.9/ --with-config-file-scan-dir=/opt/alt.php/php5.4.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl --with-vpx-dir=/usr --with-libdir=lib --with-xpm-dir=/usr
make
make install
cd ~/
rm -rf /opt/alt.php/php-5.4.9 /opt/alt.php/php-5.4.9.tar.gz
mkdir /opt/alt.php/php5.4.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php5.4.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php5.4.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php5.4.9/bin/php-cgi" > /opt/alt.php/php5.4.9/wrapper.php5.4.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php5.4.9/
cp /etc/php.ini /opt/alt.php/php5.4.9/php.d/

else
echo "Директория /opt/alt.php/php5.4.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.5.4.9 или нет)
}


function ustanovkaPHP5.5.9 {
if ! [ -d /opt/alt.php/php5.5.9/ ]; # начало условия (собрана пыха.5.5.9 или нет)
        then
        mkdir -p /opt/alt.php/php5.5.9/
        cd /opt/alt.php
        wget http://museum.php.net/php5/php-5.5.9.tar.gz
        tar xvfz php-5.5.9.tar.gz
        cd /opt/alt.php/php-5.5.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php5.5.9/ --with-config-file-path=/opt/alt.php/php5.5.9/ --with-config-file-scan-dir=/opt/alt.php/php5.5.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
cd ~/
rm -rf /opt/alt.php/php-5.5.9 /opt/alt.php/php-5.5.9.tar.gz
mkdir /opt/alt.php/php5.5.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php5.5.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php5.5.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php5.5.9/bin/php-cgi" > /opt/alt.php/php5.5.9/wrapper.php5.5.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php5.5.9
cp /etc/php.ini /opt/alt.php/php5.5.9/php.d/

else
echo "Директория /opt/alt.php/php5.5.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.5.5.9 или нет)
}

function ustanovkaPHP5.6.9 {
if ! [ -d /opt/alt.php/php5.6.9/ ]; # начало условия (собрана пыха.5.6.9 или нет)
        then
        mkdir -p /opt/alt.php/php5.6.9/
        cd /opt/alt.php
        wget http://museum.php.net/php5/php-5.6.9.tar.gz
        tar xvfz php-5.6.9.tar.gz
        cd /opt/alt.php/php-5.6.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php5.6.9/ --with-config-file-path=/opt/alt.php/php5.6.9/ --with-config-file-scan-dir=/opt/alt.php/php5.6.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
cd ~/
rm -rf /opt/alt.php/php-5.6.9 /opt/alt.php/php-5.6.9.tar.gz
mkdir /opt/alt.php/php5.6.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php5.6.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php5.6.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php5.6.9/bin/php-cgi" > /opt/alt.php/php5.6.9/wrapper.php5.6.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php5.6.9/
cp /etc/php.ini /opt/alt.php/php5.6.9/php.d/

else
echo "Директория /opt/alt.php/php5.6.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.5.6.9 или нет)
}

function ustanovkaPHP7.0.9 {
if ! [ -d /opt/alt.php/php7.0.9/ ]; # начало условия (собрана пыха.7.0.9 или нет)
        then
        mkdir -p /opt/alt.php/php7.0.9/
        cd /opt/alt.php
        wget http://museum.php.net/php7/php-7.0.9.tar.gz
        tar xvfz php-7.0.9.tar.gz
        cd /opt/alt.php/php-7.0.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php7.0.9/ --with-config-file-path=/opt/alt.php/php7.0.9/ --with-config-file-scan-dir=/opt/alt.php/php7.0.9/php.d/  --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
cd ~/
rm -rf /opt/alt.php/php-7.0.9 /opt/alt.php/php-7.0.9.tar.gz
mkdir /opt/alt.php/php7.0.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php7.0.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php7.0.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php7.0.9/bin/php-cgi" > /opt/alt.php/php7.0.9/wrapper.php7.0.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php7.0.9/
cp /etc/php.ini /opt/alt.php/php7.0.9/php.d/

else
echo "Директория /opt/alt.php/php7.0.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.7.0.9 или нет)
}

function ustanovkaPHP7.1.9 {
if ! [ -d /opt/alt.php/php7.1.9/ ]; # начало условия (собрана пыха.7.1.9 или нет)
        then
        mkdir -p /opt/alt.php/php7.1.9/
        cd /opt/alt.php
        wget http://museum.php.net/php7/php-7.1.9.tar.gz
        tar xvfz php-7.1.9.tar.gz
        cd /opt/alt.php/php-7.1.9/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php7.1.9/ --with-config-file-path=/opt/alt.php/php7.1.9/ --with-config-file-scan-dir=/opt/alt.php/php7.1.9/php.d/  --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
cd ~/
rm -rf /opt/alt.php/php-7.1.9 /opt/alt.php/php-7.1.9.tar.gz
mkdir /opt/alt.php/php7.1.9/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php7.1.9/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php7.1.9"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php7.1.9/bin/php-cgi" > /opt/alt.php/php7.1.9/wrapper.php7.1.9.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php7.1.9/
cp /etc/php.ini /opt/alt.php/php7.1.9/php.d/

else
echo "Директория /opt/alt.php/php7.1.9/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.7.1.9 или нет)
}

function ustanovkaPHP7.2.5 {
if ! [ -d /opt/alt.php/php7.2.5/ ]; # начало условия (собрана пыха.7.2.5 или нет)
        then
        mkdir -p /opt/alt.php/php7.2.5/
        cd /opt/alt.php
        wget https://museum.php.net/php7/php-7.2.5.tar.xz
	tar vxpJf php-7.2.5.tar.xz
	mv /opt/alt.php/php-7.2.5/* /opt/alt.php/php7.2.5/
        cd /opt/alt.php/php7.2.5/
if ! [ -f /usr/lib/libXpm.so ]; then
ln -s /usr/lib64/libXpm.so /usr/lib/libXpm.so
fi
./configure --prefix=/opt/alt.php/php7.2.5/ --with-config-file-path=/opt/alt.php/php7.2.5/ --with-config-file-scan-dir=/opt/alt.php/php7.2.5/php.d/  --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
cd ~/
rm -rf /opt/alt.php/php-7.2.5 /opt/alt.php/php-7.2.5.tar.xz
mkdir /opt/alt.php/php7.2.5/php.d/
cp /etc/php.d/*.ini /opt/alt.php/php7.2.5/php.d/

#создаём wrapper
echo "#!/bin/sh
PHPRC="/opt/alt.php/php7.2.5"
export PHPRC
PHP_FCGI_CHILDREN=4
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=5000
export PHP_FCGI_MAX_REQUESTS
exec /opt/alt.php/php7.2.5/bin/php-cgi" > /opt/alt.php/php7.2.5/wrapper.php7.2.5.cgi
#создаём wrapper
cp /etc/php.ini /opt/alt.php/php7.2.5/
cp /etc/php.ini /opt/alt.php/php7.2.5/php.d/

else
echo "Директория /opt/alt.php/php7.2.5/ уже создана, походу пыха уже собрана или собиралась. Работа данной функции завершается"
#exit 1;
fi  # конец условия (собрана пыха.7.2.5 или нет)
}

clear
echo ""
echo -e "${WHITE}Какую версию php нужно собрать?${NORMAL}"
if [[ "$versiaOS" == "centos6" ]];
	then
	echo -e "${WHITE}\"3\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.3.9${NORMAL}"
fi
echo -e "${WHITE}\"4\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.4.9${NORMAL}"
echo -e "${WHITE}\"5\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.5.9${NORMAL}"
echo -e "${WHITE}\"6\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.6.9${NORMAL}"
echo -e "${WHITE}\"7\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.0.9${NORMAL}"
echo -e "${WHITE}\"71\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.1.9${NORMAL}"
echo -e "${WHITE}\"72\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.2.5${NORMAL}"
if [[ "$versiaOS" == "centos6" ]];
        then
	echo -e "${WHITE}\"0\"${NORMAL} = ${BLUE}Установить ВСЁ ${YELLOW}5.3 - 7.2${NORMAL}"
fi
if [[ "$versiaOS" == "centos7" ]];
	then
	echo -e "${WHITE}\"0\"${NORMAL} = ${BLUE}Установить ВСЁ ${YELLOW}5.4 - 7.2${NORMAL}"
fi
echo ""
echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}Выйти из установки${NORMAL}"
read otv_ver
case $otv_ver in
1)
skript
;;
3)
ustanovkaPHP5.3.9
;;
4)
ustanovkaPHP5.4.9
;;
5)
ustanovkaPHP5.5.9
;;
6)
ustanovkaPHP5.6.9
;;
7)
ustanovkaPHP7.0.9
;;
71)
ustanovkaPHP7.1.9
;;
72)
ustanovkaPHP7.2.5
;;
0)
if [[ "$versiaOS" == "centos6" ]]; 
	then
		if ! [ -d /opt/alt.php/php5.3.9/ ];
		        then
	                ustanovkaPHP5.3.9
        	fi
fi
if ! [ -d /opt/alt.php/php5.4.9/ ];
        then
        ustanovkaPHP5.4.9
fi
if ! [ -d /opt/alt.php/php5.5.9/ ];
        then
        ustanovkaPHP5.5.9
fi
if ! [ -d /opt/alt.php/php5.6.9/ ];
        then
        ustanovkaPHP5.6.9
fi
if ! [ -d /opt/alt.php/php7.0.9/ ];
        then
        ustanovkaPHP7.0.9
fi
if ! [ -d /opt/alt.php/php7.1.9/ ];
        then
        ustanovkaPHP7.1.9
fi
if ! [ -d /opt/alt.php/php7.2.5/ ];
        then
        ustanovkaPHP7.2.5
fi
;;
esac
}

function izmenenie_versii_php_dlya_sajta {

if [ -d /opt/alt.php/php5.3.9/ ];
        then
        echo "5.3.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php5.4.9/ ];
        then
        echo "5.4.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php5.5.9/ ];
        then
        echo "5.5.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php5.6.9/ ];
        then
        echo "5.6.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php7.0.9/ ];
        then
        echo "7.0.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php7.1.9/ ];
        then
        echo "7.1.9" >> $p/phpversii.txt
fi
if [ -d /opt/alt.php/php7.2.5/ ];
        then
        echo "7.2.5" >> $p/phpversii.txt
fi
provphpversij=`cat $p/phpversii.txt 2>&1  | grep 'such file' | awk '{print $3, $4, $5}' | tr "[A-Z]" "[a-z]"`
if [[ "$provphpversij" != 'no such file' ]]; # открыл условие на наличие альтернативной версии php
then
phpversii=`cat $p/phpversii.txt` 
grep -r ServerName /etc/httpd/conf.d/ | grep -v docker > $p/saiti.txt
saiti=`cat $p/saiti.txt | awk '{print $2}'`
clear
echo -e "${CYAN}Для какого сайта необходимо изменить версию PHP?${NORMAL}"
echo "$saiti"
echo ""
echo -e "${CYAN}Введи домен:${NORMAL}"
echo ""
read viborsaita
clear
urlkonfiga=`grep "ServerName $viborsaita" $p/saiti.txt | awk -F ':' '{print $1}'`
imya_user=`cat $urlkonfiga | grep SuexecUserGroup |awk '{print $2}'`
put_do_wrap=`cat $urlkonfiga | grep FCGIWrapper`
nomer_wrap=`cat -n $urlkonfiga | grep FCGIWrapper |awk '{print $1}'`
echo -e "${CYAN}Доступны следующие версии PHP:${NORMAL}"
echo -e "${YELLOW}$phpversii${NORMAL}"
nativnaya=`php -v | head -1`
echo ""
echo -e "${CYAN}Чтобы выбрать нативную версию PHP:${NORMAL} $nativnaya"
echo -e "${CYAN}Выбери${NORMAL} ${WHITE}0${NORMAL}"
rm -rf $p/phpversii.txt $p/saiti.txt 2>/dev/null

echo ""
echo -e "${CYAN}Укажи какую версию ${YELLOW}PHP ${CYAN}необходимо задать для сайта ${WHITE}$viborsaita${NORMAL}"
echo ""
read otv_versiaphp
clear
echo -e "${CYAN}Изменения будут внесены в конфиг файл: ${WHITE}$urlkonfiga${NORMAL}"
case $otv_versiaphp in

5.3.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php5.3.9/wrapper.php5.3.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.3.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.3.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.3.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php5.3.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php5.3.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.3.9.cgi
cp -f /opt/alt.php/php5.3.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
	then
	service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;

5.4.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php5.4.9/wrapper.php5.4.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.4.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.4.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.4.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php5.4.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php5.4.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.4.9.cgi
cp -f /opt/alt.php/php5.4.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;

5.5.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php5.5.9/wrapper.php5.5.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.5.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.5.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.5.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php5.5.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php5.5.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.5.9.cgi
cp -f /opt/alt.php/php5.5.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;

5.6.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php5.6.9/wrapper.php5.6.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.6.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.6.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.6.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php5.6.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php5.6.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php5.6.9.cgi
cp -f /opt/alt.php/php5.6.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;

7.0.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php7.0.9/wrapper.php7.0.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.0.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.0.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.0.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php7.0.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php7.0.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.0.9.cgi
cp -f /opt/alt.php/php7.0.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;

7.1.9)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php7.1.9/wrapper.php7.1.9.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.1.9.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.1.9.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.1.9.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php7.1.9.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php7.1.9|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.1.9.cgi
cp -f /opt/alt.php/php7.1.9/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax

;;
7.2.5)
rm -rf /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php* 2>/dev/null
cp -f /opt/alt.php/php7.2.5/wrapper.php7.2.5.cgi /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.2.5.cgi
chmod +x /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.2.5.cgi
chown $imya_user:$imya_user /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.2.5.cgi
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/wrapper.${viborsaita}.php7.2.5.cgi .php|" $urlkonfiga
sed -i "s|PHPRC=/opt/alt.php/php7.2.5|PHPRC=/var/www/${imya_user}/php-cgi/${viborsaita}.php.ini|" /var/www/$imya_user/php-cgi/wrapper.$viborsaita.php7.2.5.cgi
cp -f /opt/alt.php/php7.2.5/php.ini /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
chown $imya_user:$imya_user /var/www/${imya_user}/php-cgi/${viborsaita}.php.ini
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;
0)
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/php.cgi .php|" $urlkonfiga
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
fi
fi
rm $p/peremen.syntax
;;
esac


###############################################   функция для удаления конфиг файлов если сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
###############################################


#urlkonfiga_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep PHP_FPM`
#urlkonfiga_nginx_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep -v PHP_FPM | grep .back`
#if [[ -f $urlkonfiga_php_fpm ]]; 
#	then
#	rm -rf $urlkonfiga_php_fpm
#	if [[ -f $urlkonfiga_nginx_php_fpm ]] ;
#		then
#		urlkonfiga_nginx_without_php_fpm=`echo $urlkonfiga_nginx_php_fpm | awk -F '.back' '{print $1}'`
#		mv $urlkonfiga_nginx_php_fpm $urlkonfiga_nginx_without_php_fpm
#	fi
#fi
	
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8080;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
else 
ustanovka_alternativnih_wersij_php
izmenenie_versii_php_dlya_sajta
fi # закрыл условие на наличие альтернативной версии php
}

function ustanovka_phpmyadmin {

function proverka_ustanovlennogo_PO2 {
apache=`chkconfig | grep httpd | awk '{print $1}' | head -1`
nginx=`chkconfig | grep nginx | awk '{print $1}' | head -1`
mysql=`chkconfig | grep mysqld | awk '{print $1}' | head -1`
PHP=`yum list installed | grep php |  head -1| awk -F '.' '{print $1}' | tr '[A-Z]' '[a-z]'`
if [ "$apache" == 'httpd' ]
        then
        ap=y #апач установлен
                else
                ap=n
fi
if [ "$nginx" == 'nginx' ]
        then
        ng=y
                else
                ng=n
fi
if [[ "$nginx" == 'nginx' && "$ap" == 'y' ]];
        then
        port_nginx=80
        port_apache=8080
        fr_bk_end=y #frontend и backend установлены
                else
                fr_bk_end=n
                port_apache=80
fi
if [ "$mysql" == 'mysqld' ]
        then
        mys=y #mysql установлен
                else
                mys=n
fi
if [ "$PHP" == 'php' ]
        then
        ph=y #php установлен
                else
                ph=n
fi
}


function phpmyadminapache {
# если при установке PHP было указано, что PHP должен работать как модуль apache, а при добавлении домена решили установить его как Fastcgi, то условие ниже всё поправит.
                        if [ -f /etc/httpd/conf.d/php.conf ] || [ -f /etc/httpd/conf.d/php.conf.bkp ] ; then
                                if [ "$(rpm -qa | grep php-cli | awk -F "-" '{print $1"-"$2}')" != 'php-cli' ]; then
                                yum -y install php-cgi
                                fi
                        if [ -f /etc/httpd/conf.d/php.conf ] ; then
                        mv /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/php.conf.bkp
                        fi
echo " # This is the Apache server configuration file for providing FastCGI support
# through mod_fcgid
#
# Documentation is available at
# http://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
LoadModule fcgid_module modules/mod_fcgid.so
# Use FastCGI to process .fcg .fcgi & .fpl scripts
AddHandler fcgid-script fcg fcgi fpl
# Sane place to put sockets and shared memory file
FcgidIPCDir /var/run/mod_fcgid
FcgidProcessTableFile /var/run/mod_fcgid/fcgid_shm
DirectoryIndex index.php
PHP_Fix_Pathinfo_Enable 1 " > /etc/httpd/conf.d/fcgid.conf
                         sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php.ini
                        fi

echo "<VirtualHost *:$port_apache>
ServerName pma.example.com
ServerAlias pma.*
DocumentRoot /var/www/pma/site/pma
ErrorLog /var/www/pma/logs/pma.error.log
CustomLog /var/www/pma/logs/pma.access.log common
        <IfModule mod_fcgid.c>
        SuexecUserGroup pma pma
        <Directory /var/www/pma/site/pma>
        Options +ExecCGI
        AllowOverride All
        AddHandler fcgid-script .php
        FCGIWrapper /var/www/pma/php-cgi/php.cgi .php
        Order allow,deny
        Allow from all
        </Directory>
        </IfModule>
</VirtualHost>" > /etc/httpd/conf.d/phpmyadmin.conf

# ниже перечисленные условия, проверяют созданы лы директории/файлы и если не созданы, то создают
if ! [ -d /var/www/pma/site/pma/ ]; then
mkdir -p /var/www/pma/site/pma
fi
if ! [ -d /var/www/pma/tmp/ ]; then
mkdir -p /var/www/pma/tmp/
fi

if ! [ -d /var/www/pma/logs/ ]; then
mkdir /var/www/pma/logs
fi

if ! [ -d /var/www/pma/php-cgi/ ]; then
mkdir /var/www/pma/php-cgi/
fi

if ! [ -f /var/www/pma/logs/pma.error.log ]; then
touch /var/www/pma/logs/pma.error.log
fi

if ! [ -f /var/www/pma/logs/pma.access.log ]; then
touch /var/www/pma/logs/pma.access.log
fi

if ! [ -f /var/www/pma/php-cgi/php.cgi ]; then
touch /var/www/pma/php-cgi/php.cgi
echo "#!/bin/sh
PHPRC=/var/www/pma/php-cgi/
export PHPRC
export PHP_FCGI_MAX_REQUESTS=500
exec /usr/bin/php-cgi" > /var/www/pma/php-cgi/php.cgi

#В данном месте мы копируем php.ini, для того чтобы у каждого пользователя был свой (путь до php.ini указывается через параметр PHPRC, в FCGIWrapper -  php.cgi)
cp /etc/php.ini /var/www/pma/php-cgi/
chmod +x /var/www/pma/php-cgi/php.cgi
fi
chown -R pma:pma /var/www/pma
}


function phpmyadminnginx {
if [[ "$fr_bk_end" == 'y' && "$ng" == 'y' ]];
        then
echo "
server {
listen $port_nginx;
server_name pma.*;
access_log  /var/www/pma/logs/pma.nginx.access.log combined;
error_log   /var/www/pma/logs/pma.nginx.error.log error;
client_max_body_size 20m;
location ~* \.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|swf|js|html|htm|)$ {
root /var/www/pma/site/pma;
}
location / {
proxy_pass http://127.0.0.1:$port_apache;
proxy_set_header Host \$http_host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_pass_header Set-Cookie;
}
}" > /etc/nginx/conf.d/phpmyadmin.conf

# ниже перечисленные условия, проверяют созданы лы директории/файлы и если не созданы, то создают
if ! [ -d /var/www/pma/site/pma/ ]; then
mkdir -p /var/www/pma/site/pma
fi

if ! [ -d /var/www/pma/tmp/ ]; then
mkdir -p /var/www/pma/tmp/
fi

if ! [ -d /var/www/pma/logs/ ]; then
mkdir /var/www/pma/logs
fi

if ! [ -f /var/www/pma/logs/pma.nginx.error.log ]; then
touch /var/www/pma/logs/pma.nginx.error.log
fi

if ! [ -f /var/www/pma/logs/pma.nginx.access.log ]; then
touch /var/www/pma/logs/pma.nginx.access.log
fi

chown -R pma:pma /var/www/pma

fi

}

function phpmyadmin_dobavlenie_polzovatelja {
pma=`awk -F ":" '{print $1}' /etc/passwd | grep "pma"`
if [ "$pma" != 'pma' ]
        then
        echo ""
        echo "Добавим пользователя pma"
        useradd -M pma
        echo ""
                else
                echo""
                echo "Добавим пользователя pma под которым будет работать phpmyadmin"
                echo "Такой пользователь уже существует"
                echo "Проверьте всё ли корректно"
                echo ""
                exit 1;
fi
}

function phpmyadmin_ustanovka {
yum -y install wget zip unzip php-mysql php-common php-mbstring php-gd php-ldap php-odbc php-pear php-xml php-soap curl curl-devel php-xmlrpc php-snmp
cd /var/www/pma/site/pma

phpver=`php -v | head -1 | awk -F "." '{print $2}'`
if [[ "$phpver" -lt '5' ]]; # если версия php меньше php5.5 будет установлен phpmyadmin4.1.12
        then
        wget https://files.phpmyadmin.net/phpMyAdmin/4.1.12/phpMyAdmin-4.1.12-all-languages.zip
        unzip phpMyAdmin-4.1.12-all-languages.zip
        mv /var/www/pma/site/pma/phpMyAdmin-4.1.12-all-languages/* /var/www/pma/site/pma/
        rm -rf /var/www/pma/site/pma/phpMyAdmin-4.1.12-all-languages/

echo "<?php
/*
 * Generated configuration file
 * Generated by: phpMyAdmin 4.1.12 setup script
 */

/* Servers configuration */
\$i = 0;

/* Server: localhost [1] */
\$i++;
\$cfg['Servers'][\$i]['verbose'] = 'localhost';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['port'] = '';
\$cfg['Servers'][\$i]['socket'] = '';
\$cfg['Servers'][\$i]['connect_type'] = 'socket';
\$cfg['Servers'][\$i]['extension'] = 'mysqli';
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['user'] = 'root';
\$cfg['Servers'][\$i]['password'] = '';

/* End of servers configuration */

\$cfg['blowfish_secret'] = '5968d8b1e0a5b8.83308017';
\$cfg['UploadDir'] = '/var/www/pma/tmp';
\$cfg['SaveDir'] = '/var/www/pma/tmp';
\$cfg['DefaultLang'] = 'ru';
\$cfg['ServerDefault'] = 1;
?> " > /var/www/pma/site/pma/config.inc.php

sed -i 's|session.save_path = \"\/var\/lib\/php\/session\"|session.save_path = \/var\/www\/pma\/tmp|' /var/www/pma/php-cgi/php.ini
chmod 775 /var/www/pma/tmp/
chown -R pma:pma /var/www/pma/
chmod -R 000 /var/www/pma/site/pma/setup/

        else # если версия php5.5 или больше будет установлен phpmyadmin4.7.2

        wget https://files.phpmyadmin.net/phpMyAdmin/4.7.2/phpMyAdmin-4.7.2-all-languages.zip
        unzip phpMyAdmin-4.7.2-all-languages.zip
        mv /var/www/pma/site/pma/phpMyAdmin-4.7.2-all-languages/* /var/www/pma/site/pma/
        rm -rf /var/www/pma/site/pma/phpMyAdmin-4.7.2-all-languages

echo "<?php
/*
 * Generated configuration file
 * Generated by: phpMyAdmin 4.7.2 setup script
 */

/* Servers configuration */
\$i = 0;

/* Server: localhost [1] */
\$i++;
\$cfg['Servers'][\$i]['verbose'] = 'localhost';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['port'] = '';
\$cfg['Servers'][\$i]['socket'] = '';
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['user'] = 'root';
\$cfg['Servers'][\$i]['password'] = '';

/* End of servers configuration */

\$cfg['blowfish_secret'] = '5968d8b1e0a5b8.83308017';
\$cfg['UploadDir'] = '/var/www/pma/tmp';
\$cfg['SaveDir'] = '/var/www/pma/tmp';
\$cfg['DefaultLang'] = 'ru';
\$cfg['ServerDefault'] = 1;
?> " > /var/www/pma/site/pma/config.inc.php

        sed -i 's|session.save_path = \"\/var\/lib\/php\/session\"|session.save_path = \/var\/www\/pma\/tmp|' /var/www/pma/php-cgi/php.ini
        chmod 775 /var/www/pma/tmp/
        chown -R pma:pma /var/www/pma/
        chmod -R 000 /var/www/pma/site/pma/setup/
fi
if [[ "$versiaOS" == "centos6" ]];
        then
        service httpd restart
	service nginx restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart httpd
	systemctl restart nginx
fi

}

proverka_ustanovlennogo_PO2
phpmyadmin_dobavlenie_polzovatelja
phpmyadminapache
phpmyadminnginx
phpmyadmin_ustanovka

}

function FTP {
clear
function ustanovka_ftp {


if [[ "$versiaOS" == "centos6" ]];
        then
        ftp=`chkconfig | grep proftpd | awk '{print $1}'`
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        ftp=`rpm -qa | grep proftpd | head -1 | awk -F '-' '{print $1}'`
fi


if [[ "$ftp" != proftpd  ]]
then
clear
yum -y install proftpd proftpd-utils
sleep 3
clear
if [[ "$versiaOS" == "centos6" ]];
        then
	chkconfig proftpd on
fi
if [[ "$versiaOS" == "centos7" ]];
        then
	systemctl enable proftpd
fi
sed -i "/^127.0.0.1/ s|$| `hostname`|" /etc/hosts
echo ""
echo -e "${CYAN}Создаём резервную копию конфиг файла:"
sleep 2
echo -e "${WHITE} cp /etc/proftpd.conf /etc/proftpd.conf.bak  ${NORMAL}"
sleep 3

cp /etc/proftpd.conf /etc/proftpd.conf.bak

nomAUTH=`cat -n /etc/proftpd.conf | grep AuthOrder | awk '{print $1}'`
sed -i "${nomAUTH}c AuthOrder                     mod_auth_file.c" /etc/proftpd.conf

nomDEFROOT=`cat -n /etc/proftpd.conf | grep DefaultRoot | awk '{print $1}'`
sed -i "${nomDEFROOT}c DefaultRoot                     ~" /etc/proftpd.conf
sed -i "${nomDEFROOT}a RequireValidShell               off" /etc/proftpd.conf

nomGLOB=`cat -n /etc/proftpd.conf | grep '<Global>$' | awk '{print $1}'`
sed -i "${nomGLOB}a AuthUserFile              /etc/proftpd/ftpd.passwd\nAuthGroupFile             /etc/proftpd/ftpd.group" /etc/proftpd.conf

nomLogAuth=`cat -n /etc/proftpd.conf | grep LogFormat | grep auth | awk '{print $1}'`
sed -i "${nomLogAuth}a LogFormat                       write   \"%h %l %u %t \"%r\" %s %b\"" /etc/proftpd.conf

nomExtLog=`cat -n /etc/proftpd.conf | grep ExtendedLog | head -1| awk '{print $1}'`
sed -i "${nomExtLog}c ExtendedLog                     /var/log/proftpd/access.log WRITE,READ write" /etc/proftpd.conf

echo "ExtendedLog    /var/log/proftpd/access.log WRITE,READ write
ExtendedLog    /var/log/proftpd/auth.log AUTH auth
SystemLog      /var/log/proftpd/proftpd.log
TransferLog    /var/log/proftpd/xfer.log
DebugLevel     9" >> /etc/proftpd.conf

if ! [ -d /etc/proftpd/ ]; then
mkdir /etc/proftpd
fi
if ! [ -f /var/log/proftpd/proftpd.log ]; then
touch /var/log/proftpd/proftpd.log
fi
if ! [ -f /var/log/proftpd/xfer.log ]; then
touch /var/log/proftpd/xfer.log
fi
if ! [ -f /var/log/proftpd/access.log ]; then
touch /var/log/proftpd/access.log
fi
if ! [ -f /var/log/proftpd/auth.log ]; then
touch /var/log/proftpd/auth.log
fi
if ! [ -f /etc/proftpd/ftpd.passwd ]; then
touch /etc/proftpd/ftpd.passwd
fi
if ! [ -f /etc/proftpd/ftpd.group ]; then
touch /etc/proftpd/ftpd.group
fi
chmod o-rwx /etc/proftpd/ftpd.passwd

if [[ "$versiaOS" == "centos6" ]];
        then
        service proftpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart proftpd
fi

fi

}

function dobavlenie_virt_polzovatelya {
clear
echo -e "${CYAN}Укажи системного пользователя от которого будет работать виртуальный${NORMAL}"
read user_sist

proverka_usera=`awk -F ":" '{print $1}' /etc/passwd | grep "^$user_sist$"`
if [ "$proverka_usera" != "$user_sist" ]
        then
        echo ""
        echo -e "${RED}Такого пользователя ${GREEN}"$user_sist" ${RED}не существует!!!${NORMAL}"
        exit 1;
fi

idpolz=`grep $user_sist /etc/passwd | awk -F ":" '{print $3}'`
idgrpolz=`grep $user_sist /etc/passwd | awk -F ":" '{print $4}'`
echo ""
echo -e "${CYAN}Укажи пользователя под которым будет производиться аутентификация${NORMAL}"
read user_virt
userVIRT=`echo ""$user_sist"_"$user_virt""`
echo ""
echo -e "${CYAN}Пользователь будет выглядеть следующим образом:${GREEN} "$userVIRT"${NORMAL}"
proverka_virt_usera=`awk -F ":" '{print $1}' /etc/proftpd/ftpd.passwd | grep "^$userVIRT$"`
if [ "$proverka_virt_usera" == "$userVIRT" ]
        then
        echo ""
        echo -e "${RED}Такой пользователь ${GREEN}"$userVIRT" ${RED}уже существует${NORMAL}"
        grep $userVIRT /etc/proftpd/ftpd.passwd
        exit 1;
fi

echo ""
echo -e "${CYAN}Укажи домашний каталог, к которому даёшь доступ${NORMAL}"
read homedir

if ! [ -d "$homedir" ];
        then
        echo -e "${RED}Данного каталога ${GREEN}"$homedir" ${RED}не существует${NORMAL}"
        exit 1;
fi

echo ""
echo -e "${CYAN}Укажи пароль для пользователя $userVIRT с домашней директорией $homedir${NORMAL}"
ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$userVIRT --uid=$idpolz --gid=$idgrpolz --home=$homedir --shell=/bin/false
ftpasswd --group --file=/etc/proftpd/ftpd.group.tmp --name=$user_sist --gid=$idgrpolz --member=$userVIRT
cat /etc/proftpd/ftpd.group.tmp >> /etc/proftpd/ftpd.group
rm -rf /etc/proftpd/ftpd.group.tmp 2>/dev/null

chown root:root /etc/proftpd/
chmod 755 /etc/proftpd/
chmod 644 /etc/proftpd/*
clear
chmod o-rwx /etc/proftpd/ftpd.passwd

if [[ "$versiaOS" == "centos6" ]];
        then
        service proftpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart proftpd
fi

proverka_virt_usera2=`awk -F ":" '{print $1}' /etc/proftpd/ftpd.passwd | grep "^$userVIRT$"`
if [ "$proverka_virt_usera2" == "$userVIRT" ]
        then
        echo ""
        echo -e "${YELLOW}Всё ок, данный пользователь ${GREEN}"$userVIRT" ${YELLOW}добавился${NORMAL}"
        echo -e "${YELLOW}Виртуальные пользователи добавлены в данные файлы:${NORMAL}"
        ls -l /etc/proftpd/ftpd.passwd
        ls -l /etc/proftpd/ftpd.group
                else
                echo -e "${RED}Что-то какая-то проблема... х.з. где и какая? пардоньте :\) ${NORMAL} "
fi

}
function udalenie_virt_polzovatelya {
echo -e "${CYAN}Укажи пользователя которого надо удалить${NORMAL}"
cat /etc/proftpd/ftpd.passwd | awk -F ":" '{print $1,"----"$6}'
read otv_udal_polz
sed -i "/^${otv_udal_polz}:/d" /etc/proftpd/ftpd.passwd
sed -i "/^${otv_udal_polz}:/d" /etc/proftpd/ftpd.group
chmod o-rwx /etc/proftpd/ftpd.passwd
if [[ "$versiaOS" == "centos6" ]];
        then
        service proftpd restart
fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl restart proftpd
fi
echo ""
echo -e "${YELLOW}Проверяем:${NORMAL}"
cat /etc/proftpd/ftpd.passwd
}

echo -e "${CYAN}Добавить или удалить пользователя FTP${NORMAL}"
echo -e "${WHITE}1${NORMAL} - ${CYAN}Добавить${NORMAL}"
echo -e "${WHITE}2${NORMAL} - ${CYAN}Удалить${NORMAL}"
read otv_ftp
case $otv_ftp in
1)
ustanovka_ftp
dobavlenie_virt_polzovatelya
sleep 4
;;
2)
udalenie_virt_polzovatelya
sleep 4
;;
esac
}


function ustanovkaIoncubeLoader {
if [ "$(uname -m)" == 'x86_64' ]
        then
        razrayd=64
        else
        razrayd=32
fi

if ! [ -d /opt/alt.php ];
        then
        echo "Установи сначала альтернативные версии и перезапусти скрипт  $0 "
        exit 1;
fi

if ! [ -d /opt/alt.php/ioncube/ ]; #
        then
        cd /opt/alt.php/
                if [[ "$razrayd" == '64' ]];
                        then
                        wget http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
                        tar xvfz ioncube_loaders_lin_x86-64.tar.gz
                        rm -rf /opt/alt.php/ioncube_loaders_lin_x86-64.tar.gz
                        else
                        wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
                        tar xvfz ioncube_loaders_lin_x86.tar.gz
                        rm -rf /opt/alt.php/ioncube_loaders_lin_x86.tar.gz
                fi
fi

if ! [ -f /opt/alt.php/php7.2.5/ioncube_loader_lin_7.2.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_7.2.so /opt/alt.php/php7.2.5/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php7.2.5/ioncube_loader_lin_7.2.so" /opt/alt.php/php7.2.5/php.d/php.ini 2>/dev/null
	if [[ "$versiaOS" == "centos6" ]];
	        then
        	service httpd restart
	fi
	if [[ "$versiaOS" == "centos7" ]];
	        then
        	systemctl restart httpd
	fi
fi

if ! [ -f /opt/alt.php/php7.1.9/ioncube_loader_lin_7.1.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_7.1.so /opt/alt.php/php7.1.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php7.1.9/ioncube_loader_lin_7.1.so" /opt/alt.php/php7.1.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart httpd
        fi
fi
if ! [ -f /opt/alt.php/php7.0.9/ioncube_loader_lin_7.0.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_7.0.so /opt/alt.php/php7.0.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php7.0.9/ioncube_loader_lin_7.0.so" /opt/alt.php/php7.0.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart httpd
        fi
fi

if ! [ -f /opt/alt.php/php5.6.9/ioncube_loader_lin_5.6.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.6.so /opt/alt.php/php5.6.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.6.9/ioncube_loader_lin_5.6.so" /opt/alt.php/php5.6.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart httpd
        fi
fi
if ! [ -f /opt/alt.php/php5.5.9/ioncube_loader_lin_5.5.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.5.so /opt/alt.php/php5.5.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.5.9/ioncube_loader_lin_5.5.so" /opt/alt.php/php5.5.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart httpd
        fi
fi
if ! [ -f /opt/alt.php/php5.4.9/ioncube_loader_lin_5.4.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.4.so /opt/alt.php/php5.4.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.4.9/ioncube_loader_lin_5.4.so" /opt/alt.php/php5.4.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart httpd
        fi
fi

if [[ "$versiaOS" == "centos6" ]];
then
if ! [ -f /opt/alt.php/php5.3.9/ioncube_loader_lin_5.3.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.3.so /opt/alt.php/php5.3.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.3.9/ioncube_loader_lin_5.3.so" /opt/alt.php/php5.3.9/php.d/php.ini 2>/dev/null
        if [[ "$versiaOS" == "centos6" ]];
                then
                service httpd restart
        fi
fi
fi
}

function samba {
razryadnost_versia_OS
IP=`ip a| grep inet| grep global | awk -F '/' '{print $1}' | awk '{print $2}'`
clear
function ustanovka_samba {
proverka_ustanovlennogo_PO
if [[ "$samba" != 'samba' ]];
 then
 yum -y install samba samba-common cups-libs samba-client

if [[ "$versiaOS" == "centos6" ]];
        then
        chkconfig smb on
        chkconfig nmb on
        service nmb start
        service smb start
fi

if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl enable smb
        systemctl enable nmb
        systemctl start nmb
        systemctl start smb
fi
mv /etc/samba/smb.conf /etc/samba/smb.conf.Backup

echo "[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = `hostname`
security = user
map to guest = bad user
dns proxy = no
unix password sync = yes
socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=8192 SO_SNDBUF=8192
local master = yes
preferred master = yes
log file = /var/log/samba/log.%m
max log size = 50

wins enable=yes
local master = yes
domain master = yes
ntlm auth = yes
" > /etc/samba/smb.conf
echo ""
echo ""
echo ""
echo "_______________________________"
echo -e "${YELLOW}Укажи имя рабочей группы для всего сервера${NORMAL}"
echo ""
read otv_samba_raboch_gruppa
sed -i "s|.*workgroup.*|workgroup = ${otv_samba_raboch_gruppa}|" /etc/samba/smb.conf
fi
}

function dobavlenie_direktorij_k_samba {
ustanovka_samba
clear
echo "_____________________________________________"
echo -e "${YELLOW}Директория должна быть запороленная или шара?${NORMAL}"
echo -e "${WHITE}1${NORMAL} = ${CYAN}Запороленная${NORMAL}"
echo -e "${WHITE}2${NORMAL} = ${CYAN}Шара${NORMAL}"
read otv_samba_parol
echo ""
clear
echo -e "${YELLOW}Список имеющихся директорий:${NORMAL}"
cat /etc/samba/smb.conf | grep path | awk -F '=' '{print $2}' | sed 's/^[ \t]*//'
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Укажи полный путь до директории${NORMAL}"
read otv_samba_dir
if ! [ -d $otv_samba_dir ]; then
mkdir -p $otv_samba_dir
fi
if [[ "$otv_samba_dir" == "$(cat /etc/samba/smb.conf | grep path | awk -F '=' '{print $2}' | sed 's/^[ \t]*//' | grep $otv_samba_dir)" ]] ;
        then
        echo -e "${RED}такая директория уже существует, работа скрипта завершается, перезапустите его${NORMAL}"
        exit 1;
fi
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Укажи имя которое будет отображаться в сетевом окружении${NORMAL}"
read otv_imya_setev_okruz
echo ""
if [[ "$otv_samba_parol" == "1" ]];
        then
        echo "_____________________________________________"
        echo -e "${YELLOW}Укажи группу от которой будет доступ к директории "$otv_samba_dir"${NORMAL}"
        read otv_samba_gruppa
        echo ""
        echo "_____________________________________________"
        echo -e "${YELLOW}Укажи пользователя у которого будет доступ к директории "$otv_samba_dir"${NORMAL}"
        read otv_samba_user
        proverka_usera=`awk -F ":" '{print $1}' /etc/passwd | grep "^$otv_samba_user$"`
        if [[ "$proverka_usera" != "$otv_samba_user" ]];
                 then
                adduser $otv_samba_user
        fi

        proverka_gruppi=`awk -F ":" '{print $1}' /etc/group | grep "^$otv_samba_gruppa$"`
        if [[ "$proverka_gruppi" != "$otv_samba_gruppa" ]];
                then
                groupadd $otv_samba_gruppa
        fi

        usermod -G $otv_samba_gruppa $otv_samba_user
        echo "_____________________________________________"
        echo -e "${YELLOW}Создадим пароль для входа в директорию "$otv_samba_dir"${NORMAL}"
        echo -e "${CYAN}для пользователя ${WHITE}"$otv_samba_user"${NORMAL}"
        echo ""
        smbpasswd -a $otv_samba_user
        smbpasswd -e $otv_samba_user
fi

if [[ "$otv_samba_parol" == "1" ]];
then
echo "
[$otv_imya_setev_okruz]
comment = Only password access
path = $otv_samba_dir
valid users = @$otv_samba_gruppa
browsable = yes
writable = yes
guest ok = no
create mode = 0755
directory mask = 0755 " >> /etc/samba/smb.conf
fi

if [[ "$otv_samba_parol" == "2" ]];
then
echo "
[$otv_imya_setev_okruz]
comment = Everybody has access
path = $otv_samba_dir
browsable = yes
writable = yes
guest ok = yes
create mode = 0755
directory mask = 0755 " >> /etc/samba/smb.conf
fi


if [[ "$otv_samba_parol" == "1" ]];
        then
        chown -R $otv_samba_user:$otv_samba_gruppa $otv_samba_dir
        chmod -R 775 $otv_samba_dir
        echo "_____________________________________________"
        echo -e "${MAGENTA}Зайти в запароленную директорию вы можете через проводник следующим образом:${NORMAL}"
        echo -e "${WHITE}\\\\"$IP"\\"$otv_imya_setev_okruz"${NORMAL}"
	sleep 2
        echo ""
        echo -e "${MAGENTA}В качестве логина укажите:${NORMAL}"
        workgrp=`grep workgroup /etc/samba/smb.conf | awk -F "=" '{print $2}' | sed 's/^[ \t]*//'`
        echo -e "${WHITE}$workgrp\\$otv_samba_user${NORMAL}"
	sleep 2
        echo ""
        if [[ "$versiaOS" == "centos6" ]];
                then
                service nmb restart
	        service smb restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart nmb
		systemctl restart smb
        fi
fi
if [[ "$otv_samba_parol" == "2" ]];
        then
        chown -R nobody:nobody $otv_samba_dir
        chmod -R 777 $otv_samba_dir
        echo "_____________________________________________"
        echo -e "${MAGENTA}Зайти на шару вы можете через проводник ${WHITE} \\\\"$IP"\\"$otv_imya_setev_okruz"${NORMAL}"
	sleep 2
        echo ""
        if [[ "$versiaOS" == "centos6" ]];
                then
                service nmb restart
                service smb restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart nmb
                systemctl restart smb
        fi
fi
}

function dobavlenie_polzovatelej_k_zaporolennoj_direktorii {
imya_setev_okruz=`cat /etc/samba/smb.conf | grep workgroup | awk -F '=' '{print $2}' | sed 's/^[ \t]*//'`
echo ""
clear
echo "_____________________________________________"
echo -e "${YELLOW}Для какой директории вы хотите добавить нового пользователя с паролем:${NORMAL}"
cat /etc/samba/smb.conf | grep -a2 'Only password access' |grep -E '\[|path|valid users' > $p/vse_zaparollennie_dorecktorii
cat $p/vse_zaparollennie_dorecktorii | grep path |awk -F '=' '{print $2}' | sed 's/^[ \t]*//'
echo ""
read dir_parol
echo ""
gpr=`cat $p/vse_zaparollennie_dorecktorii | grep -A1 "$dir_parol" | grep 'valid users' | awk -F '@' '{print $2}'`
echo -e "${MAGENTA}Общая группа для директории ${WHITE}"$gpr" ${MAGENTA}к ней уже добавлены следующие пользователи:${NORMAL}"
cat /etc/group | grep $gpr | awk -F ':' '{print $4}'
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Укажи дополнительного пользователя для директории ${WHITE}$dir_parol${NORMAL}"
echo ""
read dop_user
proverka_usera=`awk -F ":" '{print $1}' /etc/passwd | grep "^$dop_user$"`
if [[ "$proverka_usera" != "$dop_user" ]];
        then
        adduser $dop_user
fi
usermod -G $gpr $dop_user
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Установим для пользователя $dop_user пароль:${NORMAL}"
echo ""
smbpasswd -a $dop_user
smbpasswd -e $dop_user
echo ""
clear
echo "_____________________________________________"
echo -e "${YELLOW}Зайти в запароленную директорию вы можете через проводник следующим образом:${NORMAL}"
echo -e "${WHITE}\\\\"$IP"\\"$imya_setev_okruz"${NORMAL}"
sleep 2
echo ""
echo -e "${YELLOW}В качестве логина укажите:${NORMAL}"
echo -e "${WHITE}$imya_setev_okruz\\$dop_user${NORMAL}"
rm -rf $p/vse_zaparollennie_dorecktorii
echo ""
sleep2
        if [[ "$versiaOS" == "centos6" ]];
                then
                service nmb restart
                service smb restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart nmb
                systemctl restart smb
        fi
}

function udalenie_direktorii {
clear
echo -e "${YELLOW}Какую директорию необходимо удалить из доступа:${NORMAL}"
cat /etc/samba/smb.conf | grep path | awk -F '=' '{print $2}' | sed 's/^[ \t]*//'
echo ""
read dir_udal
echo ""
nomer_dir_udal_nachalo=`cat -n /etc/samba/smb.conf | grep -B2 "$dir_udal$" | grep '\[' | awk '{print $1}'`
nomer_dir_udal_konec=`cat -n /etc/samba/smb.conf | grep -A8 "$dir_udal$" | grep 'directory mask' | awk -F '=' '{print $1}' | awk '{print $1}'`
sed -i "${nomer_dir_udal_nachalo},${nomer_dir_udal_konec}d" /etc/samba/smb.conf
        if [[ "$versiaOS" == "centos6" ]];
                then
                service nmb restart
                service smb restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart nmb
                systemctl restart smb
        fi
}

function udalenie_polzovatelya_iz_zaporollenoj_directorii {
clear
echo -e "${YELLOW}Для какой директории вы хотите удалить пользователя с паролем:${NORMAL}"
cat /etc/samba/smb.conf | grep -a2 'Only password access' |grep -E '\[|path|valid users' > $p/vse_zaparollennie_dorecktorii
cat $p/vse_zaparollennie_dorecktorii | grep path |awk -F '=' '{print $2}' | sed 's/^[ \t]*//'
echo ""
read dir_parol
echo ""
gpr=`cat $p/vse_zaparollennie_dorecktorii | grep -A1 "$dir_parol" | grep 'valid users' | awk -F '@' '{print $2}'`
echo -e "${YELLOW}Общая группа для директории ${WHITE}"$gpr" ${YELLOW}к ней уже добавлены следующие пользователи:${NORMAL}"
cat /etc/group | grep $gpr | awk -F ':' '{print $4}'
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Укажи пользователя которого необходимо удалить для директории ${WHITE}$dir_parol${NORMAL}"
echo ""
read dop_user
gpasswd -d $dop_user $gpr
smbpasswd -d $dop_user
smbpasswd -x $dop_user
        if [[ "$versiaOS" == "centos6" ]];
                then
                service nmb restart
                service smb restart
        fi
        if [[ "$versiaOS" == "centos7" ]];
                then
                systemctl restart nmb
                systemctl restart smb
        fi
rm -rf $p/vse_zaparollennie_dorecktorii
}
function pokaz_kakie_directorii_zaporoleni_kakie_net {
clear
echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Запороленные директории:${NORMAL}"
echo ""
cat /etc/samba/smb.conf | grep -a2 'Only password access' |grep -E '\[|path|valid users' | grep path |awk -F '=' '{print $2}' | sed 's/^[ \t]*//'

echo ""
echo "_____________________________________________"
echo -e "${YELLOW}Расшаренные директории:${NORMAL}"
echo ""
cat /etc/samba/smb.conf | grep -a1 'Everybody has access' |grep -E '\[|path' | grep path |awk -F '=' '{print $2}' | sed 's/^[ \t]*//'
sleep 4
}

echo -e "${YELLOW}Что необходимо сделать:${NORMAL}"
echo -e "${WHITE}1${NORMAL} = ${CYAN}Добавить директорию${NORMAL}"
echo -e "${WHITE}2${NORMAL} = ${CYAN}Удалить директорию${NORMAL}"
echo -e "${WHITE}3${NORMAL} = ${CYAN}Добавить нового пользователя к запароленной директории${NORMAL}"
echo -e "${WHITE}4${NORMAL} = ${CYAN}Удалить пользователя у запароленной директории${NORMAL}"
echo -e "${WHITE}5${NORMAL} = ${CYAN}Показать запароленные директории и шары${NORMAL}"
echo -e "${WHITE}0${NORMAL} = ${GREEN}Выход${NORMAL}"
read otv_dejstv
case $otv_dejstv in
        1)
        ustanovka_samba
        dobavlenie_direktorij_k_samba
	samba
        ;;
        2)
        udalenie_direktorii
	samba
        ;;
        3)
        dobavlenie_polzovatelej_k_zaporolennoj_direktorii
	samba
        ;;
        4)
        udalenie_polzovatelya_iz_zaporollenoj_directorii
	samba
        ;;
        5)
        pokaz_kakie_directorii_zaporoleni_kakie_net
	samba
        ;;
        0|*)
	skript
        ;;
esac
}


function openvpn {

function ustanovka_openvpn {
razryadnost_versia_OS
if [[ "$versiaOS" == 'centos6' ]];
        then
        podkluchenie_repozitoria_epel_centos6
fi
if [[ "$versiaOS" == 'centos7' ]];
        then
        podkluchenie_repozitoria_epel_centos7
fi

yum -y install openvpn easy-rsa openssl

if [[ "$versiaOS" == 'centos6' ]];
        then
        chkconfig openvpn on
fi
if [[ "$versiaOS" == 'centos7' ]];
        then
        systemctl enable openvpn
fi

cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn/

clear
echo -e "${CYAN}Введите IP адрес данного сервера${NORMAL}"
ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1

read IP
sed -i "/;client-to-client/a client-to-client" /etc/openvpn/server.conf
sed -i "/;local a.b.c.d/a local ${IP}" /etc/openvpn/server.conf
echo ""
sed -i "s/\;push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf

sed -i "/\;push \"dhcp-option DNS 208.67.220.220\"/a push \"dhcp-option DNS 8.8.8.8\"" /etc/openvpn/server.conf
sed -i "/push \"dhcp-option DNS 8.8.8.8\"/a push \"dhcp-option DNS 8.8.4.4\"" /etc/openvpn/server.conf

sed -i "s/\;user nobody/user nobody/" /etc/openvpn/server.conf
sed -i "s/\;group nobody/group nobody/" /etc/openvpn/server.conf
sed -i "s/status openvpn-status.log/status \/var\/log\/openvpn-status.log/" /etc/openvpn/server.conf
sed -i "s/\;log-append  openvpn.log/log-append \/var\/log\/openvpn.log/" /etc/openvpn/server.conf
sed -i "s/\;duplicate-cn/duplicate-cn/" /etc/openvpn/server.conf
echo "" >> /etc/openvpn/server.conf
echo "push \"route 192.168.0.0 255.255.255.0\"" >> /etc/openvpn/server.conf
echo "crl-verify crl.pem" >> /etc/openvpn/server.conf

if ! [ -f /var/log/openvpn-status.log ]; then
touch /var/log/openvpn-status.log
fi
if ! [ -f /var/log/openvpn.log ]; then
touch /var/log/openvpn.log
fi
if ! [ -d /etc/openvpn/easy-rsa/keys ]; then
mkdir -p /etc/openvpn/easy-rsa/keys
fi

cp -rf /usr/share/easy-rsa/3.*.*/* /etc/openvpn/easy-rsa/
clear
echo -e "${MAGENTA}Генерируем ключ, укажи следующие параметры:${NORMAL}"
echo -e "KEY_COUNTRY по умолчанию ${WHITE}RU${NORMAL}"
read COUNTRY
echo -e "KEY_PROVINCE По умолчанию ${WHITE}NW${NORMAL}"
read PROVINCE
echo -e "KEY_CITY по умолчанию ${WHITE}Moscow${NORMAL}"
read CITY
echo -e "KEY_ORG по умолчанию ${WHITE}OrgName${NORMAL}"
read ORG
echo -e "KEY_EMAIL по умолчанию ${WHITE}me@myhost.mydomain${NORMAL}"
read EMAIL
echo -e "KEY_OU по умолчанию ${WHITE}MyOrganizationalUnit${NORMAL}"
read OU
echo -e "KEY_NAME по умолчанию ${WHITE}EasyRSA${NORMAL}"
read NAME
echo "export KEY_COUNTRY="$COUNTRY"" > /etc/openvpn/easy-rsa/vars
echo "export KEY_PROVINCE="$PROVINCE"" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_CITY="$CITY"" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_ORG="$ORG"" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_EMAIL="$EMAIL"" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_OU="$OU"" >> /etc/openvpn/easy-rsa/vars
echo "# X509 Subject Field" >> /etc/openvpn/easy-rsa/vars
echo "export KEY_NAME="$NAME"" >> /etc/openvpn/easy-rsa/vars
cp /etc/openvpn/easy-rsa/openssl-*cnf /etc/openvpn/easy-rsa/openssl.cnf

cd /etc/openvpn/easy-rsa
source ./vars
./clean-all
./easyrsa init-pki
clear
echo -e "${CYAN}Необходимо ввести пароль ${WHITE}для приватного ключа${NORMAL}, пароль должен быть не менее 10 символов"
echo -e "${CYAN}После чего необходимо ввести имя сервера:${NORMAL} `hostname`"
./easyrsa build-ca
clear
echo -e "${WHITE}Создаем запрос сертификата для сервера без пароля с помощью опции nopass, иначе придется вводить пароль с консоли при каждом запуске сервера${NORMAL}"
./easyrsa gen-req server nopass
clear
echo -e "${CYAN}Подписываем запрос на получение сертификата у нашего CA${NORMAL}"
./easyrsa sign-req server server
clear
echo "Создаем ключ Диффи-Хелмана"
echo "В применении к OpenVPN файл Диффи-Хелмана нужен для обеспечения защиты трафика от расшифровки, если ключи были похищены"
./easyrsa gen-dh
clear
echo -e "${WHITE}Чтобы можно было отозвать клиентский сертификат (например, при утере мобильного устройства или при увольнении сотрудника), надо создать список отозванных сертификатов CRL${NORMAL}"
./easyrsa gen-crl
clear
mkdir -p /etc/openvpn/keys
cp -rf /etc/openvpn/easy-rsa/pki/* /etc/openvpn/
cp /etc/openvpn/easy-rsa/pki/issued/server.crt /etc/openvpn/
cp /etc/openvpn/easy-rsa/pki/private/server.key /etc/openvpn/
cd /etc/openvpn
echo "Создадим файл HMAC, для дополнительной верификации клиента и сервера"
/usr/sbin/openvpn --genkey --secret /etc/openvpn/ta.key
echo "Файл ta.key должен быть скопирован и передан клиенту"
chmod 644 /etc/openvpn/ca.crt
chmod 644 /etc/openvpn/crl.pem
mv /etc/openvpn/dh.pem /etc/openvpn/dh2048.pem
chmod 644 /etc/openvpn/dh2048.pem
chmod 644 /etc/openvpn/server.crt
chmod 600 /etc/openvpn/server.key
chmod 600 /etc/openvpn/ta.key
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/Controls IP packet forwarding/a net.ipv4.ip_forward = 1' /etc/sysctl.conf
sysctl -p
sed -i 's|explicit-exit-notify 1crl-verify crl.pem|#explicit-exit-notify 1crl-verify crl.pem|' /etc/openvpn/server.conf
if [[ "$versiaOS" == 'centos6' ]];
        then
        service openvpn restart
fi
if [[ "$versiaOS" == 'centos7' ]];
        then
        systemctl restart openvpn
fi
setevoj_interface=`cat /proc/net/dev | awk '{print $1}' | grep -vE 'face|Inter|lo|tun' | awk -F ":" '{print $1}'`
echo "Необходимо добавить правила IPTABLES"
echo "iptables -I INPUT 1 -p udp --dport 1194 -j ACCEPT"
echo "iptables -I FORWARD -i $setevoj_interface -o tun0 -j ACCEPT"
echo "iptables -I FORWARD -i tun0 -o $setevoj_interface -j ACCEPT"
echo "iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE"
echo "пауза будет 5 секунд, скопируйте правила iptables чтоб потом их применить"
sleep 5
}

function dobavlenie_polzovatelej {
razryadnost_versia_OS
clear
echo "Уже существующие пользователи:"
grep -r 'Subject: CN=' /etc/openvpn/ | grep keys | grep crt | awk -F 'CN=' '{print $2}' | sort
echo ""
echo -e "${CYAN}Введи имя пользователя:${NORMAL}"
read user
echo -e "${CYAN}Защитить ключ клиента $user паролем?${NORMAL}"
echo "y/n ?"
read otv
if [[ "$otv" == "n" ]]; then
cd /etc/openvpn/easy-rsa/
/etc/openvpn/easy-rsa/easyrsa gen-req $user nopass
fi
if [[ "$otv" == "y" ]]; then
cd /etc/openvpn/easy-rsa/
echo -e "${WHITE}Необходимо задать сложный пароль${NORMAL}"
/etc/openvpn/easy-rsa/easyrsa gen-req $user
fi
clear
echo -e "${CYAN}Необходимо будет ввести ${RED}'yes' ${CYAN}после чего пароль ${WHITE}который задавался при создании приватного ключа${NORMAL}"
cd /etc/openvpn/easy-rsa/
/etc/openvpn/easy-rsa/easyrsa sign-req client $user
sleep 3;
echo "Публичный сертификат клиента"
ls /etc/openvpn/easy-rsa/pki/issued/$user.crt
echo ""
echo "Приватный ключ клиента"
ls /etc/openvpn/easy-rsa/pki/private/$user.key
echo ""
echo -e "${GREEN}Ключи которые необходимо передать клиенту${NORMAL}"
mkdir -p /etc/openvpn/keys/$user
cp /etc/openvpn/easy-rsa/pki/issued/$user.crt /etc/openvpn/keys/$user/
cp /etc/openvpn/easy-rsa/pki/private/$user.key /etc/openvpn/keys/$user/
cp /etc/openvpn/ta.key /etc/openvpn/keys/$user/
cp /etc/openvpn/ca.crt /etc/openvpn/keys/$user/

your_server_ip=`ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1 | head -1 | awk '{print $2}' | awk -F "/" '{print $1}'`
echo "client" > /etc/openvpn/keys/$user/$user.ovpn
echo "dev tun" >> /etc/openvpn/keys/$user/$user.ovpn
echo "proto udp" >> /etc/openvpn/keys/$user/$user.ovpn
echo "remote $your_server_ip 1194" >> /etc/openvpn/keys/$user/$user.ovpn
echo "resolv-retry infinite" >> /etc/openvpn/keys/$user/$user.ovpn
echo "nobind" >> /etc/openvpn/keys/$user/$user.ovpn
echo "persist-key" >> /etc/openvpn/keys/$user/$user.ovpn
echo "persist-tun" >> /etc/openvpn/keys/$user/$user.ovpn
echo "ca ca.crt" >> /etc/openvpn/keys/$user/$user.ovpn
echo "cert $user.crt" >> /etc/openvpn/keys/$user/$user.ovpn
echo "key $user.key" >> /etc/openvpn/keys/$user/$user.ovpn
echo "tls-auth ta.key 1" >> /etc/openvpn/keys/$user/$user.ovpn
echo "topology subnet" >> /etc/openvpn/keys/$user/$user.ovpn
echo "tls-client" >> /etc/openvpn/keys/$user/$user.ovpn
echo "pull" >> /etc/openvpn/keys/$user/$user.ovpn
echo "keysize 256" >> /etc/openvpn/keys/$user/$user.ovpn
echo "cipher AES-256-CBC" >> /etc/openvpn/keys/$user/$user.ovpn
echo "tun-mtu 1500" >> /etc/openvpn/keys/$user/$user.ovpn

chmod 600 /etc/openvpn/keys/$user/*
ls -lh /etc/openvpn/keys/$user/*
echo ""

echo -e "${GREEN}Файлы необходимо расположить в директории:${NORMAL}"
echo "C:\Program Files\OpenVPN\config"

if [[ "$versiaOS" == 'centos6' ]];
        then
        service openvpn restart
fi
if [[ "$versiaOS" == 'centos7' ]];
        then
        systemctl restart openvpn
fi
echo -e " ${NORMAL}"
}

function otziv_sertificata {
razryadnost_versia_OS
clear
echo "Уже существующие пользователи:"
grep -r 'Subject: CN=' /etc/openvpn/ | grep keys | grep crt | awk -F 'CN=' '{print $2}' | sort
echo ""
echo -e "${CYAN}Укажи пользователя для которого необходимо отозвать доступ${NORMAL}"
read user
cd /etc/openvpn/easy-rsa/
/etc/openvpn/easy-rsa/easyrsa revoke $user
rm -rf /etc/openvpn/crl.pem
rm -rf /etc/openvpn/keys/$user
find /etc/openvpn/ -name $user.* -exec rm {} \;
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/

if [[ "$versiaOS" == 'centos6' ]];
        then
        service openvpn restart
fi
if [[ "$versiaOS" == 'centos7' ]];
        then
        systemctl restart openvpn
fi
}
clear
echo -e "${WHITE}1${NORMAL} = ${CYAN}Добавить пользователя openvpn${NORMAL}"
echo -e "${WHITE}2${NORMAL} = ${CYAN}Удалить пользователя openvpn${NORMAL}"
echo -e "${WHITE}0${NORMAL} = ${GREEN}Выход${NORMAL}"
read otv_openvpn
case $otv_openvpn in
        1)
        proverka_ustanovlennogo_PO
        if [[ "$openvpn" != 'openvpn' ]];
                then
                ustanovka_openvpn
        fi
        dobavlenie_polzovatelej
        sleep 6
        openvpn
        ;;
        2)
        otziv_sertificata
        sleep 4
        openvpn
        ;;
        0) 
	echo ""
        ;;
        *)
        echo "Некорректный ответ"
        sleep 4
        openvpn
        ;;
esac
}



function udalenie_konfigov_php_fpm {
echo "" > $p/php-fpm
find /opt/remi/php*/root/etc/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/opt/remi/php*/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/nginx/conf.d/ -name ""$viborsaita".PHP_FPM.conf" 2>/dev/null  >> $p/php-fpm
for i in `cat $p/php-fpm`; do rm -rf $i 2>/dev/null; done

if [[ -f "/etc/nginx/conf.d/$viborsaita".conf-before_PHP_FPM ]]; then
        mv /etc/nginx/conf.d/"$viborsaita".conf-before_PHP_FPM /etc/nginx/conf.d/"$viborsaita".conf
fi
}




function Docker_php_versii {

function ustanovka_DOCKER {
razryadnost_versia_OS
proverka_ustanovlennogo_PO
if [[ "$docker" != "docker" ]];
        then
                if [[ "$versiaOS" == "centos6" ]];
                then
                yum -y install docker-io
                fi
                if [[ "$versiaOS" == "centos7" ]];
                then
                yum -y install yum-utils device-mapper-persistent-data lvm2
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum -y install docker-ce
                fi
if [[ "$versiaOS" == "centos7" ]];
        then
        systemctl enable docker
        systemctl start docker
fi
if [[ "$versiaOS" == "centos6" ]];
        then
        chkconfig docker on
        service docker start
fi
fi
}

function docker_apache_php53 {
ustanovka_DOCKER
dock_php53=`docker ps | grep apache_php53 | awk '{print $2}'`
if [[ "$dock_php53" != 'apache_php53' ]]; then
mkdir -p $p/apache_php53
echo "FROM centos:6
MAINTAINER mid
RUN yum -y install httpd mod_ssl \
&& yum -y install php php-common php-gd php-mysql php-xml php-mbstring php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8053|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8053|' /etc/httpd/conf/httpd.conf
EXPOSE 8053
ENV HOSTNAME apache_php53
ENV NAME apache_php53
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]" > $p/apache_php53/dockerfile
cd $p/apache_php53/
docker build -t apache_php53 .
docker run -dti --restart=always --name apache_php53 --hostname=apache_php53 -p 8053:8053 -v /etc/httpd/conf.d/docker53:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php53
docker exec apache_php53 service  httpd restart
cd ~/
rm -rf $p/apache_php53
fi
}

function docker_apache_php54 {
ustanovka_DOCKER
dock_php54=`docker ps | grep apache_php54 | awk '{print $2}'`
if [[ "$dock_php54" != 'apache_php54' ]]; then
mkdir -p $p/apache_php54

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php54 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8054|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8054|' /etc/httpd/conf/httpd.conf
EXPOSE 8054
ENV HOSTNAME apache_php54
ENV NAME apache_php54
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php54/dockerfile
cd $p/apache_php54/
docker build -t apache_php54 .
docker run -dti --restart=always --name apache_php54 --hostname=apache_php54 -p 8054:8054 -v /etc/httpd/conf.d/docker54:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php54
docker exec apache_php54 service  httpd restart
cd ~/
rm -rf $p/apache_php54
fi
}

function docker_apache_php55 {
ustanovka_DOCKER
dock_php55=`docker ps | grep apache_php55 | awk '{print $2}'`
if [[ "$dock_php55" != 'apache_php55' ]]; then
mkdir -p $p/apache_php55

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php55 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8055|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8055|' /etc/httpd/conf/httpd.conf
EXPOSE 8055
ENV HOSTNAME apache_php55
ENV NAME apache_php55
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php55/dockerfile
cd $p/apache_php55/
docker build -t apache_php55 .
docker run -dti --restart=always --name apache_php55 --hostname=apache_php55 -p 8055:8055 -v /etc/httpd/conf.d/docker55:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php55
docker exec apache_php55 service  httpd restart
cd ~/
rm -rf $p/apache_php55
fi
}

function docker_apache_php56 {
ustanovka_DOCKER
dock_php56=`docker ps | grep apache_php56 | awk '{print $2}'`
if [[ "$dock_php56" != 'apache_php56' ]]; then
mkdir -p $p/apache_php56

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php56 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8056|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8056|' /etc/httpd/conf/httpd.conf
EXPOSE 8056
ENV HOSTNAME apache_php56
ENV NAME apache_php56
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php56/dockerfile
cd $p/apache_php56/
docker build -t apache_php56 .
docker run -dti --restart=always --name apache_php56 --hostname=apache_php56 -p 8056:8056 -v /etc/httpd/conf.d/docker56:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php56
docker exec apache_php56 service  httpd restart
cd ~/
rm -rf $p/apache_php56
fi
}


function docker_apache_php70 {
ustanovka_DOCKER
dock_php70=`docker ps | grep apache_php70 | awk '{print $2}'`
if [[ "$dock_php70" != 'apache_php70' ]]; then
mkdir -p $p/apache_php70

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php70 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8070|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8070|' /etc/httpd/conf/httpd.conf
EXPOSE 8070
ENV HOSTNAME apache_php70
ENV NAME apache_php70
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php70/dockerfile
cd $p/apache_php70/
docker build -t apache_php70 .
docker run -dti --restart=always --name apache_php70 --hostname=apache_php70 -p 8070:8070 -v /etc/httpd/conf.d/docker70:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php70
docker exec apache_php70 service  httpd restart
cd ~/
rm -rf $p/apache_php70
fi
}

function docker_apache_php71 {
ustanovka_DOCKER
dock_php71=`docker ps | grep apache_php71 | awk '{print $2}'`
if [[ "$dock_php71" != 'apache_php71' ]]; then
mkdir -p $p/apache_php71

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php71 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8071|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8071|' /etc/httpd/conf/httpd.conf
EXPOSE 8071
ENV HOSTNAME apache_php71
ENV NAME apache_php71
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php71/dockerfile
cd $p/apache_php71/
docker build -t apache_php71 .
docker run -dti --restart=always --name apache_php71 --hostname=apache_php71 -p 8071:8071 -v /etc/httpd/conf.d/docker71:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php71
docker exec apache_php71 service  httpd restart
cd ~/
rm -rf $p/apache_php71
fi
}

function docker_apache_php72 {
ustanovka_DOCKER
dock_php72=`docker ps | grep apache_php72 | awk '{print $2}'`
if [[ "$dock_php72" != 'apache_php72' ]]; then
mkdir -p $p/apache_php72

echo "FROM centos:6
MAINTAINER mid
RUN yum -y install wget epel-release \
&& wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
&& rpm -Uvh remi-release-6.rpm \
&& yum -y install yum-utils \
&& yum-config-manager --enable remi-php72 \
&& yum -y install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo \
&& sed -i 's|Listen 80|Listen 8072|' /etc/httpd/conf/httpd.conf \
&& sed -i 's|#ServerName www.example.com:80|ServerName www.example.com:8072|' /etc/httpd/conf/httpd.conf
EXPOSE 8072
ENV HOSTNAME apache_php72
ENV NAME apache_php72
VOLUME [\"/etc/httpd/conf.d/\", \"/var/www/\"]
ENTRYPOINT [\"/usr/sbin/httpd\", \"-D\", \"FOREGROUND\"]"  > $p/apache_php72/dockerfile
cd $p/apache_php72/
docker build -t apache_php72 .
docker run -dti --restart=always --name apache_php72 --hostname=apache_php72 -p 8072:8072 -v /etc/httpd/conf.d/docker72:/etc/httpd/conf.d/ -v /var/www/:/var/www/ apache_php72
docker exec apache_php72 service  httpd restart
cd ~/
rm -rf $p/apache_php72
fi
}

function dobavlenie_konfig_fail_v_apache_php53 {
docker_apache_php53
clear
echo -e "${CYAN}Укажи для какого сайта php-5.3 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker53 ]
then
mkdir -p /etc/httpd/conf.d/docker53
fi
echo "<VirtualHost *:8053>" > /etc/httpd/conf.d/docker53/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker53/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php5_module modules/libphp5.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php5_module modules/libphp5-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker53/$konf_file

docker exec apache_php53 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8053;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php54 {
docker_apache_php54
clear
echo -e "${CYAN}Укажи для какого сайта php-5.4 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker54 ]
then
mkdir -p /etc/httpd/conf.d/docker54
fi
echo "<VirtualHost *:8054>" > /etc/httpd/conf.d/docker54/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker54/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php5_module modules/libphp5.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php5_module modules/libphp5-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker54/$konf_file

docker exec apache_php54 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8054;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php55 {
docker_apache_php55
clear
echo -e "${CYAN}Укажи для какого сайта php-5.5 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker55 ]
then
mkdir -p /etc/httpd/conf.d/docker55
fi
echo "<VirtualHost *:8055>" > /etc/httpd/conf.d/docker55/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker55/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php5_module modules/libphp5.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php5_module modules/libphp5-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker55/$konf_file

docker exec apache_php55 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
############# данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8055;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php56 {
docker_apache_php56
clear
echo -e "${CYAN}Укажи для какого сайта php-5.6 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker56 ]
then
mkdir -p /etc/httpd/conf.d/docker56
fi
echo "<VirtualHost *:8056>" > /etc/httpd/conf.d/docker56/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker56/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php5_module modules/libphp5.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php5_module modules/libphp5-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker56/$konf_file

docker exec apache_php56 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8056;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php70 {
docker_apache_php70
clear
echo -e "${CYAN}Укажи для какого сайта php-7.0 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker70 ]
then
mkdir -p /etc/httpd/conf.d/docker70
fi
echo "<VirtualHost *:8070>" > /etc/httpd/conf.d/docker70/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker70/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php7_module modules/libphp7.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php7_module modules/libphp7-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker70/$konf_file

docker exec apache_php70 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm
udalenie_konfigov_php_fpm
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8070;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php71 {
docker_apache_php71
clear
echo -e "${CYAN}Укажи для какого сайта php-7.1 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker71 ]
then
mkdir -p /etc/httpd/conf.d/docker71
fi
echo "<VirtualHost *:8071>" > /etc/httpd/conf.d/docker71/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker71/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php7_module modules/libphp7.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php7_module modules/libphp7-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker71/$konf_file

docker exec apache_php71 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm



udalenie_konfigov_php_fpm




#urlkonfiga_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep PHP_FPM`
#urlkonfiga_nginx_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep -v PHP_FPM | grep .back`
#if [[ -f $urlkonfiga_php_fpm ]];
#        then
#        rm -rf $urlkonfiga_php_fpm
#        if [[ -f $urlkonfiga_nginx_php_fpm ]] ;
#                then
#                urlkonfiga_nginx_without_php_fpm=`echo $urlkonfiga_nginx_php_fpm | awk -F '.back' '{print $1}'`
#                mv $urlkonfiga_nginx_php_fpm $urlkonfiga_nginx_without_php_fpm
#        fi
#fi
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8071;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 3
}

function dobavlenie_konfig_fail_v_apache_php72 {
docker_apache_php72
clear
echo -e "${CYAN}Укажи для какого сайта php-7.2 должен работать как модуль apache ?${NORMAL}"
grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker |  awk '{print $2}'
echo ""
read viborsaita
urlkonfiga=`grep -r ServerName /etc/httpd/conf.d/ |grep -vi docker | grep $viborsaita  | awk -F ':' '{print $1}'`
konf_file=`ls $urlkonfiga | awk -F '/' '{print $5}'`
if ! [ -d /etc/httpd/conf.d/docker72 ]
then
mkdir -p /etc/httpd/conf.d/docker72
fi
echo "<VirtualHost *:8072>" > /etc/httpd/conf.d/docker72/$konf_file
cat $urlkonfiga | grep -Ei 'ServerAdmin|DocumentRoot|ServerName|ServerAlias|ErrorLog|CustomLog' >> /etc/httpd/conf.d/docker72/$konf_file
echo '        <IfModule prefork.c>
          LoadModule php7_module modules/libphp7.so
        </IfModule>
        <IfModule !prefork.c>
          LoadModule php7_module modules/libphp7-zts.so
        </IfModule>
        <FilesMatch \.php$>
            SetHandler application/x-httpd-php
        </FilesMatch>
        AddType text/html .php
        DirectoryIndex index.php
</VirtualHost>' >> /etc/httpd/conf.d/docker72/$konf_file

docker exec apache_php72 service  httpd restart

############# данное условие необходимо если ранее сайт работал в режиме php-fpm


udalenie_konfigov_php_fpm



#urlkonfiga_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep PHP_FPM`
#urlkonfiga_nginx_php_fpm=`grep -r server_name /etc/nginx/conf.d/ | grep $viborsaita | awk -F ':' '{print $1}' | grep -v PHP_FPM | grep .back`
#if [[ -f $urlkonfiga_php_fpm ]];
#        then
#        rm -rf $urlkonfiga_php_fpm
#        if [[ -f $urlkonfiga_nginx_php_fpm ]] ;
#                then
#                urlkonfiga_nginx_without_php_fpm=`echo $urlkonfiga_nginx_php_fpm | awk -F '.back' '{print $1}'`
#                mv $urlkonfiga_nginx_php_fpm $urlkonfiga_nginx_without_php_fpm
#        fi
#fi
############ данное условие необходимо если ранее сайт работал в режиме php-fpm

old_port=`grep 'proxy_pass ' /etc/nginx/conf.d/$konf_file | awk -F ':' '{print $3}' | awk -F ';' '{print $1}'`
sed -i "s|proxy_pass http://127.0.0.1:${old_port};|proxy_pass http://127.0.0.1:8072;|" /etc/nginx/conf.d/$konf_file
nginx -s reload
sleep 4
}
clear
echo -e "${CYAN}Укажи какая версия ${YELLOW}PHP ${CYAN}необходима, чтобы php на сайте работал как модуль apache?"
echo -e "${CYAN}Отметим, что будет установлен ${RED}DOCKER ${CYAN}с соответствуещей версией"
echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}php53${NORMAL}"
echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}php54${NORMAL}"
echo -e "${WHITE}\"3\"${NORMAL} = ${YELLOW}php55${NORMAL}"
echo -e "${WHITE}\"4\"${NORMAL} = ${YELLOW}php56${NORMAL}"
echo -e "${WHITE}\"5\"${NORMAL} = ${YELLOW}php70${NORMAL}"
echo -e "${WHITE}\"6\"${NORMAL} = ${YELLOW}php71${NORMAL}"
echo -e "${WHITE}\"7\"${NORMAL} = ${YELLOW}php72${NORMAL}"
echo -e "${WHITE}\"8\"${NORMAL} = ${MAGENTA}Установить все${NORMAL}"
echo -e "${WHITE}\"0\"${NORMAL} = ${GREEN}Выход${NORMAL}"
read otv
case $otv in
        1)
        dobavlenie_konfig_fail_v_apache_php53
        ;;
        2)
        dobavlenie_konfig_fail_v_apache_php54
        ;;
        3)
        dobavlenie_konfig_fail_v_apache_php55
        ;;
        4)
        dobavlenie_konfig_fail_v_apache_php56
        ;;
        5)
        dobavlenie_konfig_fail_v_apache_php70
        ;;
        6)
        dobavlenie_konfig_fail_v_apache_php71
        ;;
        7)
        dobavlenie_konfig_fail_v_apache_php72
        ;;
        8)
	clear
        docker_apache_php53
        docker_apache_php54
        docker_apache_php55
        docker_apache_php56
        docker_apache_php70
        docker_apache_php71
        docker_apache_php72
        ;;
        0)
        skript
        ;;
esac
}


function ustanovka_php_fpm {
proverka_ustanovlennogo_PO
if [[ "$php_fpm" != 'php-fpm' ]]; then
versiaphp=`php -v | grep cli | awk '{print $2}' | head -1 | awk -F '.' '{print $1"."$2}'`

if [ "$versiaOS" == 'centos7' ]; then
   podkluchenie_repozitoria_remi_centos7
fi
if [ "$versiaOS" == 'centos6' ]; then
   podkluchenie_repozitoria_remi_centos6
fi

case $versiaphp in
        5.3)
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        5.4)
        yum-config-manager --enable remi-php54
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        5.5)
        yum-config-manager --enable remi-php55
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        5.6)
        yum-config-manager --enable remi-php56
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        7.0)
        yum-config-manager --enable remi-php70
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        7.1)
        yum-config-manager --enable remi-php71
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
        7.2)
        yum-config-manager --enable remi-php72
        yum -y install php-fpm
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php-fpm
                systemctl start php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php-fpm on
                service php-fpm start
        fi
        ;;
esac
fi
}



function vibor_versii_php_fpm {
clear
echo -e "${WHITE}Какая версия php-fpm необходима:${NORMAL}"
proverka_ustanovlennogo_PO
versiaphp=`php -v | grep cli | awk '{print $2}' | head -1 | awk -F '.' '{print $1"."$2}'`
        echo -e "${WHITE}\"1\" = ${NORMAL}Нативная: ${YELLOW}$versiaphp ${NORMAL}"
        echo -e "${WHITE}\"4\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.4.9${NORMAL}"
        echo -e "${WHITE}\"5\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.5.9${NORMAL}"
        echo -e "${WHITE}\"6\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.6.9${NORMAL}"
        echo -e "${WHITE}\"7\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.0.9${NORMAL}"
        echo -e "${WHITE}\"71\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.1.9${NORMAL}"
        echo -e "${WHITE}\"72\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.2.5${NORMAL}"
	echo -e "${WHITE}\"0\"${NORMAL} = ${GREEN}Выход${NORMAL}"
read otv_ver

echo "$otv_ver" > $p/otvet_versia
if [[ $otv_ver == '0' ]];
	then
	rm -rf $p/otvet_versia
fi
case $otv_ver in
        1)
        if [[ "$php_fpm" != "php-fpm" ]];
        then
        ustanovka_php_fpm
        fi
        ;;
        4)
        if [[ "$php54_php_fpm" != "php54-php-fpm" ]];
        then
        ustanovka_php_fpm
        yum -y install php54-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9054|" /opt/remi/php54/root/etc/php-fpm.d/www.conf
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php54-php-fpm
                systemctl start php54-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php54-php-fpm on
                service php54-php-fpm start
        fi
        fi
        ;;
        5)
        ustanovka_php_fpm
        if [[ "$php55_php_fpm" != "php55-php-fpm" ]];
        then
        yum -y install php55-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9055|" /opt/remi/php55/root/etc/php-fpm.d/www.conf
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php55-php-fpm
                systemctl start php55-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php55-php-fpm on
                service php55-php-fpm start
        fi
        fi
        ;;
        6)
        ustanovka_php_fpm
        if [[ "$php56_php_fpm" != "php56-php-fpm" ]];
        then
        yum -y install php56-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9056|" /opt/remi/php56/root/etc/php-fpm.d/www.conf
                if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php56-php-fpm
                systemctl start php56-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php56-php-fpm on
                service php56-php-fpm start
        fi
        fi
        ;;
        7)
        ustanovka_php_fpm
        if [[ "$php70_php_fpm" != "php70-php-fpm" ]];
        then
        yum -y install php70-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9070|" /etc/opt/remi/php70/php-fpm.d/www.conf
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php70-php-fpm
                systemctl start php70-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php70-php-fpm on
                service php70-php-fpm start
        fi
        fi
        ;;
        71)
        ustanovka_php_fpm
        if [[ "$php71_php_fpm" != "php71-php-fpm" ]];
        then
        yum -y install php71-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9071|" /etc/opt/remi/php71/php-fpm.d/www.conf
        if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php71-php-fpm
                systemctl start php71-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php71-php-fpm on
                service php71-php-fpm start
        fi
        fi
        ;;
        72)
        ustanovka_php_fpm
        if [[ "$php72_php_fpm" != "php72-php-fpm" ]];
        then
        yum -y install php72-php-fpm
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:9072|" /etc/opt/remi/php72/php-fpm.d/www.conf
                if [ "$versiaOS" == 'centos7' ]; then
                systemctl enable php72-php-fpm
                systemctl start php72-php-fpm
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                chkconfig php72-php-fpm on
                service php72-php-fpm start
        fi
        fi
        ;;
        0)
	clear
	skript
        ;;
esac
}

function dob_fpm_conf {
vibor_versii_php_fpm
clear
otv_ver=`cat $p/otvet_versia`
rm -rf $p/otvet_versia
echo -e "${CYAN}Укажи для какого сайта необходимо изменить режим работы на ${RED}PHP-FPM${NORMAL}"
grep -r server_name /etc/nginx/conf.d/ | grep -vE 'default.conf|*.back|*.PHP_FPM.conf' |  awk '{print $2}' | sort| uniq

read viborsaita
echo "" > $p/php-fpm
find /opt/remi/php*/root/etc/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/opt/remi/php*/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/php-fpm.d/ -name ""$viborsaita".conf*" 2>/dev/null >> $p/php-fpm
find /etc/nginx/conf.d/ -name ""$viborsaita".PHP_FPM.conf"  >> $p/php-fpm
for i in `cat $p/php-fpm`; do rm -rf $i 2>/dev/null; done

if [[ -f "/etc/nginx/conf.d/$viborsaita".conf-before_PHP_FPM ]]; then
        mv /etc/nginx/conf.d/"$viborsaita".conf-before_PHP_FPM /etc/nginx/conf.d/"$viborsaita".conf
fi

konf_file=`ls /etc/nginx/conf.d/"$viborsaita".conf |awk -F '/' '{print $5}'`
user_group=`cat /etc/nginx/conf.d/"$viborsaita".conf | grep root | awk -F '/' '{print $4}'`
cat /etc/php-fpm.d/www.conf | grep -E '\[www\]|^user|^group|^listen|^listen.allowed_clients|pm = dynamic|^pm.max_children|^pm.start_servers|^slowlog|php_admin_value\[error_log\]|php_admin_flag\[log_errors\]|^;php_admin_value\[memory_limit\]|php_value\[session.save_handler\]|php_value\[session.save_path\]|php_value\[soap.wsdl_cache_dir\]|^pm.min_spare_servers|^pm.max_spare_servers' > /etc/php-fpm.d/$konf_file
sed -i 's|\;php_admin_value\[memory_limit\] \= 128M|php_admin_value\[memory_limit\] \= 128M|' /etc/php-fpm.d/$konf_file


sed -i "s|user \= apache|user \= ${user_group}|" /etc/php-fpm.d/$konf_file
sed -i "s|group \= apache|group \= ${user_group}|" /etc/php-fpm.d/$konf_file
sed -i "s|\[www\]|\[${user_group}\]|" /etc/php-fpm.d/$konf_file
port_usera_esli_est=`grep -rE 'user =|listen' /etc/php-fpm.d/ | grep $user_group | grep -vE '9000|listen.allowed_clients|9053|9054|9055|9056|9070|9071|9072' | grep listen | awk -F ':' '{print $3}'`

if [[ $port_usera_esli_est != '' ]];
        then
        port=`echo $port_usera_esli_est | tail -1`
        sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:${port}|" /etc/php-fpm.d/$konf_file
                else
                poslednij_port=`netstat -ntpl | grep php-fpm |awk '{print $4}' | awk -F ':' '{print $2}'| grep -vE '9053|9054|9055|9056|9070|9071|9072' | sort |tail -1`
                svobodnij_port=$(($poslednij_port + 1))
                port=`echo $svobodnij_port`
                sed -i "s|listen = 127.0.0.1:9000|listen = 127.0.0.1:${port}|" /etc/php-fpm.d/$konf_file
fi

###############
#nginx  проксирвоание сайта на php-fpm
###############

cat /etc/nginx/conf.d/"$viborsaita".conf | grep -vE '^location  \/|^proxy_pass|^proxy_set_header|^proxy_set_header|^proxy_set_header|^proxy_pass_header|}' > /etc/nginx/conf.d/"$viborsaita".PHP_FPM.conf
url_saita=`cat /etc/nginx/conf.d/"$viborsaita".PHP_FPM.conf | grep root | awk '{print $2}' | awk -F ';' '{print $1}'`
echo "}
location / {
root "$url_saita";
index index.html index.htm index.php;
}
location ~ .php$ {
include /etc/nginx/fastcgi_params;
fastcgi_pass 127.0.0.1:"$port";
fastcgi_index index.php;
fastcgi_param SCRIPT_FILENAME $url_saita\$fastcgi_script_name;
    }
} " >> /etc/nginx/conf.d/"$viborsaita".PHP_FPM.conf
sed -i '0,/location \/ {/s///' /etc/nginx/conf.d/"$viborsaita".PHP_FPM.conf  #убирает первое вхождение locanion / так как дублиируется
mv /etc/nginx/conf.d/"$viborsaita".conf /etc/nginx/conf.d/"$viborsaita".conf-before_PHP_FPM
###############
#nginx  проксирвоание сайта на php-fpm
###############


proverka_ustanovlennogo_PO
case $otv_ver in
        1)
        if [[ "$php_fpm" == "php-fpm" ]];
                then
                echo "ok"
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart php-fpm
                systemctl restart nginx
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart
                service nginx restart

        fi
        ;;
        4)
        if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                mv /etc/php-fpm.d/$konf_file /opt/remi/php54/root/etc/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
        5)
        if [[ "$php55_php_fpm" == "php55-php-fpm" ]];  then
                mv /etc/php-fpm.d/$konf_file /opt/remi/php55/root/etc/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
        6)
        if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                mv /etc/php-fpm.d/$konf_file /opt/remi/php56/root/etc/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
        7)
        if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                mv /etc/php-fpm.d/$konf_file /etc/opt/remi/php70/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
        71)
        if [[ "$php71_php_fpm" == "php71-php-fpm" ]];
        then
                mv /etc/php-fpm.d/$konf_file /etc/opt/remi/php71/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm 1>&2>/dev/null
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart 1>&2>/dev/null
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
        72)
        if [[ "$php72_php_fpm" == "php72-php-fpm" ]];
        then
                mv /etc/php-fpm.d/$konf_file /etc/opt/remi/php72/php-fpm.d/
        fi
        if [ "$versiaOS" == 'centos7' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                systemctl restart php54-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                systemctl restart php55-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                systemctl restart php56-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                systemctl restart php70-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                systemctl restart php71-php-fpm 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                systemctl restart php72-php-fpm
                fi
                systemctl restart nginx
                systemctl restart php-fpm 1>&2>/dev/null
        fi
        if [ "$versiaOS" == 'centos6' ]; then
                if [[ "$php54_php_fpm" == "php54-php-fpm" ]]; then
                service php54-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php55_php_fpm" == "php55-php-fpm" ]]; then
                service php55-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php56_php_fpm" == "php56-php-fpm" ]]; then
                service php56-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php70_php_fpm" == "php70-php-fpm" ]]; then
                service php70-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php71_php_fpm" == "php71-php-fpm" ]]; then
                service php71-php-fpm restart 1>&2>/dev/null
                fi
                if [[ "$php72_php_fpm" == "php72-php-fpm" ]]; then
                service php72-php-fpm restart
                fi
                service php-fpm restart 1>&2>/dev/null
                service nginx restart
        fi
        ;;
esac
}

##################################
######nexus begin#################
##################################

function ustanovka_nexus {
clear
if [[ "$docker" != "docker" ]];
        then
        ustanovka_DOCKER
fi


svobodnie_porti=`netstat -ntpl | grep -iE '8081'`
if [[ "$svobodnie_porti" != '' ]];
 then
 echo -e "${WHITE}Порт ${RED}8081 занят, ${WHITE}поэтому дальнейшая установка не возможна${NORMAL}"
  else
  proverka_est_li_image_nexus=`docker images| grep 'sonatype/nexus3'| awk '{print $1}' | awk -F '/' '{print $2}'`
        if [[ "$proverka_est_li_image_nexus" != "nexus3" ]];
         then
         echo -e "${WHITE}Образа для nexus нет, поэтому скачаем его${NORMAL}"
         echo ""
         docker pull sonatype/nexus3
         echo ""
        fi
  proverka_est_li_container_nexus_nezapushenij=`docker ps -a | grep -E 'nexus|Exited' | awk '{print $NF}'`
        if [[ "$proverka_est_li_container_nexus_nezapushenij" == "nexus" ]];
         then
         echo -e "${WHITE}Такой контейнер уже есть, но не запущен, поэтому мы его удалим и запустим по новой${NORMAL}"
         echo ""
         docker rm -f nexus
         echo ""
        fi
  echo -e "${WHITE}Укажи в какой директории должна храниться база nexus.${NORMAL}"
  echo -e "${WHITE}Отметим, что должно быть ${RED}НЕ МЕНЕЕ 5 гб свободного дисково пространства${NORMAL}"
  echo ""
  read otv_nexus
        if ! [ -d "$otv_nexus" ]; then
         echo ""
         echo -e "${RED}Такой директории нет, ${WHITE}но мы её создали${NORMAL}"
         mkdir -p $otv_nexus
         chown -R 200 $otv_nexus
        fi
  echo ""
  echo -e "${WHITE}Попробуем поднять контейнер${NORMAL}"
  docker run -d -p 8081:8081 --name nexus -v $otv_nexus:/nexus-data sonatype/nexus3
  echo ""
  echo -e "${WHITE}Подождём секунд 40 и посмотрим, что там в логе у контейнера${NORMAL}"
  sleep 40
  docker logs nexus| tail -5
  echo "

"
echo "________________________________________________________________"
fi
}

##################################
######nexus end###################
##################################

###################################
###########ansible begin###########
###################################

function ustanovka_ansible {
if [[ "$ansible" != 'ansible' ]];
	then
	adduser ansible
	usermod -a -G wheel ansible
	yum -y install ansible
        sed -i 's|#inventory      = /etc/ansible/hosts|inventory      = /etc/ansible/hosts|' /etc/ansible/ansible.cfg 
        sed -i 's|#forks          = 5|forks          = 5|' /etc/ansible/ansible.cfg 
	sed -i 's|#roles_path    = /etc/ansible/roles|roles_path    = /etc/ansible/roles:/usr/share/ansible/roles|' /etc/ansible/ansible.cfg
	sed -i 's|#host_key_checking = False|host_key_checking = False|' /etc/ansible/ansible.cfg
	sed -i 's|#log_path = /var/log/ansible.log|log_path = /var/log/ansible.log|' /etc/ansible/ansible.cfg
	sed -i 's|#private_key_file = /path/to/file|private_key_file = /home/ansible/.ssh/id_rsa|' /etc/ansible/ansible.cfg
	wheel=`cat /etc/sudoers| grep 'NOPASSWD: ALL' | grep wheel| awk '{print $1}' | awk -F '%' '{print $2}'`
	if [[ "$wheel" != 'wheel' ]];
		then
		echo '%wheel  ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
	fi
	yum install git -y
	git clone git@github.com:midnight47/ansible-playbook.git
	mkdir -p /etc/ansible/role_from_git
	mv ansible-playbook/* /etc/ansible/role_from_git/
	clear
	echo "скачанные роли и плейбуки эелать в директории /etc/ansible/role_from_git/"
	ls -lah /etc/ansible/role_from_git/
	sleep 10
fi
}


###################################
###########ansible end#############
###################################



function ustanovka_nano_mc {

nano=`rpm -qa | grep nano | awk -F "-" '{print $1}'`
mc=`rpm -qa | grep mc | awk -F "-" '{print $1}' | grep ^mc`
if  [[ "$nano" != 'nano' ]];
        then
        yum -y install nano
fi
if  [[ "$mc" != 'mc' ]];
        then
        yum -y install mc
fi
echo ""
echo "Включим отображение цвета в редакторе nano"
echo ""
echo "" > /usr/share/nano/mysettings.nanorc
cat <<EOF>> /usr/share/nano/mysettings.nanorc
#config file highlighting

syntax "conf" "(\.(conf|config|cfg|cnf|rc|lst|list|defs|ini|desktop|mime|types|preset|cache|seat|service|htaccess)$|(^|/)(\w*crontab|mirrorlist|group|hosts|passwd|rpc|netconfig|shadow|fstab|inittab|inputrc|protocols|sudoers)$|conf.d/|.config/)"

# default text
color magenta "^.*$"
# special values
icolor brightblue "(^|\s|=)(default|true|false|on|off|yes|no)(\s|$)"
# keys
icolor cyan "^\s*(set\s+)?[A-Z0-9_\/\.\%\@+-]+\s*([:]|\>)"
# commands
color blue "^\s*set\s+\<"
# punctuation
color blue "[.]"
# numbers
color red "(^|\s|[[/:|<>(){}=,]|\])[-+]?[0-9](\.?[0-9])*%?($|\>)"
# keys
icolor cyan "^\s*(\$if )?([A-Z0-9_\/\.\%\@+-]|\s)+="
# punctuation
color blue "/"
color brightwhite "(\]|[()<>[{},;:=])"
color brightwhite "(^|\[|\{|\:)\s*-(\s|$)"
# section headings
icolor brightyellow "^\s*(\[([A-Z0-9_\.-]|\s)+\])+\s*$"
color brightcyan "^\s*((Sub)?Section\s*(=|\>)|End(Sub)?Section\s*$)"
color brightcyan "^\s*\$(end)?if(\s|$)"
# URLs
icolor green "\b(([A-Z]+://|www[.])[A-Z0-9/:#?&$=_\.\-]+)(\b|$| )"
# XML-like tags
icolor brightcyan "</?\w+((\s*\w+\s*=)?\s*("[^"]*"|'[^']*'|!?[A-Z0-9_:/]))*(\s*/)?>"
# strings
color yellow "\"(\\.|[^"])*\"""'(\\.|[^'])*'"
# comments
color white "#.*$"
color blue "^\s*##.*$"
color white "^;.*$"
color white start="<!--" end="-->""

# XML-like tags
icolor brightcyan "</?\w+((\s*\w+\s*=)?\s*("[^"]*"|'[^']*'|!?[A-Z0-9_:/]))*(\s*/)?>"
# strings
color yellow "\"(\\.|[^"])*\"""'(\\.|[^'])*'"
# comments
color white "#.*$"
color blue "^\s*##.*$"
color white "^;.*$"
color white start="<!--" end="-->""
EOF

echo "" > /usr/share/nano/php.nanorc
cat <<EOF>> /usr/share/nano/php.nanorc

## Here is an example for PHP
##
syntax "php" "\.php[2345s~]?$"

## php markings
color brightgreen "(<\?(php)?|\?>)"

## functions
color white "\<[a-z_]*\("

## types
color green "\<(var|float|global|double|bool|char|int|enum|const)\>"

## structure
color brightyellow "\<(class|new|private|public|function|for|foreach|if|while|do|else|elseif|case|default|switch)\>"

## control flow
color magenta "\<(goto|continue|break|return)\>"

## strings
color brightyellow "<[^=       ]*>" ""(\.|[^"])*""

## comments
color brightblue "//.*"
color brightblue start="/\*" end="\*/"
#color blue start="<" end=">"
#color red "&[^;[[:space:]]]*;"

## Trailing whitespace
color ,green "[[:space:]]+$"
EOF
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; > ~/.nanorc
}


##########################
# конец описания функций #
##########################
####################### начало скрипта
echo ""
function skript {
proverka_ustanovlennogo_PO
clear
echo -e "${CYAN}Требуется работа с доменами или базой?${NORMAL}"
echo -e "${WHITE}\"1\" = С доменами${NORMAL}"
echo -e "${WHITE}\"2\" = С базой${NORMAL}"
echo -e "${WHITE}\"3\" = С сервером, утилитами${NORMAL}"
echo -e "${WHITE}\"0\" = ${GREEN}Выход${NORMAL}"
read otv_d_b
case $otv_d_b in
        1)
        clear
        echo -e "${CYAN}Добавить домен, или удалить, или изменить версию ${YELLOW}PHP?${NORMAL}"
        echo -e "${WHITE}\"1\"${NORMAL} = Добавить"
        echo -e "${WHITE}\"2\"${NORMAL} = Удалить"
        echo -e "${WHITE}\"3\"${NORMAL} = Изменить версию PHP"
	echo -e "${WHITE}\"0\"${NORMAL} = ${GREEN}Выход${NORMAL}"
        read otv
	if [ $otv == "1" ]; then
		clear
		if [[ "$versiaOS" == 'centos6'  ]]; then
			proverka_ustanovlennogo_PO
			ustanovka_apache_centos6
			ustanovka_nginx_centos6
			ustanovka_PHP_centos6
				else
				proverka_ustanovlennogo_PO
				ustanovka_apache_centos7
				ustanovka_nginx_centos7
				ustanovka_PHP_centos7
		fi
	        virthost_apache_dobavlenie
                if [ "$ex" != 'exit' ]; then
	                virthost_nginx_dobavlenie
                fi
                echo "готово"
                #добавил функцию для изменения загружаемого файла через сайт
                razmer_zagruzaemogo_faila
		skript
        fi
	if [ $otv == "2" ]; then
                clear
                virthost_udalenie
		skript
	fi
	if [ $otv == "3" ]; then
                clear
		echo -e "${CYAN}PHP должен работать как ${WHITE}fastcgi${NORMAL} ${CYAN}или как ${WHITE}модуль apacha${NORMAL} ${CYAN}или в режиме ${WHITE}php-fpm${NORMAL}"
		echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}fastcgi${NORMAL}"
		echo -e "${WHITE}\"2\"${NORMAL} = В данном случае можно выбрать разные версии php которые будут работать ${YELLOW}как модуль apache${NORMAL}, но будет установлен ${RED}docker${NORMAL}"
		echo -e "${WHITE}\"3\"${NORMAL} = ${YELLOW}php-fpm${NORMAL}"
		echo -e "${WHITE}\"0\"${NORMAL} = ${GREEN}Выход${NORMAL}"
		read otv_vibor
		if [ $otv_vibor == '1' ]; then
			clear
			izmenenie_versii_php_dlya_sajta
			skript
		fi
		if [ $otv_vibor == '2' ]; then
			clear
                        Docker_php_versii
                        skript
                fi
		if [ $otv_vibor == '3' ]; then
                        clear
                        dob_fpm_conf
                        skript
                fi
		if [ $otv_vibor == '0' ]; then
                        clear
                        skript
                fi

	fi
	if [ $otv == "0" ]; then
                clear
                skript
        fi
        ;;
        2)
        clear
        if [[ "$versiaOS" == 'centos6'  ]]; then
		proverka_ustanovlennogo_PO
	        ustanovka_mysql_centos6
        	        else
			proverka_ustanovlennogo_PO
                        ustanovka_mysql_centos7
        fi
        rabota_s_bazoi
	sleep 3
	skript
        ;;
        3)
	clear
        echo -e "${WHITE}\"1\"${NORMAL} = ${CYAN}Установить ${RED}альтернативные${CYAN} версии PHP${NORMAL}"
        echo -e "${WHITE}\"2\"${NORMAL} = ${CYAN}Установить ${RED}IoncubeLoader${CYAN} для всех альтернативных версий PHP${NORMAL}"
        echo -e "${WHITE}\"3\"${NORMAL} = ${CYAN}Установить редакторы ${RED}nano ${CYAN}и ${RED}midnight commander${NORMAL}"
        echo -e "${WHITE}\"4\"${NORMAL} = ${CYAN}Установить ${RED}PHPMyAdmin${NORMAL}"
        echo -e "${WHITE}\"5\"${NORMAL} = ${CYAN}Установить ${RED}ProFTPd${CYAN}, добавить виртуальных FTP пользователей${NORMAL}"
	echo -e "${WHITE}\"6\"${NORMAL} = ${CYAN}Установить ${RED}Samba${CYAN}, добавить,удалить директории${NORMAL}"
	echo -e "${WHITE}\"7\"${NORMAL} = ${CYAN}Установить ${RED}Openvpn${CYAN}, добавить/удалить пользователей${NORMAL}"	
	echo -e "${WHITE}\"8\"${NORMAL} = ${CYAN}Установить ${RED}ansible${CYAN}, добавить несколько ролей${NORMAL}"
        echo -e "${WHITE}\"9\"${NORMAL} = ${CYAN}Установить ${RED}nexus${CYAN},в docker контейнере${NORMAL}"
#	echo -e "${WHITE}\"8\"${NORMAL} = ${CYAN}Альтернативные версии PHP для работы php как модуль apache будут установлены в DOCKER${NORMAL}"
	echo -e "${WHITE}\"0\"${NORMAL} = ${GREEN}Выход${NORMAL}"
        read otv_serv
                        case $otv_serv in
                        1)
                        ustanovka_alternativnih_wersij_php
			skript
                        ;;
                        2)
                        ustanovkaIoncubeLoader
			skript
                        ;;
                        3)
                        ustanovka_nano_mc
			skript
                        ;;
                        4)
                        ustanovka_phpmyadmin
			skript
                        ;;
                        5)
                        FTP
			skript
			;;
			6)
			samba
			skript
			;;
			7)
			openvpn
			skript
			;;
			8)
			ustanovka_ansible
			dobavlenie_roli_new_server
			dobavlenie_roli_docker_docker_compose
			dobavlenie_roli_tomcat
			uvedomlenie_posle_ustanovki
			skript
			;;
			9)
			ustanovka_nexus
			sleep 2
			skript
			;;
#			8)
#			Docker_php_versii
#			skript
#                       ;;
			0)
			skript
			;;
                        esac

        ;;
	0)
	exit 1;
	;;
        *)
        echo -e "${RED}Некорректный ответ, работа скрипта завершена${NORMAL}"
        ;;
esac
}
####################### конец скрипта
skript



