###########
# Imports #
###########
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import formataddr
from email.header import Header
import smtplib

class EmailMessage(object):
	
	def __init__(self, recipient):
		self.recipient = recipient
		self.sbj = ""
		self.msg = ""

	def subject(self, subject):
		self.sbj = subject

	def message(self, message):
		self.msg = message

	def get(self):
		return (self.recipient, self.sbj, self.msg)

class EmailClient(object):

	def __init__(self, name, email, signature='', host='localhost'):
		self.name = name
		self.email = email
		self.signature = signature
		self.client = smtplib.SMTP(host)
		self.recipient = None

	def _send(self, target, subject, message):
		msg = MIMEMultipart('alternative')
		msg['To'] = target
		msg['From'] = formataddr((str(Header(self.name, 'utf-8')), self.email))
		msg['Subject'] = subject
		msg.attach(MIMEText(message, 'plain'))

		self.client.sendmail(self.email, [target], msg.as_string())

	def set_recipient(self, recipient):
		self.recipient = recipient

	def send_email(self, email):
		if isinstance(email, EmailMessage):
			info = email.get()
			self._send(info[0], info[1], info[2])


if __name__ == "__main__":
	
	msg = EmailMessage('wtreible@udel.edu')
	msg.subject("Test Email")
	msg.message("Hello from the other side. I must have emailed a thousand times!")

	eclient = EmailClient('Wayne Treible', 'wtreible@biohen.dbi.udel.edu')
	eclient.send_email(msg)


