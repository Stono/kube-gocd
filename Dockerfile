# Take the mtaintained dind
FROM docker:stable-dind

# Take the gocd apline code
LABEL gocd.version="17.6.0" \
  description="GoCD agent based on alpine version 3.5" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="17.6.0-5142" \
  gocd.git.sha="be1ff52e07d80323fcc615864a64f3afe83b7016"

ADD "https://download.gocd.org/binaries/17.6.0-5142/generic/go-agent-17.6.0-5142.zip" /tmp/go-agent.zip
ADD https://github.com/krallin/tini/releases/download/v0.14.0/tini-static-amd64 /usr/local/sbin/tini
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/local/sbin/gosu

# allow mounting ssh keys, dotfiles, and the go server config and data
VOLUME /godata

# force encoding
ENV LANG=en_US.utf8

RUN \
# add mode and permissions for files we added above
  chmod 0755 /usr/local/sbin/tini && \
  chown root:root /usr/local/sbin/tini && \
  chmod 0755 /usr/local/sbin/gosu && \
  chown root:root /usr/local/sbin/gosu && \
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
  addgroup -g 1000 go && \ 
  adduser -D -u 1000 -G go go && \
  apk --update-cache upgrade && \ 
  apk add --update-cache openjdk8-jre-base git mercurial subversion openssh-client bash && \
# unzip the zip file into /go-agent, after stripping the first path prefix
  unzip /tmp/go-agent.zip -d / && \
  mv go-agent-17.6.0 /go-agent && \
  rm /tmp/go-agent.zip

ADD docker-entrypoint.sh /
ADD gocd-entrypoint.sh /

# Custom stuff
ENV TINI_SUBREAPER=true
CMD ["/gocd-entrypoint.sh"]
