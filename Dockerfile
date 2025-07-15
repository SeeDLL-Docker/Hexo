FROM node:24-bookworm-slim

ENV HEXO_SERVER_PORT \
    APP_CHECK_UPDATE \
    GIT_USER \
    GIT_EMAIL

COPY --chmod=755 start.sh /start.sh

RUN chmod +x /start.sh && \
    apt-get update && \
    apt-get install git -y && \
    npm install -g hexo-cli && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

EXPOSE 4000

CMD /start.sh
