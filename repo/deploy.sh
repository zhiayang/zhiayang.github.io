#!/bin/bash

# handle packages file.

echo "" > Packages

cd debs

for PACKAGE in $(ls *.desc)
do
	NAME=$(basename $PACKAGE .desc)
	echo "Package: $NAME"

	echo "" > "$NAME.pack"

	# the package file contains the description for all versions.
	for DEB in $(ls $NAME*.deb)
	do
		printf "    DEB File: $DEB\n"
		cat $PACKAGE >> "$NAME.pack"
		printf "\n" >> "$NAME.pack"

		# Version: 1.0.0
		# Filename: debs/com.zhiayang.whatsappnotificationname_1.0.0-2+debug_iphoneos-arm.deb
		# Size: 4284
		# MD5sum: 391bb0d5fb366eee5be86a35692bc961
		# SHA1: 7dd9fcfa37f6acd025e30e938f54c95b16b80f52
		# SHA256: 7189adee2f1d888b48c7e2321b9bb48f348b4e91cab9313365a359203aa47b78

		# enter the version.
		printf "Version: %s\n" "$(echo $DEB | cut -d _ -f 2)" >> "$NAME.pack"
		printf "Filename: %s\n" $DEB >> "$NAME.pack"
		printf "Size: %s\n" "$(stat -f '%z' $DEB)" >> "$NAME.pack"
		printf "MD5sum: %s\n" "$(md5 -q $DEB)" >> "$NAME.pack"
		printf "SHA1: %s\n" "$(shasum -a 1 $DEB | awk '{print $1;}')" >> "$NAME.pack"
		printf "SHA256: %s\n" "$(shasum -a 256 $DEB | awk '{print $1;}')" >> "$NAME.pack"
		printf "\n\n" >> "$NAME.pack"
	done

	printf "\n"

done

cat $(find . -name '*.pack') > ../Packages


cd ..


printf "Done: Packages.bz2\n"
bzip2 -kf Packages



# handle release file.

echo "" > Release.sums

printf "MD5Sum:\n %s %s Packages\n %s %s Packages.bz2\n" "$(md5 -q Packages)" "$(stat -f '%z' Packages)" "$(md5 -q Packages.bz2)" "$(stat -f '%z' Packages.bz2)" >> Release.sums

printf "SHA1:\n %s %s Packages\n %s %s Packages.bz2\n" "$(shasum -a 1 Packages | awk '{print $1;}')" "$(stat -f '%z' Packages)" "$(shasum -a 1 Packages.bz2 | awk '{print $1;}')" "$(stat -f '%z' Packages.bz2)" >> Release.sums

printf "SHA256:\n %s %s Packages\n %s %s Packages.bz2\n" "$(shasum -a 256 Packages | awk '{print $1;}')" "$(stat -f '%z' Packages)" "$(shasum -a 256 Packages.bz2 | awk '{print $1;}')" "$(stat -f '%z' Packages.bz2)" >> Release.sums

cat Release.meta Release.sums > Release


printf "Done: Release\n\n"


git add ./*
git commit -m "repo update"
git push







