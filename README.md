# Cardano Automatic Native Asset (Token / NFT) Sales System - By Fred

Want to host your own automatic NFT sale on Cardano with native assets minted on demand?

The idea to release this into the public came with no attempt to clean up my code, I do not expect anyone to use this code as-is, the Classic ASP code requires special software and is not as widely used as php. This is meant as a learning tool in order to help you design your own system. It is possible to use this and run a sale, I have hosted multiple sales using this software.

Some caveats regarding this setup, special permissions are required on your web server if you attempt to use the asp pages, a change under basic authentiation might be needed from the specific user to pool, and you might need to change some permissions so the website can rename files. I provide a test.asp page you can use to confirm if you have the right permissions. You can reach me on Twitter at @fredrovicius and I will offer some support but I am hoping you just use this to make something on your own.

Steps to host an event:
1. Create a folder on your node ie: /home/user/sellvault01/
2a. Create a set of folders inside this folder to hold each wallet. (1 for each NFT to be sold)
2b. Use the following example to create 200 folders and associated wallet for each folder.
```
# Make folder structure for wallets for sales event.

for (( i=1; i<=9; i++ ))
do
mkdir 00$i
cd 00$i
cardano-cli address key-gen     --verification-key-file pay.vkey     --signing-key-file pay.skey
cardano-cli address build     --payment-verification-key-file pay.vkey     --out-file pay.addr     --mainnet
cd ..
done

for (( i=10; i<=99; i++ ))
do
mkdir 0$i
cd 0$i
cardano-cli address key-gen     --verification-key-file pay.vkey     --signing-key-file pay.skey
cardano-cli address build     --payment-verification-key-file pay.vkey     --out-file pay.addr     --mainnet
cd ..
done

for (( i=100; i<=200; i++ ))
do
mkdir $i
cd $i
cardano-cli address key-gen     --verification-key-file pay.vkey     --signing-key-file pay.skey
cardano-cli address build     --payment-verification-key-file pay.vkey     --out-file pay.addr     --mainnet
cd ..
done

```

