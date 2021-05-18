FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1

FROM docker.ub.gu.se/rails-imagemagick7:ruby-2.5.8-2021-03-003

COPY --from=release /root/release/ /usr/src/app
RUN echo -e '#/bin/bash\numask 0002\nexec "$@"\n' > /var/tmp/umask.sh
RUN chmod +x /var/tmp/umask.sh
 
RUN bundle install

ENTRYPOINT ["/var/tmp/umask.sh"]

CMD ["sh", "-c", "rm -f /usr/src/app/tmp/pids/server.pid && rails server -b 0.0.0.0 -e $ENVIRONMENT"]
