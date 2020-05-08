#!/bin/bash

# Argument 1 should be the Reverse Proxy API token
# Argument 2 should be the starting directory
# Argument 3 should be the tmpfile path
# Argument 4 should be the time allotment

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --wait 0

API_TOKEN=$1
TMPFILE=$2

echo "Temp file: $TMPFILE"

# Get the comet node's IP
IP="$(hostname -s).local"
jupyter lab --ip $IP --config "$TMPFILE".py | tee $TMPFILE &

# Waits for the notebook to start and gets the port
PORT=""
while [ -z "$PORT" ]
do
    PORT=$(grep '1\.' $TMPFILE)
    PORT=${PORT#*".local:"}
    PORT=${PORT:0:4}
done

echo $PORT | tee -a $TMPFILE

# redeem the API_TOKEN given the untaken port
url='"https://manage.comet-user-content.sdsc.edu/redeemtoken.cgi?token=$API_TOKEN&port=$PORT"'

# Redeem the API_TOKEN
eval curl $url | tee -a $TMPFILE

# waits for all child processes to complete, which means it waits for the jupyter notebook to be terminated
wait
