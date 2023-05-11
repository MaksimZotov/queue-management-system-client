FROM nginx:stable

WORKDIR /app

RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
ENV PATH "$PATH:/app/flutter/bin"

RUN flutter doctor
RUN flutter upgrade

COPY . .

RUN flutter update-packages --force-upgrade
RUN flutter pub get

RUN flutter build web --release --web-renderer html --dart-define SERVER_URL=http://141.98.169.103/api --dart-define CLIENT_URL=http://141.98.169.103

COPY /nginx/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]