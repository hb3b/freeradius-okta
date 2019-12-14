FROM amazonlinux:2

ARG FREERADIUS_VERSION=3.0.20
ARG FREERADIUS_URL=ftp://ftp.freeradius.org/pub/freeradius/freeradius-server-${FREERADIUS_VERSION}.tar.gz
ARG FREERADIUS_DL_DIR=/freeradius
ARG FREERADIUS_DIR=/usr/local/etc/raddb

RUN yum -y install make glibc-devel gcc patch python-pip tar gzip openssl libtalloc-devel openssl-devel python-devel

RUN pip install requests

RUN mkdir ${FREERADIUS_DL_DIR}
RUN curl -sL ${FREERADIUS_URL} | tar xvz -C ${FREERADIUS_DL_DIR} --strip-components 1

WORKDIR ${FREERADIUS_DL_DIR}

RUN sed -i -e 's|RLM_TYPE_THREAD_UNSAFE|RLM_TYPE_THREAD_SAFE|g' ${FREERADIUS_DL_DIR}/src/modules/rlm_python/rlm_python.c

RUN ./configure && make && make install

COPY configs/clients.conf ${FREERADIUS_DIR}/clients.conf
COPY configs/default ${FREERADIUS_DIR}/sites-enabled/default
COPY configs/eap ${FREERADIUS_DIR}/mods-enabled/eap
COPY configs/inner-tunnel ${FREERADIUS_DIR}/sites-enabled/inner-tunnel
COPY configs/python ${FREERADIUS_DIR}/mods-enabled/python
COPY configs/users ${FREERADIUS_DIR}/users
COPY authenticators/okta.py ${FREERADIUS_DIR}/mods-config/python/okta.py

RUN sed -i -e 's|auth = no|auth = yes|g' ${FREERADIUS_DIR}/radiusd.conf

RUN ln -s /dev/stdout /usr/local/var/log/radius/radius.log

ENV OKTA_ORG="org.okta.com"
ENV OKTA_DOMAIN="org.com"
ENV OKTA_APITOKEN="ABCDEFGHIJKLMNOP"
ENV RADIUS_SECRET="testing123"

CMD ["/usr/local/sbin/radiusd", "-f"]