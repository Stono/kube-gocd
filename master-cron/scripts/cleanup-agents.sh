#!/bin/bash
set -e
API_URL="http://gocd-master-internal:8153/go/api"
gocd() {
  curl -s -X $1 "$API_URL/$2" \
    -H 'Accept: application/vnd.go.cd.v4+json' \
    -H 'Content-Type: application/json' \
    -u "$GO_USERNAME:$GO_PASSWORD"
}

get() {
  gocd "GET" "$1"
}

delete() {
  gocd "DELETE" "$1"
}

disable_agent() {
  curl -s -X PATCH "$API_URL/agents/$1" \
    -H 'Accept: application/vnd.go.cd.v4+json' \
    -H 'Content-Type: application/json' \
    -u "$GO_USERNAME:$GO_PASSWORD" \
    -d '{
          "agent_config_state": "Disabled"
        }'
}

delete_agent() {
  disable_agent "$1"
  delete "agents/$1"
}

get_agents() {
  get "agents"
}

export GO_USERNAME
export GO_PASSWORD
export API_URL
export -f delete_agent
export -f disable_agent
export -f get_agents
export -f delete
export -f get
export -f gocd

get_agents | jq  -c '._embedded.agents[] | select(.agent_state | contains("LostContact")) | .uuid' | xargs -r -n 1 bash -i -c 'delete_agent $@' _
get_agents | jq  -c '._embedded.agents[] | select(.agent_state | contains("Missing")) | .uuid' | xargs -r -n 1 bash -i -c 'delete_agent $@' _
echo "Cleanup complete."
exit 0
