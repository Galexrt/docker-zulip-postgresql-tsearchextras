FROM sameersbn/ubuntu:14.04.20160416
MAINTAINER galexrt@googlemail.com

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.4 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && wget -qO - https://zulip.com/dist/keys/zulip-ppa.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && echo "deb http://ppa.launchpad.net/tabbott/zulip/ubuntu trusty main" > /etc/apt/sources.list.d/zulip.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
      postgresql-9.3-tsearch-extras hunspell-en-us \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && ln -sf /usr/share/postgresql/9.3/extension/tsearch_extras.control "/usr/share/postgresql/$PG_VERSION/extension/tsearch_extras.control" \
 && ln -sf /usr/lib/postgresql/9.3/lib/tsearch_extras.so "/usr/lib/postgresql/$PG_VERSION/lib/tsearch_extras.so" \
 && ln -sf /var/cache/postgresql/dicts/en_us.dict "/usr/share/postgresql/$PG_VERSION/tsearch_data/en_us.dict" \
 && ln -sf /var/cache/postgresql/dicts/en_us.affix "/usr/share/postgresql/$PG_VERSION/tsearch_data/en_us.affix" \
 && rm -rf ${PG_HOME} \
 && rm -rf /var/lib/apt/lists/*

COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
COPY zulip_english.stop "/usr/share/postgresql/$PG_VERSION/tsearch_data/zulip_english.stop"

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}"]
WORKDIR ${PG_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"]
