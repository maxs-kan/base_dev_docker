#!/bin/bash

set -ue

USER_ID=${UID:-$(id -u)}    

GROUP_ID=${GID:-$(id -g)}

USER=user

WORK_TREE_DIR=${PROJECT_HOME_DIR:-"/home/"}

mkdir -p "${WORK_TREE_DIR}"

if ! id -u "${USER_ID}" &> /dev/null
then
    echo "Create a new user with ID: ${USER_ID}"

    groupadd -g ${GROUP_ID} ${USER}
    useradd -m -u ${USER_ID} -g ${GROUP_ID} ${USER}
    echo "${USER}:${USER}" | chpasswd 
    adduser ${USER} sudo

    chown -R ${USER} "${WORK_TREE_DIR}"
    chown -R ${USER} "${CONDA_DIR}"
    echo "Add conda dir to user"
else
    USER=$(id -un $USER_ID)
    echo "No user specified! user=${USER} with id=${USER_ID} is selected."
    echo "Specify user via environment variable USER_ID!"
fi

cd "${WORK_TREE_DIR}"

exec gosu ${USER} "$@"
