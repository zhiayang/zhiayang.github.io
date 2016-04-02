#!/bin/bash

# handle packages file.

echo "" > Packages
dpkg-scanpackages -m debs > Packages


printf "Done: Packages\n"
bzip2 -kf Packages
printf "Done: Packages.bz2\n"



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







