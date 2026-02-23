#base image pulled from dockerhub that we are going to build on top of to add the dependencies that we need*/
#why alpine: lightweight version of Linux ideal for running docker containers- doesn't have unnecessary dependencies that you wouldn't need
FROM python:3.9-alpine3.13  
#specify who is going to be maintaining this docker image
LABEL maintainer="lakshitabopaiah"
#recommended when running python on a docker container- tells python not to buffer the o/p
#o/p from python will be directly printed to the console- prevents any delay
ENV PYTHONUNBUFFERED=1

#copy our local file of requirements.txt to /tmp/requirements.txt
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
#copy app directory containing the django app to /app container
COPY ./app /app
#Working directory-default directory from where all commands are gonna be run from when we run commands on our docker image
#setting it to the location where our django project will be synced to so when we run the commands we don't have to specify the full path of the django management command
WORKDIR /app
#expose port 8000 from our container to our machine when we run the container
#help connect to the django development server
EXPOSE 8000

#defines a build argument called dev and sets the default value to false
#we override this indise our docker compose file by specifying that ARGS DEV=true inside the yml file.
#when we use this docker file thorugh this docker-compose.yml configuration, it will update this dev here to true whereas if we use it in any other docker compose configuration it will leave this as false
#therefore by default we are not running in development mode
ARG DEV=false

#run command - install dependencies to our computer
#runs a comand on the alpine image that we are using when we're building our image
#multiple RUN command=creates new image layer -> avoid it by running single RUN command. This keeps it lightweight. You can break it down by using "&& \"
#create new virtual env which will be used to store our dependencies
RUN python -m venv /py && \
#install pip inside virtual env
    /py/bin/pip install --upgrade pip && \  
#install requirements inside docker image    
    /py/bin/pip install -r /tmp/requirements.txt && \
#Logic added for DEV - shell script
#if DEV=true then run below code- install the dev dependencies
#fi- is the shell syntax to close an if statement not a typo
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
#remove tmp coz we dont want any extra dependencies on out docker image once created(keep docker image lightweight)
    rm -rf /tmp && \
#calls add user command which adds a new user inside out image. done so the we dont use the root user since root user has full access and permissions to do everything on the server without any restrictions or limitations
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#updates the env variable inside the image
ENV PATH="/py/bin:$PATH"

#user we are switching to
USER django-user