#!/bin/sh -l

dependency_updates=$(mvn versions:display-property-updates versions:display-parent-updates -DgenerateBackupPoms=false \
    | grep '\->' \
    | awk -F ' ' '{if ($2 != $4) print $0}')
message=""
if [ -z "$dependency_updates" ];
then
  message="Congratulations, all your plugins have the latest releases! 🥳"
else
  countOutdated=$(echo "$dependency_updates" | wc -l)
  dependency_updates=$(echo "$dependency_updates" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')
  message="**You have $countOutdated dependencies and plugins with newer releases available:**\n$dependency_updates"
fi

curl \
  -X POST \
  "$1" \
  -H "Content-Type: application/json" \
  -H "Authorization: token $2" \
  -d \
  "
  {
        \"body\": \"$message\"
  }
  "
