#!/usr/bin/env bash

set -e

ursname=""
passwrd=""

while (( "$#" )); do
    case "$1" in
	-u|--username)
	    usrname=$2
	    shift 2
	    ;;
	-p|--password)
	    passwrd=$2
	    shift 2
	    ;;
	--)
	    shift
	    break
	    ;;
	-*|--*)
	    echo "Error: Unsupperted flag $1" >&2
	    exit 1
	    ;;
    esac
done

if [ -z $usrname ] || [ -z $passwrd ]; then
    echo "Must enter username and password -u username -p password"
    exit 1
fi

UNAME=${SUDO_USER:=${USER}}

IMAGE_UID=$(id -u ${UNAME})
IMAGE_GID=$(id -g ${UNAME})

echo "${GIT_USER}"

docker build . -t ue4-airsim2-ws \
    --build-arg UID=${IMAGE_UID} \
    --build-arg GID=${IMAGE_GID} \
    --build-arg UNAME=${UNAME} \
    --build-arg GIT_USER=${usrname} \
    --build-arg GIT_PASS=${passwrd}
    
BUILD_RESULT=$?

if [ "$?" != "0" ]; then
  echo "Either this script must be run with \"sudo\" or the user ${UNAME} must be a member of the \"docker\" group."
  exit 1
fi

if [ ! -d $HOME/Simulators ]; then
  sudo -u ${UNAME} mkdir $HOME/Simulators
fi

GPGARG="-v $HOME/.gnupg:/home/${UNAME}/.gnupg "
if [ ! -d $HOME/.gnupg ]; then
  echo "No GPG keys found; GPG signing will be unavailable."
  GPGARG=""
fi

if [ ! -f $HOME/.ssh/id_rsa ]; then
  echo "No SSH keys found; generating a new keypair."
  ssh-keygen
fi

init_file() {
  if [ ! -f $HOME/$1 ]; then
    sudo -u ${UNAME} touch $HOME/$1
  fi
}

init_file .gitconfig
init_file .vimrc
init_file .Xauthority

docker run \
    -it \
    --gpus=all \
    --cap-add=SYS_PTRACE \
    --name airsim2-ws \
    -e DISPLAY \
    -v $HOME/Simulators:/home/${UNAME}/src \
    -v $HOME/.Xauthority:/home/${UNAME}/.Xauthority \
    -v $HOME/.gitconfig:/home/${UNAME}/.gitconfig \
    -v $HOME/.vimrc:/home/${UNAME}/.vimrc \
    -v $HOME/.ssh:/home/${UNAME}/.ssh \
    -v $HOME/.local/share/JetBrains:/home/${UNAME}/.local/share/JetBrains \
    $GPGARG \
    --net host \
    --ipc host \
    ue4-airsim2-ws

echo "To restart this container, run:
sudo docker start -ai airsim2-ws"

# After the first time you run it, re-start it like so:
# sudo docker start -ai airsim2-ws

# To attach to a running container:
# sudo docker exec -it airsim2-ws /bin/bash
