FROM percona/percona-xtradb-cluster:5.7.25

USER root
RUN rm /var/log/mysqld.log && \
	ln -s /dev/stdout /var/log/mysqld.log \
	&& chown mysql:mysql /var/log/mysqld.log

COPY entrypoint.sh /entrypoint.sh
COPY functions.sh /functions.sh
