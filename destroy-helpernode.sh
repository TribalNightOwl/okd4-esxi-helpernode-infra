#!/bin/bash
source .env

docker build  . -t helpernode-builder

function docker_run {
        # First argument = working directory
        # Second argument = command to execute in the container
        docker run --rm -v $(pwd):/files -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}  -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK}" --env-file .env --workdir $1 helpernode-builder $2
}

docker_run /files/terraform "terraform destroy -auto-approve"