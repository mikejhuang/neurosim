wait=on
echo "Waiting for qsub to start."
while [ $wait = on ]; do
eval `sed -n '1'p qsubwait.sh`
sleep 1
done






