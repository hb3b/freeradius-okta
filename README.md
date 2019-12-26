# FreeRADIUS + Okta

## Quickstart
```
docker run -it -p 1812:1812/udp \
-e OKTA_ORG=org.okta.com \
-e OKTA_DOMAIN=org.com \
-e OKTA_APITOKEN="ABCDEFGHIJKLMNOP" \
-e RADIUS_SECRET="testing123" \
hb3b/freeradius-okta
```

## Features
- Basic username/password authentication against Okta
- WPA2 Enterprise: PAP, GTC, TTLS-GTC, PEAP-GTC, and EAP-TLS (client certificates) support
- Dynamic VLAN assignment

## Testing
* https://itunes.apple.com/us/app/eaptest/id725566160?mt=12
* [eapol_test](/tree/master/testing)
