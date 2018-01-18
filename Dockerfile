FROM nginx:stable-alpine
RUN apk --no-cache add ca-certificates
RUN rm -rf /usr/share/nginx/html
COPY ./public /usr/share/nginx/html
