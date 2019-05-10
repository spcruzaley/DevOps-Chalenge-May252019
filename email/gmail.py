from __future__ import print_function
import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import smtplib
import sys

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

def main(sender, receiver, subject, body, pwdSender, path):
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(path + '/token.pickle'):
        with open(path + '/token.pickle', 'rb') as token:
            creds = pickle.load(token) #, encoding='latin1')
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                path + '/credentials.json', SCOPES)
            creds = flow.run_local_server()
        # Save the credentials for the next run
        with open(path + '/token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    # creates SMTP session
    s = smtplib.SMTP('smtp.gmail.com', 587)

    # start TLS for security
    s.starttls()

    # Authentication
    s.login(sender, pwdSender)

    # message to be sent
    message = "\r\n".join([
      "From: " + sender,
      "To: " + receiver,
      "Subject: " + subject,
      "",
      body
    ])

    # sending the mail
    s.sendmail(sender, receiver, message)

    # terminating the session
    s.quit()

if __name__ == '__main__':
    sender = sys.argv[1]
    receiver = sys.argv[2]
    subject = sys.argv[3]
    body = sys.argv[4]
    pwdSender = sys.argv[5]
    path = sys.argv[6]

    main(sender, receiver, subject, body, pwdSender, path)
