#!/bin/bash

IMAGE_ID=5600498a75fa
RESOURCE_CLASS_TOKEN=239586226acd7fe55233fe79812096f10f130cf242a3f47bcbe5702adf3440f8c7854076478b3dce
CIRCLECI_TOKEN=a21996172f944cf4648fd21dc051911f6f335064
RESOURCE_CLASS=danielholdsworth/docker-resource-class

#Set initial value for the RUNNING_TASKS variable
RUNNING_TASKS=1
#Gather the number of waiting tasks in the docker-resource-class
WAITING_TASKS=$(curl -X GET "https://runner.circleci.com/api/v2/runner/tasks?resource-class=$RESOURCE_CLASS" -H \
'Circle-Token: $CIRCLECI_TOKEN' | sed 's/[^0-9]*//g')


#if statement that is only actions if the waiting jobs are NOT 0
if (( $WAITING_TASKS != 0 )); then
    #for loop that creates as many runner containers as needed and suffixs a number to the runner name based on how many there is
    for i in $(seq $WAITING_TASKS); do
        docker run -d --rm --env CIRCLECI_TOKEN --env $RESOURCE_CLASS --name runner-$i $IMAGE_ID
    done

    echo "$WAITING_TASKS container(s) spun-up"

    #until block that polls for the amount of running jobs in the resource-class, runs until this number is 0
    until [ $RUNNING_TASKS == 0 ]; do
        RUNNING_TASKS=$(curl -X GET "https://runner.circleci.com/api/v2/runner/tasks/running?resource-class=$RESOURCE_CLASS" -H \
        'Circle-Token: $CIRCLECI_TOKEN' | sed 's/[^0-9]*//g')
    done

    echo "Running tasks at $RUNNING_TASKS...Shutting down containers..."

    #once the jobs are finished, loop through the intial variable and remove the created containers
    for i in $(seq $WAITING_TASKS); do
         docker rm $(docker stop $(docker ps -a -q --filter ancestor=circledan/rubyrunner --format="{{.ID}}"))
    done

    echo "$WAITING_TASKS containers removed...All done."
else
    echo "No jobs in Q"
fi
