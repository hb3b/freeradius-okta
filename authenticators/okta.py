#! /usr/bin/env python2
#
# Okta Authentication
# Ben Hecht <hechtb3@gmail.com>
#

import requests
import radiusd
import os


def authenticate(p):
  radiusd.radlog(radiusd.L_INFO, '*** Authenticate: {} ***'.format(p))
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


def authorize(p):
  radiusd.radlog(radiusd.L_INFO, '*** Authorize: {} ***'.format(p))
  return radiusd.RLM_MODULE_OK


def post_auth(p):
  radiusd.radlog(radiusd.L_INFO, '*** Post Authentication: {} ***'.format(p))
  params = dict(i for i in p)

  if params['EAP-Type'] == 'TLS':
    radiusd.radlog(radiusd.L_INFO, 'Processing a certificate')
    return (radiusd.RLM_MODULE_OK,
            (
              ('Tunnel-Private-Group-Id', '1111111'),
              ('Tunnel-Type', 'VLAN'),
              ('Tunnel-Medium-Type', 'IEEE-802'),
            ), ())

  elif params['EAP-Type'] == 'GTC':
    radiusd.radlog(radiusd.L_INFO, 'Processing a GTC client')
    # For dynamic VLAN...
    # if params['User-Name'] == 'ben.hecht':
    vlan = '1'
    return (radiusd.RLM_MODULE_OK,
            (
              ('Tunnel-Private-Group-Id', vlan),
              ('Tunnel-Type', 'VLAN'),
              ('Tunnel-Medium-Type', 'IEEE-802'),
            ), ())

  elif params['EAP-Type'] == 'PEAP':  # Allow outer server to pass thru
    return radiusd.RLM_MODULE_OK
