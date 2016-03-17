#!/usr/bin/python

import smtplib

sender = 'from@example.com'
receivers = ['test@arenstar.net']

message = """From: From Person <from@example.com>
To: To Person <test@arenstar.net>
Subject: SMTP e-mail test

This is a test e-mail message.
"""

try:
   smtpObj = smtplib.SMTP('localhost')
   smtpObj.sendmail(sender, receivers, message)         
   print "Successfully sent email"
except SMTPException:
   print "Error: unable to send email"