3. Next you will need to make a file containing each of those payment addresses. I like to think of each numbered folder as a slot. Use the following code to grab all those addresses.
```

for (( i=1; i<=9; i++ ))
do
tm=$(cat 00$i/pay.addr)
echo $tm>>wallets.txt
done

for (( i=10; i<=99; i++ ))
do
tm=$(cat 0$i/pay.addr)
echo $tm>>wallets.txt
done

for (( i=100; i<=200; i++ ))
do
tm=$(cat $i/pay.addr)
echo $tm>>wallets.txt
done
```
4. Each directory needs a file named ticker.txt. This could easily be put into the work file that is sent by the website, just never got around to different use cases. This was created to fill a specific need at the time, after a few sales, more things were added and changed, a couple times over again.
I like to create spreadsheet of the metadata. I highlight all the cells for the ticker (row 1 - row 200 here) and paste them into a file named ticker.txt. Regardless of how you get this file created, line 1 = ticker #1, line 200 = ticker #200. Run this script to make a ticker.txt in each of the folders using this file you just created.
```
iii=1
input="./tickers.txt"
while IFS= read -r line
do
  if ((iii < 10)); then 
  echo $line>>00$iii/tickers.txt
  fi
  if ((iii < 100 && iii > 9)); then
  echo $line>>0$iii/tickers.txt
  fi
  if ((iii > 99)); then
  echo $line>>$iii/tickers.txt
  fi
  let "iii=iii+1";
done < "$input"
```
5. Create a template meta.txt file. Inside it have the policy already prepared ahead of time. Have any items that need to be unique for each NFT as a variable like #ipfs# for example. Make your metadata file be located in the root of your sellvault01 folder. So when you list the folder contents you see wallets.txt, meta,txt and all the numbered folders 001-200. Now issue this set of commands to start to build your metadata. In this code example we are replacing the string "#long#" with the "Long NFT Name (###/200)". The idea here is you would put the metadata together with the word #long# in the position where you wanted to insert the real thing.
```
for (( i=1; i<=9; i++ ))
do
sed "s;#long#;Long NFT Name ($i/200);g" meta.txt > 00${i}/tokenmeta.tmp1
done

for (( i=10; i<=99; i++ ))
do
sed "s;#long#;Long NFT Name ($i/200);g" meta.txt > 0${i}/tokenmeta.tmp1
done

for (( i=100; i<=200; i++ ))
do
sed "s;#long#;Long NFT Name ($i/200);g" meta.txt > ${i}/tokenmeta.tmp1
done
```
6. Using that same tickers.txt file from earlier, we will populate the metadata ahead of time with the ticker we plan to mint. Continuing just like in the previous step, we move on to the next variable that needs to be replaced. Once you get to the last variable, be sure the file extension ends with json. In each step so far we just increment the extension from .tmp1 to .tmp2, etc.
```
iii=1
input="./tickers.txt"
while IFS= read -r line
do
  if ((iii < 10)); then 
  sed "s/#ticker#/$line/g" 00$iii/tokenmeta.tmp1 > 00$iii/tokenmeta.tmp2
  rm 00$iii/tokenmeta.tmp1
  fi
  if ((iii < 100 && iii > 9)); then
  sed "s/#ticker#/$line/g" 0$iii/tokenmeta.tmp1 > 0$iii/tokenmeta.tmp2
  rm 0$iii/tokenmeta.tmp1
  fi
  if ((iii > 99)); then
  sed "s/#ticker#/$line/g" $iii/tokenmeta.tmp1 > $iii/tokenmeta.tmp2
  rm $iii/tokenmeta.tmp1
  fi
  let "iii=iii+1";
done < "$input"
```
7. In this example we finally make the final replacement and end up with that .json extension on our metadata file named tokenmeta.json.
```

iii=1
input="./ipfs.txt"
while IFS= read -r line
do
  if ((iii < 10)); then 
  sed "s/#ipfs#/$line/g" 00$iii/tokenmeta.tmp2 > 00$iii/tokenmeta.json
  rm 00$iii/tokenmeta.tmp2
  fi
  if ((iii < 100 && iii > 9)); then
  sed "s/#ipfs#/$line/g" 0$iii/tokenmeta.tmp2 > 0$iii/tokenmeta.json
  rm 0$iii/tokenmeta.tmp2
  fi
  if ((iii > 99)); then
  sed "s/#ipfs#/$line/g" $iii/tokenmeta.tmp2 > $iii/tokenmeta.json
  rm $iii/tokenmeta.tmp2
  fi
  let "iii=iii+1";
done < "$input"
```
8a. In my website examples I used a concept of .work and .busy files. I was trying to use an approach that did not rely on a database. I wanted the simplest approach I could think of with the least amount of moving pieces. KISS concept. A database was too many layers, too much overhead. I was under the impression these sales events were hard and that previously people needed multiple servers and it was common to see a sale event take down the server. You could easily adapt this to use your favorite database platform.
8b. Make a folder named www and copy the wallets.txt into this folder. cd into the new directory so it's the current directory and make the work files the website needs using this script.
```
######################################
### BUILD .work files for website. ###
######################################
iii=1
input="./wallets.txt"
while IFS= read -r line
do
  if ((iii < 10)); then 
  echo $line>00${iii}.work
  fi
  if ((iii < 100 && iii > 9)); then
  echo $line>0${iii}.work
  fi
  if ((iii > 99)); then
  echo $line>${iii}.work
  fi
  let "iii=iii+1";
done < "$input"
```
9. If you are using the provided web files, the following directory structure needs to be created ahead of time:
```
/_CurrentSale/
/ips/
/ready/
/ready/busy/
/sale2img/
```
Place the wallets file in the _CurrentSale folder like this: /_CurrentSale/Wallets.txt == Real important, do not use this name, .txt could allow someone to download your entire list of predefined wallet addresses. This is shown here as an example. You should not do this in production.


10. Read through each asp page and look for information like pricing that needs to be changed. I was a little sloppy in some areas as clients changed their mind about their plans often.
11. Copy the 2 bash scripts located in the scripts folder to your sellvaule01 folder. Edit the payout amounts and look over the file for any information that needs to be changed. The scripts are pretty basic.
12. To make a sale live and start checking for payments I open a terminal and run a loop like this:
```
for i in {1..10000000}; do   ./check4saleswork.sh;   sleep 10s; done
```


