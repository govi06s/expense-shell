#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log
mkdir -p $LOGS_FOLDER


USERID=$(id -u)

#echo "UserID is: $USERID"
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e " $R please run the script with root prevelages $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 is.. $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is.. $G SUCCESS $N" |tee -a $LOG_FILE
    fi
}

echo "Script started excuting: $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MYSQL server"
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starts the MYSQL server"
 mysql -h 172.31.39.201 -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
 if [ $? -ne 0 ]
 then
     echo "MYSQL root password is not setup, setting now" &>>$LOG_FILE
     mysql_secure_installation --set-root-pass ExpenseApp@1
     VALIDATE $? "Set the password for Expense"
 else
     echo -e "MYSQL root password is setup.. $Y SKIPPING $N" | tee -a $LOG_FILE
 fi
 