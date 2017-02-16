#!/bin/bash

export PGUSER="fleettool";
export PGDATABASE="EclipseFleetTracker";
export PGPASSWORD="HelloWorld";
export PGPORT="5432";
export NODE_PATH=$NODE_PATH:./

export PORT="8000";

export DEBUG_AUTH="FALSE"

node ./server.js $@