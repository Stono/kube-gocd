FROM centos:7
RUN yum -y -q install jq cronie && \
		yum -y -q clean all

COPY crontab /etc/crontab
COPY scripts/* /usr/local/bin/
CMD ["crond", "-s"]
