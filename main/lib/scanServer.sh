#!/bin/tcsh

if [ $# -ne 4 ]; then
  echo "Invalid number of arguments"
  echo "Usage: scanServer.sh [cluster group] [# of clusters to use] [# of job threshold to exclude] [m-file name]"
  exit 1
fi

clusterGroup=$1
maxServer=$2
maxJob=$3
mfileName=$4

dir=`pwd`

userId=yoichi_m
exeCmd="/home/cns/matlab/r2011b/bin/matlab -nojvm -r $mfileName < /dev/null > /dev/null & echo \$! \`whoami\` \`hostname\` `date`"
exeCmd="matlab74nj -r $mfileName < /dev/null > /dev/null & echo \$! \`whoami\` \`hostname\` `date`"

minServer=1

serverList=`/home/cns/cluster/bin/loadall $clusterGroup | egrep -v 'Xeon|GHz|euler' | grep -v unavailable |  awk -v mxj=$maxJob '{if ($10 < mxj) print $8;}'`;

echo "--- available servers ---";
for sname in $serverList; do
    echo $sname
done
echo "-------------------------";

idx=1
for server in $serverList; do
    /home/cns/field/loadall $clusterGroup | grep $server

  if [ $idx -ge $minServer -a $idx -le $maxServer ]; then
    echo $idx $server 1>&2
    ssh -x -f ${userId}@${server/:/} "cd ${dir}; ${exeCmd}"
    sleep 1
  fi

  idx=`expr $idx + 1`;
done



