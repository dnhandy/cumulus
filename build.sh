#!/usr/bin/env bash

docker build -t cumulus_web -f dockerfile.web .;

docker build -t cumulus_api -f dockerfile.api .;

docker build -t cumulus_worker -f dockerfile.worker . ;
