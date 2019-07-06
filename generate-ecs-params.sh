#!/bin/bash

export `cd terraform && terraform output | tr -d " "`
export `cd terraform/postgresql && terraform output | tr -d " "`

envsubst < ecs-params.template.yml > ecs-params.yml

echo ecs-params.yml was generated.
