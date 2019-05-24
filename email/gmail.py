from google.auth.transport.requests import Request
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from email.mime.text import MIMEText
import smtplib
import os.path
import base64
import pickle
import sys
import os

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def get_service(path):
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(path + '/token.pickle'):
        with open(path + '/token.pickle', 'rb') as token:
            creds = pickle.load(token)
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

    try:
        service = build('gmail', 'v1', credentials=creds)
        return service
    except error:
        print("Error getting the service - $s" % error)

def create_message(to, subject, message_text):
    """Create a message for an email.

    Args:
      to: Email address of the receiver.
      subject: The subject of the email message.
      message_text: The text of the email message.

    Returns:
      An object containing a base64url encoded email object.
    """
    message = MIMEText(message_text)
    message['to'] = to
    message['subject'] = subject

    return {'raw': base64.urlsafe_b64encode(message.as_string())}

def send_message(service, message):
    """Send an email message.

    Args:
      service: Authorized Gmail API service instance.
      message: Message to be sent.

    Returns:
      Sent Message.
    """
    try:
        message = (service.users().messages().send(userId='me', body=message)
                   .execute())
        print("Message Id: %s" % message['id'])
        return message
    except Exception as e:
        print("Error occurred %s:" % e)

if __name__ == '__main__':
    #Note that the environment variables should be exist, in other case the
    #send email process will fail
    receiver = os.environ['GMAIL_RECEIVER']
    subject = os.environ['GMAIL_SUBJECT']
    body = os.environ['GMAIL_BODY']
    path = os.environ['WORK_DIR']

    message = create_message(receiver, subject, body)
    service = get_service(path)
    send_message(service, message)
