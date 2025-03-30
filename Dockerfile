FROM mysql:latest
COPY ./db-init/ /docker-entrypoint-initdb.d/
EXPOSE 3306