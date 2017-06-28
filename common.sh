#!/bin/bash
set -e
source go.env

# required commands: 
# - envsubst
# - gcloud
# - kubectl
# - docker
# - docker-compose

function export_variable {
  ARG_NAME=$1
  ARG_VALUE=$2
  eval "export $ARG_NAME=$ARG_VALUE"
}

function enforce_arg {
  ARG_NAME="$1"
  ARG_DESC="$2"
  ARG_VALUE="${!1}"

  if [ -z "$ARG_VALUE" ]; then
    echo " - $ARG_NAME ($ARG_DESC) is a required value.  Please ensure it is set in go.env "
		exit 1 
  else
    export_variable "$ARG_NAME" "$ARG_VALUE"
    return;
  fi
}
enforce_arg "GO_USERNAME" "Username for GoCD master"
enforce_arg "GO_PASSWORD" "Password for GoCD master"
enforce_arg "AGENT_AUTO_REGISTER_KEY" "Unique key that agents use to self register"
enforce_arg "KUBE_NAMESPACE" "The namespace to deploy GoCD to"

export_variable "GCP_REGISTRY" "$GCP_REGISTRY_HOST/$(gcloud config get-value project 2>/dev/null | xargs)"
export_variable "SECRET_NAME" "kube-gocd"

function k() {
	kubectl --namespace=$KUBE_NAMESPACE $*
}

function tag() {
	docker tag stono/$1:latest $GCP_REGISTRY/$1:latest 
}

function push() {
	gcloud docker -- push $GCP_REGISTRY/$1:latest 
}

function tag_and_push() {
	tag $1
	push $1
}

function apply() {
	envsubst < $1 | kubectl --namespace=$KUBE_NAMESPACE apply -f -
}

function yesno {
  read -r -p "Do you want to continue? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      return 0; 
      ;;
    *)
      return 1
      ;;
  esac
}

function confirm {
  read -r -p "Do you want to continue? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      return; 
      ;;
    *)
      echo "Aborting."
      exit 1
      ;;
  esac
}
