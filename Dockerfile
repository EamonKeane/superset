FROM debian:stretch

# Superset version
ARG SUPERSET_VERSION=0.25.5

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/incubator-superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        python3-dev \
        python3-pip && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    curl https://raw.githubusercontent.com/${SUPERSET_REPO}/${SUPERSET_VERSION}/requirements.txt -o requirements.txt && \
    pip3 install --no-cache-dir \
        -r requirements.txt \
        Werkzeug==0.12.1 \
        flask-cors==3.0.3 \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyathena==1.2.5 \
        pyhive==0.5.1 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        sqlalchemy-clickhouse==0.1.3.post0 \
        sqlalchemy-redshift==0.5.0 \
        superset==${SUPERSET_VERSION} && \
    rm requirements.txt

RUN pip3 install cx_Oracle

### Oralce install taken from https://github.com/marcusrehm/airflow-dev-env/blob/master/Dockerfile ###

RUN apt-get update && apt-get install libaio-dev -y \
    libaio1 \
    libaio-dev \
    unzip
###
### Oralce install taken from https://github.com/marcusrehm/airflow-dev-env/blob/master/Dockerfile ###
RUN mkdir -p opt/oracle
COPY instantclient_12_2.zip /opt/oracle
RUN cd /opt/oracle && unzip instantclient_12_2.zip
RUN mv /opt/oracle/instantclient_12_2 /opt/oracle/instantclient
RUN ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so
RUN ln -s /opt/oracle/instantclient/libocci.so.12.1 /opt/oracle/instantclient/libocci.so
ENV ORACLE_HOME="/opt/oracle/instantclient"
ENV OCI_HOME="/opt/oracle/instantclient"
ENV OCI_LIB_DIR="/opt/oracle/instantclient"
ENV OCI_INCLUDE_DIR="/opt/oracle/instantclient/sdk/include"
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient:$ORACLE_HOME"
RUN echo '/opt/oracle/instantclient/' | tee -a /etc/ld.so.conf.d/oracle_instant_client.conf && ldconfig
###

# Configure Filesystem
COPY superset /usr/local/bin
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset"]
CMD ["runserver"]
USER superset
