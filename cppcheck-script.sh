#!/bin/sh
# POC for Azure DevOps Pipeline to execute Cppcheck and convert its results to JUnit format.
apt -y update && apt -y upgrade && apt -y install cppcheck && apt -y install python3-venv
mkdir -p /sast/c-cpp-code && cp /backup/main.c /sast/c-cpp-code/main.c && echo $WORKDIR # DELETE LINE LATER
cd /sast/c-cpp-code #$WORKDIR
mkdir -p results
cppcheck --xml-version=2 --enable=all . --output-file=results/cppcheck-result.xml
cd results
echo -e "\nCppcheck XML results\n"
cat cppcheck-result.xml
python3 -m venv .venv && . .venv/bin/activate && python3 -m pip install --upgrade pip && python3 -m pip install cppcheck-junit
cppcheck_junit cppcheck-result.xml cppcheck-junit.xml
echo -e "\nCppcheck JUnit results\n"
cat cppcheck-junit.xml
deactivate
cd /sast
rm -rf /sast/c-cpp-code