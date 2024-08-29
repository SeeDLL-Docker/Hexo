#!/bin/bash

function setup_env()
{
	if [ "$(ls -A /app)" ]; then
	    echo "***** App directory exists and has content, continuing *****";
	else
	    echo "***** App directory is empty, initialising with hexo and hexo-admin *****"
	    hexo init
	    npm install
	    npm install --save hexo-admin;
	fi;

	npm list -g | grep npm-check-updates  >/dev/null 2>&1 
	if [ $? -ne 0 ]; then
		echo "***** npm install npm-check-updates *****";
		npm install -g npm-check-updates
	fi
}

function setup_requirements()
{
	if [ ! -f /app/requirements.txt ]; then
	    echo "***** App directory contains no requnirements.txt file, continuing *****";
	else
	    echo "***** App directory contains a requirements.txt file, installing npm requirements *****";
	    cat /app/requirements.txt | xargs npm --prefer-offline install --save;
	fi;
}

function setup_ssh()
{
	if [ "$(ls -A /app/.ssh 2>/dev/null)" ]; then
	    echo "***** App .ssh directory exists and has content, continuing *****";
	else
	    echo "***** App .ssh directory is empty, initialising ssh key and configuring known_hosts for common git repositories (github/gitlab) *****"
	    rm -rf ~/.ssh/*
	    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
	    ssh-keyscan github.com > ~/.ssh/known_hosts 2>/dev/null
	    ssh-keyscan gitlab.com >> ~/.ssh/known_hosts 2>/dev/null
	    cp -r ~/.ssh /app;
	fi;
}

function setup_git_config()
{
	if [ -n "$GIT_EMAIL" ] && [ -n "$GIT_USER" ]; then
	    echo "***** Running git config, user = ${GIT_USER}, email = ${GIT_EMAIL} *****"
	    git config --global user.email ${GIT_EMAIL}
	    git config --global user.name ${GIT_USER}
	    echo "***** Copying .ssh from App directory and setting permissions *****"
	    cp -r /app/.ssh ~/
	    chmod 600 ~/.ssh/id_rsa
	    chmod 600 ~/.ssh/id_rsa.pub
	    chmod 700 ~/.ssh
	    echo "***** Contents of public ssh key (for deploy) - *****"
	    cat ~/.ssh/id_rsa.pub
	else 
	    echo "***** git user and git email is empty, continuing *****"  
	fi
}

function setup_port()
{
	if [ -z "$HEXO_SERVER_PORT" ];then
	  	echo "***** Set Default on Port ${HEXO_SERVER_PORT} *****"
	  	HEXO_SERVER_PORT=4000
    else
    	echo "***** Set the specified port ${HEXO_SERVER_PORT} *****"
	fi
}

function run_server()
{
	echo "***** Starting server on port ${HEXO_SERVER_PORT} *****"
	hexo server -d -p ${HEXO_SERVER_PORT}
}

function app_check_and_update()
{
	echo "***** Check Hexo Package Version *****"
	ncu
	if [ "$APP_CHECK_UPDATE" ]; then
		ncu -u
		echo "***** Update Hexo Package Version *****"
		npm install
	fi
}

setup_env
setup_requirements
app_check_and_update
setup_ssh
setup_git_config
setup_port
run_server || exit 1