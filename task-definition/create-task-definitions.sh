#!/bin/bash

PROJECT=enter-your-project-name

for env in "dev" "qa" "sandbox" "test" "uat" 
do
  family=$PROJECT-$env
  aws ecs register-task-definition --family $family --cli-input-json file://./task-definition.json 
done
