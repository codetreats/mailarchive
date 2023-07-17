FROM sutoj/piler:1.4.4
RUN apt-get update && apt-get install -q -y mariadb-server nano rsyslog
COPY data/* /
RUN rm -f /etc/mysql/my.cnf && mkdir -p /etc/mysql && ln -s /my.cnf /etc/mysql/my.cnf
RUN chmod +x /*.sh
RUN mkdir -p /etc/piler
RUN mkdir -p /var/piler/manticore
RUN mkdir -p /var/piler/store
CMD ["./start_and_import.sh"]
