#!/bin/bash
set -e

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
			echo ""
      return 0; 
      ;;
    *)
			echo ""
      return 1
      ;;
  esac
}

function confirm {
  if ! yesno; then
    echo "Aborting."
    exit 1
  fi
}

function command_check {
  if ! type "$1" &> /dev/null; then
    echo " - $1"
    echo "You need $1 installed, please get it and try again"
    exit 1
  else
    echo " + $1"
  fi
}

function validate_requirements {
	echo "Checking CLI requirements..."
	command_check "envsubst"
	command_check "gcloud"
	command_check "kubectl"
	command_check "docker"
	command_check "docker-compose"
}

function validate_config {
	source go.env
	enforce_arg "GO_USERNAME" "Username for GoCD master"
	enforce_arg "GO_PASSWORD" "Password for GoCD master"
	enforce_arg "AGENT_AUTO_REGISTER_KEY" "Unique key that agents use to self register"
	enforce_arg "KUBE_NAMESPACE" "The namespace to deploy GoCD to"

	export_variable "GCP_REGISTRY" "$GCP_REGISTRY_HOST/$(gcloud config get-value project 2>/dev/null | xargs)"
	export_variable "SECRET_NAME" "kube-gocd"

  echo "Checking configuration...: "
  echo " + GoCD username: $GO_USERNAME"
  echo " + GoCD password: $GO_PASSWORD"
  echo " + Agent registration key: $AGENT_AUTO_REGISTER_KEY"
  echo " + GCP registry: $GCP_REGISTRY"
  echo " + Kubernetes namespace: $KUBE_NAMESPACE"
  echo ""

  echo "Check, double check, and triple check the above configuration."
  echo "If you're not happy, quit, and edit go.env"
  confirm
}

validate_requirements
echo ""
validate_config
