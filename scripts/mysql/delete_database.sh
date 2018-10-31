#!/usr/bin/env bash

red='\033[01;31m'
green='\033[01;32m'
blue='\033[01;34m'
norm='\033[00m'

EXPECTED_ARGS=2
E_BADARGS=65
MYSQL=`which mysql`

ROOT_PWD="${ROOT_PWD:-test}"

Q1="DELETE FROM mysql.db WHERE db.Db = '${1}' AND db.User = '${2}';"
Q2="DELETE FROM mysql.user WHERE user.Host = '%' AND user.User = '${2}';"
Q3="DROP DATABASE ${1};"
Q4="FLUSH PRIVILEGES;"

if [ $# -ne $EXPECTED_ARGS ]
then
echo -e "\nUsage: $0 dbname dbuser\n"
exit $E_BADARGS
fi

echo -e "\n${blue}-Dropping mysql DATABASE ${red}${1}${norm}\n${blue}-Deleting mysql USER ${red}${2}${norm}\n"

for query in "$Q1" "$Q2" "$Q3" "$Q4"
do
$MYSQL -uroot -p"${ROOT_PWD}" -e "$query" && echo -e "$query ---> [${green}OK${norm}]" || echo -e "$query ---> [${red}BAD${norm}]"
done
echo -e " "

