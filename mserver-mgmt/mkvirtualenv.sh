#!/bin/bash

VENV_DIR=virt-python
PIP_CMD="pip" # $(which pip)
VENV_CMD=$(which virtualenv2 || which virtualenv)
if [ $? -ne 0 ]; then
    echo "Can't find virtualenv. You probably need to install it."
    exit 1
fi

$VENV_CMD --no-site-packages --distribute $VENV_DIR
source $VENV_DIR/bin/activate
$PIP_CMD -E $VENV_DIR install psycopg2
$PIP_CMD -E $VENV_DIR install bottle
$PIP_CMD -E $VENV_DIR install werkzeug
$PIP_CMD -E $VENV_DIR install bottle-werkzeug
