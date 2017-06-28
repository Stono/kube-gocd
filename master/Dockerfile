FROM gocd/gocd-server:v17.6.0

RUN apk add apache2-utils

ENV TINI_SUBREAPER=true
ADD custom-boot.sh /usr/local/bin/
CMD ["custom-boot.sh"]
