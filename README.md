# GoCD agent with Docker (in docker)

## History
[Previously](https://github.com/Stono/ci-in-a-box), I had been running GoCD agents in docker containers, and then volume mounting the docker socket from the host, so that the agents could build and deploy docker containers.

This had multiple problems:
 
  - Mounting the host docker process is in no way isolated, and privilege escalation is a massive problem. 
  - Running on kubernetes, you had access to the underlying kubernetes machine and could destroy your cluster quite easily.
  - Agents weren't isolated, so a build job on one agent could affect a build job on another.
  - Things like volume mounts don't work, they'd be mounting from your agents host, rather than from the agents filesystem

So I started looking at [docker in docker](https://hub.docker.com/_/docker/) and thought it would be nice if my gocd agents ran their own docker daemon, totally isolated, no reason to have access to the host they're running on.

Docker in Docker carries its own problems, theres a good blog post on [here](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/), however the dind image is now officially supported, albeit a little slower (as you're doing filesystems on top of filesystems.

## Two containers, one pod
The idea on kubernetes is that your kubernetes pod has two containers, one is the gocd-agent, the other is docker-in-docker, they scale linearly, so each agent gets its own unique docker daemon.  The gocd-agent talks to the docker daemon via TLS.

Check out the kubernetes folder for examples.

## Shared volumes
You'll notice that both in docker-compose and kubernetes, I share a volume (/godata) between docker-in-docker, and the agent.  The reason for this is because if your agent runs a job, which does say, `docker run --rm -it -v $PWD:/test centos:7 /bin/bash`, it'd actually mount `$PWD` from the dind container, rather than the agent.  By sharing this volume you can mount files from your build directory into the child container.

## In a diagram
It's probably easier to digest as a diagram.  Each agent builds against it's own docker, and pushes up to a registry, no more `-v /var/run/docker.sock:/var/run/docker.sock` on your agents.

![docker in docker](images/kube_dind.png)

## The result
Is docker running on the agent, not accessing the host! :-)

![result](images/gocd.png)
