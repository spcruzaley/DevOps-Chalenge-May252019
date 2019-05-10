FROM postgres:latest

#Install python2.7
RUN apt-get update -y
RUN apt-get install python2.7 -y
RUN apt-get install python-pip -y

#Install google api dependencies to send email through python
RUN pip2 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
