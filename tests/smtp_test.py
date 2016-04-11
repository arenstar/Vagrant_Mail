from smtplib import SMTP
import datetime

debuglevel = 0

smtp = SMTP()
smtp.set_debuglevel(debuglevel)
smtp.connect('localhost', 25)
smtp.ehlo()

from_addr = "Contact <contact@davidarena.net>"
to_addr = "test@arenstar.net"

subj = "TEST no AUTH port 25"
date = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )

message_text = "Hello\nThis is a mail from your server\n\nBye\n"

msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( from_addr, to_addr, subj, date, message_text )

smtp.sendmail(from_addr, to_addr, msg)
smtp.quit()

smtp = SMTP()
smtp.set_debuglevel(debuglevel)
smtp.connect('localhost', 25)
smtp.ehlo()
smtp.starttls()
smtp.ehlo
smtp.login('test@arenstar.net', 'password')

from_addr = "Contact <contact@davidarena.net>"
to_addr = "test@arenstar.net"

subj = "TEST STARTTLS AUTH port 25"
date = datetime.datetime.now().strftime( "%d/%m/%Y %H:%M" )

message_text = "Hello\nThis is a mail from your server\n\nBye\n"

msg = "From: %s\nTo: %s\nSubject: %s\nDate: %s\n\n%s" % ( from_addr, to_addr, subj, date, message_text )

smtp.sendmail(from_addr, to_addr, msg)
smtp.quit()
