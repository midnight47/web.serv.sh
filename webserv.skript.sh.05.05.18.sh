#!/bin/bash

#develop1
#test2
#develop user2
#########################
#описание скрипта начало#
#########################

#Данный скрипт служит, для первоначального развёртывания web сервера, с базовой настройкой основных сервисов: apache,nginx,mysql,php
#Для добавления/удаления доменных имён.
#Запускать РЕКОМЕНДУЕТСЯ на НЕ боевом сервере, чтобы каким-либо не учётнным способом, случайно не нарушить работу.
#При первом запуске будет проверено всё ли ПО установлено, далее будет предложено, что необходимо произвести, добавление или удаление домена.
#Предварительно в системе должен быть добавлен пользователь, под которым будет работать сайт
#Возможно создание/удаление базы данных и пользователя базы данных, а так же можно изменить пароль для пользователя базы
#В целях безопасности, после установки apache и nginx(server_tokens off;) будут автоамтически скрыты их версии.

#########################
#описание скрипта конец #
#########################



############################
#Назначение функций начало #
############################

#proverka_ustanovlennogo_PO - проверяет, установлены ли apache,nginx,mysql,php

#podkluchenie_repozitoria_epel - подключает репозиторий epel, в зависимости от разрядности системы, если не подключен.

#podkluchenie_repozitoria_webtatic - подключает репозиторий webtatic, если не подключен.

#podkluchenie_repozitoria_REMI - подключает репозиторий remi, если не подключен.

#ustanovka_apache - если апач не установлен, ставит, если отказаться, скрипт будет завершён, так же сразу устанавливает mod_fcgid, 
#отключает SELINUX (нужно для работы mod_fcgid) и ставит mod_rpaf, чтобы в логе Apache отображались корректные IP

#ustanovka_nginx - если nginx не установлен, ставит, но можно и не устанавливать. Если была выбрана установка, то апач будет работать на порту 8080

#ustanovka_mysql - если mysql не установлен, ставит, если отказаться, скрипт будет завершён

#ustanovka_PHP - если php не установлен, можно выбрать версию PHP.5.3, PHP.5.4, PHP.5.5, PHP.5.6, если отказаться, скрипт будет завершён.
#В данной функции будет выбран режим работы PHP: как модуль apache или как fastcgi

#ustanovka_PO - функция в которой собраны остальные функции с установкой apache,nginx,mysql,php

#virthost_apache_dobavlenie - в данной функции, если ранее был установлен nginx, а сейчас он удалён, но в конфигах остался старый порт 8080 исправляется на 80 порт
#Здесь же происходит первоначальный опрос:
#какой домен нужно добавить, под каким пользователем (если пользователь не существует, то скрипт завершит работу, пользователь должен быть в /etc/passwd),  
#какой режим работы PHP для данного сайта необходим: как модуль apache или как fastcgi. Если при установке PHP было указано, 
#что PHP должен работать как модуль apache, а при добавлении домена решили установить его как Fastcgi, то условие в данной функции всё поправит.
#в этой же функции при добавлении домена будет создан FCGIWrapper.
#Домашняя директория пользователя, задаётся переменной homedir=/var/www/$user, для файлов сайта домашней директорией является /var/www/$user/site/$domen/
#для логов /var/www/$user/logs/$domen.error.log для Wrapper /var/www/$user/php-cgi/ для php.ini /var/www/$user/php-cgi/
#конфиг файл для каждого сайта создаётся отдельно в директории /etc/httpd/conf.d/

#virthost_nginx_dobavlenie - в данной функции, если nginx установлен, то добавляется виртхост nginx для домена, существует выбор: использовать gzip сжатия для сайта или нет. 
#основные переменные берутся из функции virthost_apache_dobavlenie, логи хранятся в директории /var/www/$user/logs/$domen.nginx.error.log
#конфиг файл для каждого сайта создаётся отдельно в директории /etc/nginx/conf.d/

#virthost_udalenie - в данной функции, производится удаление конфиг файлов сайта. Если установлен apache и nginx, то будут удалены оба конфига сайта,
#если установлен только apache, то соответсвенно будет удалён только виртхост сайта апача.

#rabota_s_bazoi - в данной функции, производится создание/удаление базы данных и пользователя базы данных, а так же изменение пароля для указанного пользователя


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



###########################
#Назначение функций конец:#
###########################


