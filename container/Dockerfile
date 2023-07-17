FROM sutoj/piler:1.4.4
RUN apt-get update && apt-get install -y mariadb-server nano
COPY data/* /
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql
RUN rm -f /etc/mysql/my.cnf && mkdir -p /etc/mysql && ln -s /my.cnf /etc/mysql/my.cnf
RUN chmod +x /*.sh

CMD ["./start_and_import.sh"]
