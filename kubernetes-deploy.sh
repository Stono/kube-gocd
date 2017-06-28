#!/bin/bash
source common.sh

if [ ! "$1" = "--deploy-only" ]; then
  docker-compose build
  tag_and_push "kube-gocd-master"
  tag_and_push "kube-gocd-master-cron"
  tag_and_push "kube-gocd-agent"
fi

if ! k get namespaces | grep $KUBE_NAMESPACE &>/dev/null; then
	kubectl create namespace $KUBE_NAMESPACE
fi

if k get secrets | grep $SECRET_NAME &>/dev/null; then
	k delete secret $SECRET_NAME
fi

k create secret generic $SECRET_NAME \
	--from-literal=user=$GO_USERNAME \
	--from-literal=pass=$GO_PASSWORD \
	--from-literal=agent_key=$AGENT_AUTO_REGISTER_KEY

EXISTING=0
if k get pods | grep gocd &>/dev/null; then
	EXISTING=1
fi

apply kubernetes/master.pod.yml
apply kubernetes/agent.pod.yml

if [ "$EXISTING" = "1" ]; then
	k delete pod -l tier=gocd
fi
