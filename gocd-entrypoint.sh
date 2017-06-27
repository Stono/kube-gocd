#!/bin/bash
function stop()
{
	echo "Stopping GoCD..."
	kill $docker_pid
	kill $gocd_pid
	kill $tail_pid
	echo "Stopped."
	exit 0
}

function start() {
	echo "Starting GoCD Agent..."
	dockerd-entrypoint.sh & 
	docker_pid=$!

	./docker-entrypoint.sh &	
	gocd_pid=$!

	sleep 3
	tail -f /go/go-agent-bootstrapper.out.log &
	tail_pid=$!

	echo "Started (GoCD: $gocd_pid, Docker: $docker_pid, LogTail: $tail_pid)."
}

trap stop TERM INT SIGHUP
start
wait $gocd_pid
