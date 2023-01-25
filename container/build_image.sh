#!/bin/bash

script_dir="$(dirname $(readlink -f $0))"
top_dir=$(dirname "${scripts_dir}")

registry="$(whoami)"
tag="latest"

function usage {
    cat << EOM
usage: $(basename "$0") [OPTION]...
    -i <occlum package> the occlum instance tar package after doing "occlum package"
    -r <registry prefix> the prefix string for registry
    -n <container image name> 
    -g <tag> container image tag
    -b <base image name>
    -h <usage> usage help
EOM
    exit 0
}

function process_args {
    while getopts ":i:r:n:g:b:h" option; do
        case "${option}" in
            i) package=${OPTARG};;
            r) registry=${OPTARG};;
            n) name=${OPTARG};;
            g) tag=${OPTARG};;
            b) base_image_name=${OPTARG};;
            h) usage;;
        esac
    done

    if [[ "${package}" == "" ]]; then
        echo "Error: Please specify your occlum instance package via -i <occlum package>."
        exit 1
    fi

    if [[ "${name}" == "" ]]; then
        echo "Error: Please specify your container image name via -n <container image name>."
        exit 1
    fi
}

function build_docker_occlum_image {
    cd ${top_dir}

    echo "Build docker Occlum image based on ${package} ..."
    sudo -E docker build \
        --network host \
        --build-arg http_proxy=$http_proxy \
        --build-arg https_proxy=$https_proxy \
        --build-arg OCCLUM_PACKAGE=${package} \
        -f ${base_image_name} . \
        -t ${registry}/${name}:${tag}
}

process_args "$@"
build_docker_occlum_image