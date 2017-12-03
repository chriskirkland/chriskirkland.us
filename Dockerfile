FROM nginx:stable-alpine
RUN apk --no-cache add ca-certificates
ADD ./public /usr/share/nginx/html
