#!/bin/bash
itemSlot=${1}
payoutAddr=${2}
mintAmount=1
itemPrice=12000000
minUTXOlovelace=2000000
partnerWallet=addr1q87jlc0kuaueat5s9qapsxvde9085k99des3cfhe58aky6ju0uq0lhqzhl0ytw9gh5kzl9udpskwjws9wrysj3a04njs25v25r
partnerWallet2=addr1q87jlc0kuaueat5s9qapsxvde9085k99des3cfhe58aky6ju0uq0lhqzhl0ytw9gh5kzl9udpskwjws9wrysj3a04njs25v25r
profitWallet=addr1q87jlc0kuaueat5s9qapsxvde9085k99des3cfhe58aky6ju0uq0lhqzhl0ytw9gh5kzl9udpskwjws9wrysj3a04njs25v25r
vault=sellvault01
tokenName=$(cat ${HOME}/${vault}/${itemSlot}/ticker.txt)
webName=https://subdomain.metromermaids.com

# if we have metadata file still, we can proceed, else we need to notify the website this worker is done.
if [[ -f ${HOME}/${vault}/${itemSlot}/tokenmeta.json ]]; then

  echo "Checking $itemSlot, payout=${payoutAddr}"
  get_UTXO() {
    while IFS= read -r line; do
      IFS=' ' read -ra utxo_entry <<< "${line}"
      local utxoHashIndex="${utxo_entry[0]}#${utxo_entry[1]}"
    done < <(printf "${1}\n" | tail -n +3)
    echo "${utxoHashIndex}"
  }
  get_Lovelace() {
    while IFS= read -r line; do
      IFS=' ' read -ra utxo_entry <<< "${line}"
      local lamountLovelace="${utxo_entry[2]}"
    done < <(printf "${1}\n" | tail -n +3)
    echo "${lamountLovelace}"
  }

  checkAddr=$(cat ${HOME}/${vault}/${itemSlot}/pay.addr)
  makeutxo=$(cardano-cli query utxo --address ${checkAddr} --mainnet --mary-era)
  utxoOUT=$(get_UTXO "${makeutxo}")
  amountLovelace=$(get_Lovelace "${makeutxo}")

  if [ "${amountLovelace}" != "" ]; then
    if ((${amountLovelace} >= ${itemPrice})); then
      cardano-cli  query protocol-parameters --mainnet --out-file ${HOME}/${vault}/${itemSlot}/protocol.json --mary-era
      currentTip=$(cardano-cli query tip --mainnet | jq -r .slotNo);
      validBefore=$(( ${currentTip} + 1200 ))
      newpolicy=$(cardano-cli transaction policyid --script-file ${HOME}/${vault}/policy/policy.script)
      cardano-cli transaction build-raw --mary-era --fee 0 \
        --tx-in ${utxoOUT} \
        --invalid-hereafter ${validBefore} \
        --tx-out ${payoutAddr}+${minUTXOlovelace}+"1 ${newpolicy}.${tokenName}" \
        --tx-out ${profitWallet}+1000000 \
        --tx-out ${partnerWallet}+1000000 \
        --tx-out ${partnerWallet2}+1000000 \
        --metadata-json-file="${HOME}/${vault}/${itemSlot}/tokenmeta.json" \
        --mint="1 ${newpolicy}.${tokenName}" \
        --out-file ${HOME}/${vault}/${itemSlot}/tx.raw

      getMinFee=$(cardano-cli transaction calculate-min-fee \
        --tx-body-file ${HOME}/${vault}/${itemSlot}/tx.raw \
        --tx-in-count 1 --tx-out-count 4 --witness-count 2 \
        --mainnet --protocol-params-file ${HOME}/${vault}/${itemSlot}/protocol.json)

      minFeeParts=(${getMinFee})
      minFee=${minFeeParts[0]}

      # split the funds based on the price
      # if ((itemPrice>=102000000)); then
      # this is how I normally do it, but this is a 4-way split.
      OUTiGet="2500000"
      OUTtheyGet="7500000"
      # fi

      # This should be 0 but just in case..
      # if some how they send more ADA than they should.
      lovelaceChange=$((amountLovelace-OUTiGet-OUTtheyGet-minFee))

      #echo "BUYER REFUND AMOUNT: $lovelaceChange "
      #echo "--They get: $OUTtheyGet "
      #echo "--I get: $OUTiGet "

      cardano-cli transaction build-raw --mary-era --fee ${minFee} \
        --tx-in ${utxoOUT} \
        --invalid-hereafter ${validBefore} \
        --tx-out ${payoutAddr}+${lovelaceChange}+"1 ${newpolicy}.${tokenName}" \
        --tx-out ${profitWallet}+2500000 \
        --tx-out ${partnerWallet}+2500000 \
        --tx-out ${partnerWallet2}+5000000 \
        --metadata-json-file="${HOME}/${vault}/${itemSlot}/tokenmeta.json" \
        --mint="1 ${newpolicy}.${tokenName}" \
        --out-file ${HOME}/${vault}/${itemSlot}/tx.raw

      cardano-cli transaction sign --signing-key-file ${HOME}/${vault}/${itemSlot}/pay.skey \
        --signing-key-file ${HOME}/${vault}/policy/policy.skey \
        --script-file ${HOME}/${vault}/policy/policy.script --mainnet \
        --tx-body-file ${HOME}/${vault}/${itemSlot}/tx.raw \
        --out-file ${HOME}/${vault}/${itemSlot}/tx.signed

      cardano-cli transaction submit --tx-file  ${HOME}/${vault}/${itemSlot}/tx.signed --mainnet
      mv ${HOME}/${vault}/${itemSlot}/tokenmeta.json ${HOME}/${vault}/${itemSlot}/tokenmeta.sold
      echo "${itemSlot} sold!"
      wget "${webName}/ready/setwork.asp?i=${itemSlot}" -O ${HOME}/${vault}/${itemSlot}/sentdone.tmp -a ${HOME}/${vault}/${itemSlot}/wget.log
    fi
  fi
else # this job was missing the metadata file, signs it was already finished.
  #notify that this .busy file should now become a .sold file.
  wget "${webName}/ready/setwork.asp?i=${itemSlot}" -O ${HOME}/${vault}/${itemSlot}/sentdone.tmp -a ${HOME}/${vault}/${itemSlot}/wget.log
fi
