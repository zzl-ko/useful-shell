#!/bin/bash

echo "This is a test script that is called when the package is executed"

echo "Father's EXTRACT_DIR is [$EXTRACT_DIR]"
echo -e "\n--------------------------------------"
cd $EXTRACT_DIR/myPackage
chmod +x smartbc
./smartbc "0xa-0o5+0b110*(5+1)"
#cd -
echo -e "--------------------------------------\n"

echo "Now you can custom your actions via the script makeSelfExtracting.sh"
