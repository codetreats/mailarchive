FROM sutoj/piler:1.4.4
COPY start_and_import.sh /
COPY import.sh /
COPY add_user.sh /
COPY hash_password.php /
RUN chmod +x /*.sh
CMD ["./start_and_import.sh"]
