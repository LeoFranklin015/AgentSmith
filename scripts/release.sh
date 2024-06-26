#!/bin/bash

# This script is used to release new versions of the project.

### NOTE ###
# Specify the versions of the Docker and Lilypad modules in VERSIONS.env

# Change to this script's location so we can find the VERSIONS.env file
cd "$(dirname "$0")"

# Load the versions
source VERSIONS.env

# Change to the root directory of the repository.
cd ".."

# Check that jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq before releasing."
    exit 1
fi

# Check that Git is in a clean state
if [[ -n $(git status -s) ]]; then
    echo "Git is not in a clean state. Please commit or stash your changes before releasing."
    exit 1
fi

# Check that the versions are set
if [[ -z $LILYPAD_$VLLAMA3_8B ]]; then
    echo "Please set the versions in VERSIONS.env before releasing."
    exit 1
fi

# Check that the Docker versions are set
if [[ -z $VLLAMA3_8B ]]; then
    echo "Please set the Docker versions in VERSIONS.env before releasing."
    exit 1
fi

# For each module, we'll switch to that module's branch, update lilypad_module.json.tmpl with the new Docker version, commit the change, and push it to the repository.
# We'll then tag the commit with the new Lilypad version and push the tag to the repository.
git checkout llama3-8b && git pull
VALUE="zorlin/ollama:llama3-8b-lilypad$VLLAMA3_8B"
echo $VALUE
sed -i 's|^\(\s*\)"Image": .*|\1"Image": "'$VALUE'",|' lilypad_module.json.tmpl
git add lilypad_module.json.tmpl
git commit -m "Update container version to llama3-8b-lilypad$VLLAMA3_8B"
git tag llama3-8b-lilypad$LILYPAD_VLLAMA3_8B

# Switch back to main
git checkout main

# Inform the user they should update README.md after testing the new modules
echo "Please test the new modules and update README.md with the new versions when you're done."
echo
echo "The easiest way to test them is... with Lilypad! Here's some commands to inspire you:"
echo "lilypad run ollama-pipeline:llama3-8b-lilypad$LILYPAD_VLLAMA3_8B -i Prompt='Something awesome this way comes'"
echo
echo "Don't forget to update the README.md with the new versions!"
