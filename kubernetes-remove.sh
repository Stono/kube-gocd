#!/bin/bash
source common.sh
validate_config
set +e 

echo "This action will remove all GoCD deployments!"
confirm
k delete -f kubernetes/master.pod.yml 
k delete -f kubernetes/agent.pod.yml
k delete secret kube-gocd

echo "Would you also like to remove all the data volumes too?"
echo "WARNING: This includes your go config!"
if yesno; then
	k delete pvc -l tier=gocd 
fi
