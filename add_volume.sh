#!/bin/bash

if [ "$1" == "" ]; then
  echo "Need a volumeId!"
  exit
fi

cp ../volumes/$1/deploy/$1.sqlite assets/$1.sqlite
mkdir zip
cp -r ../volumes/$1/deploy/$1 zip
zip -r $1.zip -r zip
mv $1.zip assets/$1.zip
rm -r zip
