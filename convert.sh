#!/bin/bash

function info() {
    echo "$(tput setaf 6)INFO$(tput setaf 7) $1"
}

function warning() {
    echo "$(tput setaf 3)WARN$(tput setaf 7) $1"
}

function error() {
    echo "$(tput setaf 1)FATA$(tput setaf 7) $1"
}


usage()
{
   echo "Utility wrapper script for kompose"
   echo ""
   echo "Usage: $(basename "$0") [OPTIONS]"
   echo ""
   echo "Options:"
   echo -e "\t-f\tPath to directory that holds the Docker Compose / Swarm YAML file(s)"
   echo -e "\t-o\tPath to save OpenShift YAML files to. Default is ./openshift"
   echo -e "\t-h\tShow usage"
   exit 1 
}


if [ $# -eq 0 ];
then
    usage
    exit 1
fi


while getopts "f:o:h" opt
do 
    case "$opt" in 
        f)
        COMPOSE_PATH="$(realpath $OPTARG)"
        ;;
        o)
        OPENSHIFT_PATH="$OPTARG"
        ;;
        h)
        usage
        exit 1
        ;;
        \?)
        echo "Unknown flag -$OPTARG."
        echo "see $(basename "$0") -h"
        echo ""
        usage
        exit 1
        ;;
        :)
        echo "Missing option argument for -$OPTARG"
        exit 1
        ;;
        *)
        echo "Unimplemented option -$options"
        exit 1
    esac
done

info "Checking minikube installation..."
if ! [ -x "$(command -v minikube)" ]; 
then
    error "minikube is not installed"
    exit 1
else
  info "minikube is installed..."
fi

info "Checking kompose installation..."
if ! [ -x "$(command -v kompose)" ]; 
then
    error "kompose is not installed"
    exit 1
else
  info "kompose is installed..."
fi

if [ ! -d "$COMPOSE_PATH" ];
then
    error "Path \"${COMPOSE_PATH}\" not found."
    exit 1
fi

COMPOSE_FILES=""

info "Finding compose files in \"${COMPOSE_PATH}\""
shopt -s nullglob
for COMPOSE_FILE in $COMPOSE_PATH/*.y*ml
do
    COMPOSE_FILES="${COMPOSE_FILES} -f=${COMPOSE_FILE}"
done

if [ -z "${COMPOSE_FILES}" ];
then
    error "No files found in path \"${COMPOSE_PATH}\""
    exit 1
fi

if [ -z "${OPENSHIFT_PATH}" ];
then
    BASE_DIR="$(dirname $0)"
    OPENSHIFT_PATH="${BASE_DIR}/openshift"
    warning  "OpenShift path not set. Using \"${OPENSHIFT_PATH}\""
fi


if [ ! -d "$OPENSHIFT_PATH" ];
then 
    warning "OpenShift path does not exist. Trying to create it."
    {
        mkdir -p "${OPENSHIFT_PATH}" 
    } || {
        error "Could not create directory."
        exit 1
    }
fi


info "Writing openshift files to \"${OPENSHIFT_PATH}\""


info "Starting convertion..."
kompose convert \
    --out=${OPENSHIFT_PATH} \
    --provider=openshift \
    --build=build-config \
    ${COMPOSE_FILES}

info "Done..."