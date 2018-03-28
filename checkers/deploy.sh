#!/bin/bash


export PORT=5252
export MIX_ENV=prod
export GIT_PATH=/home/checkers/src/checkers 

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "checkers" ]; then
	echo "Error: must run as user 'checkers'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/checkers ]; then
	echo mv ~/www/checkers ~/old/$NOW
	mv ~/www/checkers ~/old/$NOW
fi

mkdir -p ~/www/checkers
REL_TAR=~/src/checkers/_build/prod/rel/checkers/releases/0.0.1/checkers.tar.gz
(cd ~/www/checkers && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/checkers/src/checkers/start.sh
CRONTAB

#. start.sh