clear
#Данное условие ограничивает работу скрипта, запуск возможен только из под root
if [ "$(whoami)" != 'root' ]; then
    echo -e $"${RED}У Вас нет прав запускать данный скрипт $0 не из под root, используйте sudo${NORMAL}"
        exit 1;
fi
p=`pwd`

#Данное условие проверяет разрядность системы 32/64  bit
if [ "$(uname -m)" == 'x86_64' ]
	then
	razrayd=64
	else
	razrayd=32
fi

#Данное условие устанавливает утилиту wget в случае если её нет
if [ "$(rpm -qa | grep wget | awk -F "-" '{print $1}')" != 'wget' ]
then
yum install wget -y
clear
fi
###########################
# начало описания функций #
###########################

#############################################################
function proverka_ustanovlennogo_PO {
chkconfig > $p/chkconfig_list
apache=`cat $p/chkconfig_list | grep httpd | awk '{print $1}' | head -1`
nginx=`cat $p/chkconfig_list | grep nginx | awk '{print $1}' | head -1`
mysql=`cat $p/chkconfig_list | grep -E 'mysqld|mysql' | awk '{print $1}' | head -1`
PHP=`yum list installed | grep php |  head -1| awk -F '.' '{print $1}' | tr '[A-Z]' '[a-z]'`
rm -rf $p/chkconfig_list
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
if [ "$mysql" == 'mysqld' ] || [ "$mysql" == 'mysql' ];
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
#############################################################

#############################################################
function podkluchenie_repozitoria_epel { 
epl=`yum repolist | grep epel | tail -1 | awk -F '*' '{print $2}' | awk '{print $1}'`
if [ "$epl" != 'epel' ]
	then
		yum -y install yum-utils yum-priorities
        	if [ "$razrayd" == '64' ]
                	then
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
#############################################################

#############################################################
function podkluchenie_repozitoria_webtatic {
webs=`yum repolist | grep webtatic | tail -1 | awk '{print $1}'`
if [ "$webs" != 'webtatic' ]
then
rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum-config-manager --enable channel
fi
}
#############################################################
function podkluchenie_repozitoria_REMI {
rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`
if [ "$rem" != 'remi-safe' ]
then
rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
fi
}
#############################################################
function ustanovka_apache {
if [ "$ap" == 'n' ]
        then
        echo -e "${GREEN}Apache не установлен, установить?  y/n ?${NORMAL}"
        read otv_apach
                if [ "$otv_apach" == 'y' ]
                        then
                        podkluchenie_repozitoria_epel
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

			yum -y install httpd-devel gcc
			echo "178.236.176.177 stderr.net" >> /etc/hosts
			wget http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz
			tar zxvf mod_rpaf-0.6.tar.gz
			rm -rf mod_rpaf-0.6.tar.gz
			sed -i '/178.236.176.177 stderr.net/ d' /etc/hosts
			cd mod_rpaf-0.6
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
#############################################################

#############################################################
function ustanovka_nginx {
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
#############################################################

#############################################################
function ustanovka_mysql {
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
				podkluchenie_repozitoria_REMI
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
			exit 1;
                fi
fi
}
#############################################################

#############################################################
function ustanovka_PHP {
#proverka_ustanovlennogo_PO
if [ "$ph" == 'n' ]
	then
	echo -e "${GREEN}PHP не установлен, установить?  y/n ?${NORMAL}"
        read otv_php
                if [ "$otv_php" == 'y' ]
                        then
			echo ""
			echo -e "${YELLOW}Какую версию PHP Вы хотите установить:${NORMAL}"
			echo -e "${WHITE}\"1\"${NORMAL} = ${BLUE}PHP.5.3${NORMAL}"
			echo -e "${WHITE}\"2\"${NORMAL} = ${BLUE}PHP.5.4${NORMAL}"
			echo -e "${WHITE}\"3\"${NORMAL} = ${BLUE}PHP.5.5${NORMAL}"
			echo -e "${WHITE}\"4\"${NORMAL} = ${BLUE}PHP.5.6${NORMAL}"
			read otv_ver
			case $otv_ver in
			1)
			rem=`yum repolist | grep remi | tail -1 | awk '{print $1}'`

			# Данное условие нужно, в случае если репозиторий remi уже был подключен и какую-то версию PHP уже ставили

			if [ "$rem" == 'remi-safe' ]
			then
			sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo
			fi
			yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc
			;;
			2)
			podkluchenie_repozitoria_epel
			podkluchenie_repozitoria_webtatic
			podkluchenie_repozitoria_REMI
			 
			#установка php5.4
			sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '10c\enabled=1\' /etc/yum.repos.d/remi.repo 
			yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc
			;;
			3)
                        podkluchenie_repozitoria_epel
			podkluchenie_repozitoria_webtatic
			podkluchenie_repozitoria_REMI
			
			#установка php5.5
			sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=1\' /etc/yum.repos.d/remi.repo 
			yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc
			;;
			4)
                        podkluchenie_repozitoria_epel
			podkluchenie_repozitoria_webtatic
			podkluchenie_repozitoria_REMI
			
			#установка php5.6
			sed -i '10c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '20c\enabled=0\' /etc/yum.repos.d/remi.repo && sed -i '30c\enabled=1\' /etc/yum.repos.d/remi.repo 
			yum -y install php php-common php-cli php-devel php-gd php-mbstring php-mcrypt php-mysql php-odbc php-pdo php-soap php-tidy php-xml php-xmlrpc
			;;
			esac
					echo ""
					echo -e "${YELLOW}В каком режиме PHP должен работать?${NORMAL}"
					echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}Как модуль apache${NORMAL}"
					echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Как Fastcgi${NORMAL} ${RED}(Рекомендуется)${NORMAL}"
					read otv_rez_rab
					if [ "$otv_rez_rab" == '2' ]
						then
						yum -y install php-cgi
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
#############################################################

#############################################################
function ustanovka_PO {
ustanovka_apache 
ustanovka_nginx
ustanovka_mysql
ustanovka_PHP
}
#############################################################

#############################################################
function virthost_apache_dobavlenie {

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
        echo -e "${RED}Извините, но такого пользователя нет, добавьте его и перезапустите скрипт $0${NORMAL}"
        exit 1;
fi
                echo ""
                echo -e "${CYAN}Выберите, PHP для сайта "$domen" будет работать как модуль APACHE или как FASTCGI?${NORMAL}"
                echo -e "${WHITE}\"1\"${NORMAL} = ${YELLOW}модуль Apache ${NORMAL}"
                echo -e "${WHITE}\"2\"${NORMAL} = ${YELLOW}Fastcgi ${NORMAL}"
                read otv_rezima_raboti
                case $otv_rezima_raboti in
                                1)
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
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
service httpd restart
fi
rm $p/peremen.syntax
                        ;;
                        2)
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
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
service httpd restart
fi
rm $p/peremen.syntax
                        ;;
                        *)
                        ex='exit' # Данная переменная нужна для проверки, при добавлении домена.
                        echo "БЛЯТЬ по Русcки же написано 1 или 2, хренли ты мне тут пишешь $otv_rezima_raboti"
                        ;;
                        esac
}
#############################################################

#############################################################
function virthost_nginx_dobavlenie {
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
service nginx restart
fi
rm $p/peremen.ng
fi
}
#############################################################

#############################################################
function virthost_udalenie {
echo -e "${CYAN}Введите домен который хотите удалить${NORMAL}"
read domen
apach_conf=`find /etc/httpd/conf.d/ -name "$domen.conf"`
nginx_conf=`find /etc/nginx/conf.d/ -name "$domen.conf"`
if [ "$fr_bk_end" == 'y' ]
then
	if [ -f "$apach_conf" ] || [ -f "$nginx_conf" ];
                then
		echo ""
                echo -e "${WHITE}Вы уверены, что хотите удалить конфиги домена $domen ${NORMAL}"
                echo "$apach_conf"
                echo "$nginx_conf"
                echo ""
                echo -e "${WHITE}y/n ?${NORMAL}"
                read otv_p
                       if [ "$otv_p" == 'y' ]
                          then
                          rm -rf $apach_conf $nginx_conf
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
#############################################################

#############################################################
function rabota_s_bazoi {
if [[ "$mys" == 'y' ]]
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

#############################################################

#############################################################
function ustanovka_alternativnih_wersij_php {

mysql55=`mysql -V | awk '{print $5}' | cut -c1-3` #5.5

#yum install -y libxml2-devel httpd-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel bzip2-devel libcurl-devel libjpeg-devel
#yum install -y libvpx-devel libpng-devel freetype-devel readline-devel libtidy-devel libxslt-devel httpd-devel libxml2 libxml2-devel openssl openssl-devel
#yum install -y bzip2 bzip2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel libXpm-devel freetype-devel t1lib-devel gmp-devel libicu-devel
#yum install -y libmcrypt libmcrypt-devel aspell-devel libtidy libtidy-devel libxslt-devel libwebp-devel gcc-c++ wget gcc libxml2-devel openssl-devel libcurl-devel
#yum install -y libpng-devel libmcrypt-devel libmhash-devel mysql-devel libtidy-devel libtool-ltdl-devel mhash mhash-devel glibc-headers libjpeg-devel


lst="libxml2-devel httpd-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel bzip2-devel libcurl-devel libjpeg-devel  libvpx-devel libpng-devel freetype-devel readline-devel libtidy-devel libxslt-devel httpd-devel libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel libXpm-devel freetype-devel t1lib-devel gmp-devel libicu-devel libmcrypt libmcrypt-devel aspell-devel libtidy libtidy-devel libxslt-devel libwebp-devel gcc-c++ wget gcc libxml2-devel openssl-devel libcurl-devel libpng-devel libmcrypt-devel libmhash-devel mysql-devel libtidy-devel libtool-ltdl-devel mhash mhash-devel glibc-headers libjpeg-devel man zip unzip php-common php-mbstring php-gd php-ldap php-odbc php-pear php-xml php-soap curl curl-devel php-xmlrpc php-snmp"
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
./configure --prefix=/opt/alt.php/php5.3.9/ --with-config-file-path=/opt/alt.php/php5.3.9/ --with-config-file-scan-dir=/opt/alt.php/php5.3.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl --with-libdir=lib --with-xpm-dir=/usr
make
make install
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
exit 1;
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
./configure --prefix=/opt/alt.php/php5.4.9/ --with-config-file-path=/opt/alt.php/php5.4.9/ --with-config-file-scan-dir=/opt/alt.php/php5.4.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl --with-vpx-dir=/usr --with-libdir=lib --with-xpm-dir=/usr
make
make install
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
exit 1;
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
./configure --prefix=/opt/alt.php/php5.5.9/ --with-config-file-path=/opt/alt.php/php5.5.9/ --with-config-file-scan-dir=/opt/alt.php/php5.5.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
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
exit 1;
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
./configure --prefix=/opt/alt.php/php5.6.9/ --with-config-file-path=/opt/alt.php/php5.6.9/ --with-config-file-scan-dir=/opt/alt.php/php5.6.9/php.d/ --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
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
exit 1;
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
./configure --prefix=/opt/alt.php/php7.0.9/ --with-config-file-path=/opt/alt.php/php7.0.9/ --with-config-file-scan-dir=/opt/alt.php/php7.0.9/php.d/  --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
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
exit 1;
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
./configure --prefix=/opt/alt.php/php7.1.9/ --with-config-file-path=/opt/alt.php/php7.1.9/ --with-config-file-scan-dir=/opt/alt.php/php7.1.9/php.d/  --with-layout=PHP --with-openssl --with-pear --enable-calendar --with-gmp --enable-exif --with-mcrypt --with-mhash --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl -with-curl --with-gd --enable-gd-native-ttf --with-libdir=lib64 --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-webp-dir=/usr --with-freetype-dir=/usr --with-libxml-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --enable-exif --enable-shmop --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --enable-pcntl
make
make install
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
exit 1;
fi  # конец условия (собрана пыха.7.1.9 или нет)
}

clear
echo ""
echo -e "${WHITE}Какую версию php нужно собрать?${NORMAL}"
echo -e "${WHITE}\"3\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.3.9${NORMAL}"
echo -e "${WHITE}\"4\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.4.9${NORMAL}"
echo -e "${WHITE}\"5\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.5.9${NORMAL}"
echo -e "${WHITE}\"6\"${NORMAL} = ${BLUE}PHP.${YELLOW}5.6.9${NORMAL}"
echo -e "${WHITE}\"7\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.0.9${NORMAL}"
echo -e "${WHITE}\"71\"${NORMAL} = ${BLUE}PHP.${YELLOW}7.1.9${NORMAL}"
echo -e "${WHITE}\"0\"${NORMAL} = ${BLUE}Установить ВСЁ ${YELLOW}5.3 - 7.1${NORMAL}"
read otv_ver
case $otv_ver in
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
0)
if ! [ -d /opt/alt.php/php5.3.9/ ];
        then
        ustanovkaPHP5.3.9
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
;;
esac
}
#############################################################

#############################################################
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
phpversii=`cat $p/phpversii.txt`
grep -r ServerName /etc/httpd/conf.d/ > $p/saiti.txt
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
service httpd restart
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
service httpd restart
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
service httpd restart
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
service httpd restart
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
service httpd restart
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
service httpd restart
fi
rm $p/peremen.syntax
;;
0)
sed -i "${nomer_wrap} s|${put_do_wrap}|        FCGIWrapper /var/www/${imya_user}/php-cgi/php.cgi .php|" $urlkonfiga
httpd -t 2> $p/peremen.syntax
apachSyntax=`cat $p/peremen.syntax`
if [ "$apachSyntax" == 'Syntax OK' ]
then
service httpd restart
fi
rm $p/peremen.syntax
;;
esac

}
#############################################################

#############################################################
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
#############################################################

#############################################################
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


#######################


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

############

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

############

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

cat <<EOF>> /var/www/pma/site/pma/config.inc.php
<?php
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
?>
EOF
sed -i 's|session.save_path = \"\/var\/lib\/php\/session\"|session.save_path = \/var\/www\/pma\/tmp|' /var/www/pma/php-cgi/php.ini
chmod 775 /var/www/pma/tmp/
chown -R pma:pma /var/www/pma/
chmod -R 000 /var/www/pma/site/pma/setup/

        else # если версия php5.5 или больше будет установлен phpmyadmin4.7.2

	wget https://files.phpmyadmin.net/phpMyAdmin/4.7.2/phpMyAdmin-4.7.2-all-languages.zip
	unzip phpMyAdmin-4.7.2-all-languages.zip
	mv /var/www/pma/site/pma/phpMyAdmin-4.7.2-all-languages/* /var/www/pma/site/pma/
	rm -rf /var/www/pma/site/pma/phpMyAdmin-4.7.2-all-languages

cat <<EOF>> /var/www/pma/site/pma/config.inc.php
<?php
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

\$cfg['blowfish_secret'] = '<83if<([^={/\'d8\\I)lWP"\'econ=<n]';
\$cfg['UploadDir'] = '/var/www/pma/tmp';
\$cfg['SaveDir'] = '/var/www/pma/tmp';
\$cfg['DefaultLang'] = 'ru';
\$cfg['ServerDefault'] = 1;
?>
EOF
	sed -i 's|session.save_path = \"\/var\/lib\/php\/session\"|session.save_path = \/var\/www\/pma\/tmp|' /var/www/pma/php-cgi/php.ini
	chmod 775 /var/www/pma/tmp/
	chown -R pma:pma /var/www/pma/
	chmod -R 000 /var/www/pma/site/pma/setup/
fi
service httpd restart 
service nginx restart
}

proverka_ustanovlennogo_PO2
phpmyadmin_dobavlenie_polzovatelja
phpmyadminapache
phpmyadminnginx
phpmyadmin_ustanovka

}
#############################################################

#############################################################
function FTP {
clear
function ustanovka_ftp {

ftp=`chkconfig | grep proftpd | awk '{print $1}'`
if [[ "$ftp" != proftpd  ]]
then
clear
yum -y install proftpd proftpd-utils
sleep 3
clear
chkconfig proftpd on
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

service proftpd restart
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
service proftpd restart

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
service proftpd restart
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
;;
2)
udalenie_virt_polzovatelya
;;
esac
}
#############################################################

#############################################################
function ustanovkaIoncubeLoader {
if [ "$(uname -m)" == 'x86_64' ]
        then
        razrayd=64
        else
        razrayd=32
fi

if ! [ -d /opt/alt.php/ioncube/ ]; #
        then
        cd /opt/alt.php/
                if [[ "$razrayd" == '64' ]];
                        then
                        wget http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
                        tar xvfz ioncube_loaders_lin_x86-64.tar.gz
                        else
                        wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
                        tar xvfz ioncube_loaders_lin_x86.tar.gz
                fi
fi

if ! [ -f /opt/alt.php/php7.1.9/ioncube_loader_lin_7.1.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_7.1.so /opt/alt.php/php7.1.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php7.1.9/ioncube_loader_lin_7.1.so" /opt/alt.php/php7.1.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi
if ! [ -f /opt/alt.php/php7.0.9/ioncube_loader_lin_7.0.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_7.0.so /opt/alt.php/php7.0.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php7.0.9/ioncube_loader_lin_7.0.so" /opt/alt.php/php7.0.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi

if ! [ -f /opt/alt.php/php5.6.9/ioncube_loader_lin_5.6.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.6.so /opt/alt.php/php5.6.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.6.9/ioncube_loader_lin_5.6.so" /opt/alt.php/php5.6.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi
if ! [ -f /opt/alt.php/php5.5.9/ioncube_loader_lin_5.5.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.5.so /opt/alt.php/php5.5.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.5.9/ioncube_loader_lin_5.5.so" /opt/alt.php/php5.5.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi
if ! [ -f /opt/alt.php/php5.4.9/ioncube_loader_lin_5.4.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.4.so /opt/alt.php/php5.4.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.4.9/ioncube_loader_lin_5.4.so" /opt/alt.php/php5.4.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi
if ! [ -f /opt/alt.php/php5.3.9/ioncube_loader_lin_5.3.so ];
        then
        cp /opt/alt.php/ioncube/ioncube_loader_lin_5.3.so /opt/alt.php/php5.3.9/ 2>/dev/null
        chown -R root:root /opt/alt.php/
        sed -i "/\[PHP\]/a zend_extension=/opt/alt.php/php5.3.9/ioncube_loader_lin_5.3.so" /opt/alt.php/php5.3.9/php.d/php.ini 2>/dev/null
        service httpd restart
fi
}

#############################################################



##########################
# конец описания функций #
##########################
####################### начало скрипта
echo ""
proverka_ustanovlennogo_PO
#ustanovka_PO
clear
echo -e "${CYAN}Требуется работа с доменами или базой?${NORMAL}"
echo -e "${WHITE}\"1\" = С доменами${NORMAL}"
echo -e "${WHITE}\"2\" = С базой${NORMAL}"
echo -e "${WHITE}\"3\" = С сервером, утилитами${NORMAL}"
read otv_d_b
case $otv_d_b in
	1)
	clear
	ustanovka_PO
	echo -e "${CYAN}Добавить домен, или удалить, или изменить версию ${YELLOW}PHP?${NORMAL}"
	echo -e "${WHITE}\"1\"${NORMAL} = Добавить"
	echo -e "${WHITE}\"2\"${NORMAL} = Удалить"
	echo -e "${WHITE}\"3\"${NORMAL} = Изменить версию PHP"
	read otv
		if [ $otv == "1" ]
			then
	       		clear
	 	        virthost_apache_dobavlenie
		        	if [ "$ex" != 'exit' ]
			        then
		        	virthost_nginx_dobavlenie
	     			fi
		        echo "готово"
			#добавил функцию для изменения загружаемого файла через сайт
			razmer_zagruzaemogo_faila
		fi
		if [ $otv == "2" ]
			then
			clear
			virthost_udalenie
		fi
		if [ $otv == "3" ]
        		then
		        clear
		        izmenenie_versii_php_dlya_sajta
	        fi
	;;
	2)
	clear
	ustanovka_PO
	rabota_s_bazoi
	;;
	3)
	ustanovka_PO
	clear
	echo -e "${WHITE}\"1\"${NORMAL} = ${CYAN}Установить альтернативные версии PHP${NORMAL}"
	echo -e "${WHITE}\"2\"${NORMAL} = ${CYAN}Установить IoncubeLoader для всех альтернативных версий PHP${NORMAL}"
	echo -e "${WHITE}\"3\"${NORMAL} = ${CYAN}Установить редакторы nano и midnight commander${NORMAL}"
	echo -e "${WHITE}\"4\"${NORMAL} = ${CYAN}Установить PHPMyAdmin${NORMAL}"
	echo -e "${WHITE}\"5\"${NORMAL} = ${CYAN}Установить ProFTPd, добавить виртуальных FTP пользователей${NORMAL}"
        read otv_serv
			case $otv_serv in
			1)
			ustanovka_alternativnih_wersij_php
			;;
			2)
			ustanovkaIoncubeLoader
			;;
			3)
			ustanovka_nano_mc
			;;
			4)
			ustanovka_phpmyadmin
			;;
			5)
			FTP
			;;
			esac

	;;
	*)
	echo -e "${RED}Некорректный ответ, работа скрипта завершена${NORMAL}"
	;;
esac
####################### конец скрипта




