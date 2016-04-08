import getpass, imaplib

M = imaplib.IMAP4_SSL('127.0.0.1')
M.login('test@arenstar.net', 'password')
M.select()
typ, data = M.search(None, 'ALL')
for num in data[0].split():
    typ, data = M.fetch(num, '(RFC822)')
    print 'Message %s\n%s\n' % (num, data[0][1])
M.close()
M.logout()
