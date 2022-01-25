#!/bin/bash

WAITING_TASKS=$(curl -X GET "https://runner.circleci.com/api/v2/runner/tasks?resource-class=danielholdsworth/docker-resource-class" -H \
'Circle-Token: a21996172f944cf4648fd21dc051911f6f335064' | sed 's/[^0-9]*//g')
RUNNING_TASKS=1

if (( $WAITING_TASKS != 0 )); then
    for i in $(seq $WAITING_TASKS); do
        CIRCLECI_RESOURCE_CLASS=danielholdsworth/docker-resource-class \
        CIRCLECI_API_TOKEN=239586226acd7fe55233fe79812096f10f130cf242a3f47bcbe5702adf3440f8c7854076478b3dce \
        docker run -d --rm --env CIRCLECI_API_TOKEN --env CIRCLECI_RESOURCE_CLASS --name runner-$i 5600498a75fa
    done

    echo "$WAITING_TASKS containers spun-up"
    
    until [ $RUNNING_TASKS == 0 ]; do
        RUNNING_TASKS=$(curl -X GET "https://runner.circleci.com/api/v2/runner/tasks/running?resource-class=danielholdsworth/docker-resource-class" -H \
        'Circle-Token: a21996172f944cf4648fd21dc051911f6f335064' | sed 's/[^0-9]*//g')
    done
    
    echo "Running tasks at $RUNNING_TASKS...Shutting down containers..."

    for i in $(seq $WAITING_TASKS); do
         docker rm $(docker stop $(docker ps -a -q --filter ancestor=circledan/rubyrunner --format="{{.ID}}"))
    done

    echo "$WAITING_TASKS containers removed...All done."
else
    echo "No jobs in Q"
fi
