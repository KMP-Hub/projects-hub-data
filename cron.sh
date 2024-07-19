#!/bin/bash

# The prefix of the docker container
TARGET_PREFIX="srv-captain--crawler"

# Get the container's full name by using the prefix
CONTAINER_NAME=$(sudo docker ps --format "{{.Names}}" | grep "^${TARGET_PREFIX}")

if [ -z "$CONTAINER_NAME" ]; then
    echo "No container starts with ${TARGET_PREFIX}"
    exit 1
fi

echo "Found: $CONTAINER_NAME"

# The json file in the container of projects-hub-server-crawler
CONTAINER_FILE_PATH="output/projects.json"

# The destination of projects-hub-data
HOST_DEST_PATH="/home/ubuntu/projects-hub-data/"

# Copy the file
sudo docker cp ${CONTAINER_NAME}:${CONTAINER_FILE_PATH} ${HOST_DEST_PATH}

echo "The file has been copied to ${HOST_DEST_PATH}"

# Go to the path of projects-hub-data
cd ${HOST_DEST_PATH=} || exit

# Check if there are any changes
if git diff --quiet; then
    echo "No changes to commit."
else
    # Add the changes
    git add .
    
    # Commit the changes with a timestamp
    git commit -m "Automatic commit at $(date +'%Y-%m-%d %H:%M:%S')"
    
    # Push to GitHub
    git push origin main
fi
