#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
	echo "ОШИБКА: Необходимы root права"
	exit 1
fi

ALL_FILES=("check_test.sh" "checktest.service" "checktest.timer")
for file in "${ALL_FILES[@]}"; do
	if [ ! -f "$file" ]; then
		echo "ООШИБКА: Отсутствует файл $file"
		exit 1
	fi
done

cp check_test.sh /usr/local/bin/
chmod +x /usr/local/bin/check_test.sh

cp checktest.service /etc/systemd/system/
cp checktest.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable checktest.timer
systemctl start checktest.timer
