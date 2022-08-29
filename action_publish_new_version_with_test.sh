#!/bin/bash

# npm whoami --registry http://verdaccio:4873
# if auto version - auto version and git add version commit info
yarn version:alpha -y
git config user.email "test@mail.com"
git config user.name "test"
git add .
git commit -m "chore(versions): publish packages xxx"

# publish test npm registry
yarn release:force --registry http://verdaccio:4873
npm config set registry http://verdaccio:4873

version=$(echo ${$(npm view @nocobase/server | grep '@nocobase/server@'):0:1} | awk -F '@' '{print $3}')
result = $(cat packages/app/server/package.json | grep $version)
if [[ $result != "" ]]
then
  echo "publish test npm registry success"
else
  echo "ERROR! publish test npm registry version different with package.json version!"
  exit 1
fi

# test published package
cd ../
yarn config set registry http://verdaccio:4873
yarn create nocobase-app my-nocobase-app -d sqlite
cd my-nocobase-app
yarn install
yarn nocobase install --lang=zh-CN
yarn start > start.log &
n=0;
while($n<=100) do
 # NocoBase server running at: http://localhost:13000/
  start_flag_str = $(cat start.log | grep "NocoBase server running at: http://localhost:13000/")
  if [[ $start_flag_str != "" ]]
  then
    echo $start_flag_str
    break
  else
    echo "ERROR! start NocoBase server fail!"
    exit 1
  fi 
  n=$n+1;
  sleep 10;
done
# {"data":{"lang":"zh-CN"}}
lang_data = $(curl http://localhost:13000/api/app:getLang)
echo $lang_data
if [[ $lang_data == '{"data":{"lang":"zh-CN"}}' ]]
then
  echo "publish test success"
else
  echo "ERROR! publish test fail!"
  exit 1
fi

