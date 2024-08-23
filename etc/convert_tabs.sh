#! /bin/bash

FILE_EXTENSIONS=("v")

set -e

read -p "Convert to tabs or space (t/s) ? : " choice

if [ "$choice" == "t" ]; then
	for file in $(find . -type f -name "*.v"); do
		vim -c "source convert_tabs.vim" \
			-c "call ConvertToTabs()" \
		"$file"
	done
elif [ "$choice" == "s" ]; then
	for file in $(find . -type f -name "*.v"); do
		vim -c "source convert_tabs.vim" \
			-c "call ConvertToSpaces()" \
			"$file"
	done
else
	echo "Invalid input."
fi

echo '"convert_tabs.sh" finished successfully.'
