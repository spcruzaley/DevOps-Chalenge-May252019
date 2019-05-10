#!/bin/bash

#Validate if the environments variables are defined
result=0
if [ -z ${GMAIL_SENDER} ] ; then
	echo "Variables are not defined, taking from arguments"
	echo
	echo "Sending email..."
	python ${WORK_DIR}/gmail.py $1 $2 $3 $4 $5 $6
	result=$?
else
	echo "Variables are defined"
	echo
	echo "Sending email..."
	python ${WORK_DIR}/gmail.py "$GMAIL_SENDER" "$GMAIL_RECEIVER" "$GMAIL_SUBJECT" "$GMAIL_BODY" "$GMAIL_PASSWORD"  "$WORK_DIR"
	result=$?
fi

if [ $result -eq 0 ] ; then
	echo
	echo "Email sent successfully !!!"
fi
