#! /bin/bash

set -e

read -p "Convert to tabs or space (t/s) ? : " choice

cd ..

if [ "$choice" == "t" ]; then
	for file in $(find . -type f -name "*.sv"); do
		vim -c "source etc/convert_tabs.vim" \
			-c "call ConvertToTabs()" \
		"$file"
	done
elif [ "$choice" == "s" ]; then
	for file in $(find . -type f -name "*.sv"); do
		vim -c "source etc/convert_tabs.vim" \
			-c "call ConvertToSpaces()" \
			"$file"
	done
else
	echo "Invalid input."
fi

cd -

echo '"convert_tabs.sh" finished successfully.'
