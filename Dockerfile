FROM ruby:2.3

COPY . /app
WORKDIR /app
RUN bin/setup \
 && rake install

ENTRYPOINT ["zd_search"]
