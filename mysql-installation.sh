#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read mysql_root_password

echo "scripting started executing at: $TIMESTAMP"

VALIDATE(){     #function is checking if the installation is SUCCESS or FAILURE.
if [ $1 -ne 0 ]
then 
    echo -e "$2....$R FAILURE $N"
    exit 1
else
    echo -e "$2....$G SUCCESS $N"
fi

}

if [ $USERID -ne 0 ] #checking if the USERID is 0 or not, if 0 it is a SUPER-USER, will have access for installation and exit status is 0
then
    echo "please run this script with root access."
    exit 1 #manually exit if there is a error.
else
    echo "You are a Super User"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1
# VALIDATE $? "Setting up root password"

#"Below code will be usefull for idempotent nature"
mysql -h db.goliexpense.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup....$Y SKIPPING $N"
fi
    
    
    

