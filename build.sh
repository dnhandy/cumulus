#!/usr/bin/env bash

docker build -t dnhandy/cumulus_web -f dockerfile.web .;

docker build -t dnhandy/cumulus_api -f dockerfile.api .;

docker build -t dnhandy/cumulus_worker -f dockerfile.worker . ;
