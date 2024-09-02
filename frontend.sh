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
        echo -e "$2 is.. $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is.. $G SUCCESS $N" |tee -a $LOG_FILE
    fi
}

echo "Script started excuting: $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx.."

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable the Nginx"

#systemctl start nginx
#VALIDATE $? "Starts the Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Remove the unwanted file"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Download the frontend application code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract the application code"

#cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf 
#VALIDATE "Copied Expense Nginx"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restart the Nginx"
