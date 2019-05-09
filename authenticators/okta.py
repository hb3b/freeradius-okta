#! /usr/bin/env python2
#
# Okta Authentication
# Ben Hecht <hechtb3@gmail.com>
#

import json
import requests
import radiusd
import os

def authenticate(p):
  attributes = dict(p)
  username = attributes['User-Name']
  password = attributes['User-Password']
  
  if not username.endswith('@{}'.format(os.environ['OKTA_DOMAIN'])):
    username = username + '@{}'.format(os.environ['OKTA_DOMAIN'])

  radiusd.radlog(radiusd.L_INFO, '*** Authenticating: {} ***'.format(username))

  url = 'https://{}/api/v1/authn'.format(os.environ['OKTA_ORG'])
  headers = {'Authorization': 'SSWS {}'.format(os.environ['OKTA_APITOKEN'])}
  payload = {'username': username, 'password': password}
  r = requests.post(url, json=payload, headers=headers)

  if r.status_code == 200:
    return radiusd.RLM_MODULE_OK
  else:
    return radiusd.RLM_MODULE_REJECT
