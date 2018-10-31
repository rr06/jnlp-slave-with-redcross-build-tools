#!/usr/bin/env bash

red='\033[01;31m'
blue='\033[01;34m'
green='\033[01;32m'
norm='\033[00m'

EXPECTED_ARGS=3
E_BADARGS=65
MYSQL=`which mysql`

ROOT_PWD="${ROOT_PWD:-test}"

Q1="CREATE DATABASE IF NOT EXISTS $1;"
Q2="GRANT USAGE ON *.* TO $2@'%' IDENTIFIED BY '$3';"
Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@'%';"
Q4="FLUSH PRIVILEGES;"

if [ $# -ne $EXPECTED_ARGS ]
then
echo -e "\nUsage: $0 dbname dbuser dbpass\n"
exit $E_BADARGS
fi

echo -e "\n${blue}-Creating mysql DATABASE ${red}${1}${norm}\n${blue}-Creating mysql USER ${red}${2}${norm}\n"
for query in "$Q1" "$Q2" "$Q3" "$Q4"
do
$MYSQL -uroot -p"${ROOT_PWD}" -e "$query" && echo -e "$query ---> [${green}OK${norm}]" || echo -e "$query ---> [${red}BAD${norm}]"

done
echo -e " "

#End of the creation script


