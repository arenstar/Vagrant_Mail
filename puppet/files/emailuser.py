import pam, syslog, pwd

def auth_log(msg):
  syslog.openlog(facility=syslog.LOG_AUTH)
  syslog.syslog("STAMP: " + msg)
  syslog.closelog()


def get_username(pamh):
  try:
    emailaddress = pamh.get_user()
  except pamh.exception:
    return pamh.PAM_USER_UNKNOWN

  emailarr = emailaddress.split('@')
  if len(emailarr) != 2:
    return pamh.PAM_SYSTEM_ERR

  username = emailarr[0]
  domain = emailarr[1]
  return username


def get_password(pamh):
  if pamh.authtok == None:
    passmsg = pamh.Message(pamh.PAM_PROMPT_ECHO_OFF, "Password: ")
    rsp = pamh.conversation(passmsg)
    pamh.authtok = rsp.resp
  try:
    password = pamh.authtok
  except pamh.exception:
    password = None
  if password == None:
    return pamh.PAM_SYSTEM_ERR
  return password

def pam_sm_authenticate(pamh, flags, argv):

  pam_service = 'system-auth'
  if len(argv) == 2:
    pam_service = argv[1]

  username = get_username(pamh)
  password = get_password(pamh)

  #auth_log(username)
  #auth_log(password)

  if pam.authenticate(username,password, service=pam_service):
    return pamh.PAM_SUCCESS
  return pamh.PAM_AUTH_ERR

def pam_sm_setcred(pamh, flags, argv):
  return pamh.PAM_SUCCESS

def pam_sm_acct_mgmt(pamh, flags, argv):
  username = get_username(pamh)
  try:
    pwent = pwd.getpwnam(username)
    #auth_log(str(pwent))
  except KeyError:
    retval = pamh.PAM_USER_UNKNOWN
    msg_style = pamh.PAM_ERROR_MSG
  return pamh.PAM_SUCCESS

def pam_sm_open_session(pamh, flags, argv):
  return pamh.PAM_SUCCESS

def pam_sm_close_session(pamh, flags, argv):
  return pamh.PAM_SUCCESS

def pam_sm_chauthtok(pamh, flags, argv):
  return pamh.PAM_SUCCESS
