#!/bin/sh
 
db_user="root"; #имя пользователя для подключения к базе sql
db_pass="mysql_root-pass"; #пароль пользователя для подключения к базе sql
DATA=`date "+%Y-%m-%d"`; #записываем текущую дату в нужном нам формате
mysqldir="/home/backup/mysql"; #путь для архивов баз MySQL.
filesdir="/home/backup/files"; #путь для архивов файлов сайтов.
period="7"; #период хранения архивов
 
#формируем список баз, исключая information_schema и performance_schema
backbases=`echo "SHOW DATABASES" | mysql -u"${db_user}" -p"${db_pass}" | grep -v information_schema | grep -v Database | grep -v performance_schema`;
#---------------------------- архивируем файлы сайтов из /var/www/ ------------
tar zcf ${filesdir}/fs_${DATA}.tar.gz /var/www
#---------------------------- делаем дампы баз sql и упаковываем в архив ------------
mkdir ${mysqldir}/${DATA} 
for i in ${backbases}; do mysqldump -u"${db_user}" -p"${db_pass}" -l $i | gzip > ${mysqldir}/${DATA}/${i}.sql.gz; done 
tar zcf ${filesdir}/mysql_${DATA}.tar.gz /${mysqldir}/${DATA}
 
#формируем списки устаревших папок и файлов и удаляем их
rmdirectory=`find ${mysqldir} -type d -mtime +${period} -print`;
rmfiles=`find ${filesdir} -type f -mtime +${period} -name "*.gz" -print`;
 
for d in ${rmdirectory}; do rmdir $d; done
for f in ${rmfiles}; do rm -f $f; done
