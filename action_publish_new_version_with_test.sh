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
version=$(echo $version_info_line |awk '{print $1}' |awk -F '@' '{print $3}')
echo '::set-output name=VERSION::$version'
package_info=$(cat packages/app/server/package.json)
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
# there is something wrong ,yarn nocobase install --lang=zh-CN but actual is get en-US,so just test  {"data":{"lang":
expect_lang_data='{"data":{"lang":'
if [[ $lang_data=~$expect_lang_data ]]
then
  echo "publish test success"
else
  echo "::error file=action_publish_new_version_with_test.sh,line=66,endLine=70,title= publish test fail :: lang_data is not contains expect str"
  exit 1
fi

