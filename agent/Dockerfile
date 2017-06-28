# Take the mtaintained dind
FROM gocd/gocd-agent-centos-7:v17.6.0

# Add docker to the agent
ENV DOCKER_VERSION=17.03.1
RUN curl --silent -O https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION-ce.tgz && \
		tar xzf docker-*.tgz && \
		mv docker/docker /usr/local/bin/docker && \
		rm -rf docker
