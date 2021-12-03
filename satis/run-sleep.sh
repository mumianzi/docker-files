#!/usr/bin/env bash

while :
do
echo '开始生成'
if [ "$(cat /satis/bin/satis.lock)" != "" ]; then
  echo "其他程序正在生成...."
else
echo "1" > /satis/bin/satis.lock
php /satis/bin/satis build /build/satis.json /build/packages/ -v
echo '生成结束，一小时后重新生成'
echo "" > /satis/bin/satis.lock
fi
sleep 3600
done
