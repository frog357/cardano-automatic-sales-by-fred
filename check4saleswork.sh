#!/bin/bash
vault=sellvault01
wget "https://subdomain.metromermaids.com/ready/getwork.asp" -O ${HOME}/${vault}/work.tmp -a ${HOME}/${vault}/wget.log

# work looks like this: SLOT#.payoutaddress

webwork=$(cat ${HOME}/${vault}/work.tmp)
if [ "${webwork}" != "" ]; then

sdinput="${HOME}/${vault}/work.tmp"
  while IFS= read -r line
  do
    webworkparts=(${line//./ }) # https://stackoverflow.com/questions/918886/how-do-i-split-a-string-on-a-delimiter-in-bash
    itemSlot=${webworkparts[0]}
    payoutaddr=${webworkparts[1]}

    cd ${HOME}/${vault}/
    cp ${HOME}/${vault}/mint4saleEvent.sh ${HOME}/${vault}/${itemSlot}
    ${HOME}/${vault}/${itemSlot}/mint4saleEvent.sh ${itemSlot} ${payoutaddr}
  done < "$sdinput"
fi
