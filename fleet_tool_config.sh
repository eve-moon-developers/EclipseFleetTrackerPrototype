#!/bin/bash

export PGUSER="fleettool";
export PGDATABASE="EclipseFleetTracker";
export PGPASSWORD="helloworld";
export PGPORT="5432";
export NODE_PATH=$NODE_PATH:./

export PORT="8000";

node ./server.js $@