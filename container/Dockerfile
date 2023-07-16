FROM sutoj/piler:1.4.4
COPY data/* /
RUN chmod +x /*.sh
RUN sed -i 's/thread_stack.*=.*/thread_stack            = 512M/g' /etc/piler/manticore.conf
CMD ["./start_and_import.sh"]
