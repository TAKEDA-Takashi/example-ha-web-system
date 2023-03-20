#!/bin/bash

aws ecs register-task-definition --cli-input-json file://apps/task-definition.json
