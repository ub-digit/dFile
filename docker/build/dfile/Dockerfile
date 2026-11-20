FROM ruby:3.3.14

WORKDIR /usr/src/app

COPY . ./
RUN rm -f Gemfile.lock

# COPY --from=release /root/release/ /usr/src/app
RUN /bin/echo -e '#!/bin/bash\numask 0002\nexec "$@"' > /var/tmp/umask.sh
RUN chmod +x /var/tmp/umask.sh

RUN bundle install

ENTRYPOINT ["/var/tmp/umask.sh"]

CMD ["sh", "-c", "rm -f /usr/src/app/tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0 -e $ENVIRONMENT"]
