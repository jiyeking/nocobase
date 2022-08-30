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

version_info_line=$(npm view '@nocobase/server')
echo $version_info_line
echo $version_info_line |awk '{print $1}'
echo $version_info_line |awk '{print $1}' |awk -F '@' '{print $3}'
version=$(echo $version_info_line |awk '{print $1}' |awk -F '@' '{print $3}')
echo "version is $version"
package_info=$(cat packages/app/server/package.json)
echo "package_info is $package_info"
if [[ $package_info=~$version ]]
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
sleep 10
n=0
while [ $n -le 100 ] 
do
 # NocoBase server running at: http://localhost:13000/
  cat start.log
  start_flag_str=$(cat start.log)
  start_flag='NocoBase server running at'
  if [[ $start_flag_str=~$start_flag ]]
  then
    echo $start_flag_str
    break
  else
    echo "on starting...."
  fi 
  n=$n+1;
  sleep 10
done

# {"data":{"lang":"zh-CN"}}

lang_data=$(curl http://localhost:13000/api/app:getLang)
echo $lang_data
if [[ $lang_data == '{"data":{"lang":"zh-CN"}}' ]]
then
  echo "publish test success"
else
  echo "ERROR! publish test fail!"
  exit 1
fi

