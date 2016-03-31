#!/bin/bash

# handle packages file.

echo "" > Packages

cd debs

for PACKAGE in $(ls *.desc)
do
	NAME=$(basename $PACKAGE .desc)
	echo "Package: $NAME"

	printf "" > "$NAME.pack"

	# the package file contains the description for all versions.
	for DEB in $(ls $NAME*.deb)
	do
		printf "    DEB File: $DEB\n"
		cat $PACKAGE >> "$NAME.pack"
		printf "\n" >> "$NAME.pack"

		VERSION=$(echo $DEB | cut -d _ -f 2)

		# this is quite gross
		# but we need to unpackage the deb, edit the control file to reflect the correct version,
		# and then re-deb it.

		mkdir -p $PACKAGE.folder/DEBIAN
		dpkg-deb --extract $DEB $PACKAGE.folder
		dpkg-deb --control $DEB $PACKAGE.folder/DEBIAN

		rm $DEB

		# edit the control file
		# gsed -i '0,/Version:/{//d}' $PACKAGE.folder/DEBIAN/control
		# rm $PACKAGE.folder/DEBIAN/control
		# mv $PACKAGE.folder/DEBIAN/control.tmp $PACKAGE.folder/DEBIAN/control

		dpkg-deb --build -Zlzma $PACKAGE.folder $DEB &> /dev/null
		rm -r $PACKAGE.folder


		# enter the details.
		printf "Version: %s\n" $VERSION >> "$NAME.pack"
		printf "Filename: ./debs/%s\n" $DEB >> "$NAME.pack"
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







