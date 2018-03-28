#!/bin/bash

export PORT=5252

cd ~/www/checkers
./bin/checkers stop || true
./bin/checkers start
