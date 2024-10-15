FROM nginx:1.26.0

WORKDIR /etc/nginx

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY ./index.html /usr/share/nginx/html/index.html

COPY mime.types /etc/nginx/mime.types

RUN mkdir -p /var/log/nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
