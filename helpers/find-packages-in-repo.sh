#!/bin/bash -x

#
# A script to grep over RPM repos to find if they contains packages enumerated in a text file.
# If any match from 'package-list.txt' is found in any of the repos, echos "yes" to stdout.
# Otherwise prints nothing, which is treated as "false" by makefile.
#
# The script can handle URLs passed as multiple arguments, i.e.:
#
#  ./find-packages-in-repo.sh package-list.txt https://first-url https://second-url
#
# and URLs passed in a single argument as a newline/space-separated string:
#
#  ./find-packages-in-repo.sh package-list.txt "https://first-url https://second-url"
#
#  ./find-packages-in-repo.sh package-list.txt "https://first-url
#  https://second-url"
#

if [ $# -lt 2 ]; then
    echo "Usage: find-packages-in-repo.sh package-list.txt https://first-url https://second-url ..."
    exit 1
fi

PKG_LIST_FILE="$1"
PKG_LIST=$(cat ${PKG_LIST_FILE} | head -c -1 | tr '\n' '|')

shift

while [ $# -gt 0 ]; do
	while read -r repos; do
		for repo in ${repos}; do
			curl -s "${repo}" | egrep -q "${PKG_LIST}"
			if [ $? -eq 0 ]; then
				echo yes
				exit 0
			fi
		done
	done <<< "$1"
    shift
done
