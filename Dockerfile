FROM python:2.7.15 AS python
RUN virtualenv /venv
RUN /venv/bin/pip install requests

FROM freeradius/freeradius-server:3.0.20
RUN apt-get update
RUN apt-get -y install vim
COPY configs/clients.conf /etc/freeradius/clients.conf
COPY configs/default /etc/freeradius/sites-enabled/default
COPY configs/eap /etc/freeradius/mods-enabled/eap
COPY configs/inner-tunnel /etc/freeradius/sites-enabled/inner-tunnel
COPY configs/python /etc/freeradius/mods-enabled/python
COPY configs/users /etc/freeradius/users
COPY authenticators/okta.py /etc/freeradius/mods-config/python/okta.py
COPY --from=python /venv/lib/python2.7/site-packages /etc/freeradius/mods-config/python/

ENV OKTA_ORG="org.okta.com"
ENV OKTA_DOMAIN="org.com"
ENV OKTA_APITOKEN="ABCDEFGHIJKLMNOP"
ENV RADIUS_SECRET="testing123"
