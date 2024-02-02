#!/bin/bash
##########################################################################################
##                                                                                      ##
##      This is a POC for Cppcheck XML conversion to NUnit using PHP and Handlebars     ##
##                                                                                      ##
##########################################################################################

# NOTES:
#
#       The route to the repo and results must be replaced by a variable or parameter.
#
apt -y install npm php php-xml && npm install -g handlebars
cd /sast/c-cpp-code #$WORKDIR
cppcheck --xml-version=2 --enable=all . --output-file=results/cppcheck-result.xml
php -r 'print(json_encode(simplexml_load_string(file_get_contents("results/cppcheck-result.xml"), "SimpleXMLElement", LIBXML_NOCDATA)));' > results/cppcheck-result.json
tr -d '@' < results/cppcheck-result.json > /tmp/cppcheck-result.json
echo <<EOF > /tmp/nunit-template.hbs
<test-run
   id="2"
   name="Cppcheck test"
   start-time="SCAN DATETIME">
           {{#each errors.error}}
           <test-case
                   id="{{attributes.id}}"
                   severity="{{attributes.severity}}"
                   msg="{{attributes.msg}}"
                   verbose="{{attributes.verbose}}"
                   cwe="{{attributes.cwe}}"
                   file0="{{attributes.file0}}"
                   result="Failed"
                   time="1">
                   <location file="{{location.attributes.file}}" line="{{location.attributes.line}}" column="{{location.attributes.column}}"/>
           </test-case>
           {{/each}}
</test-run>
EOF
handlebars /tmp/cppcheck-report.json < /tmp/nunit-template.hbs > results/nunit-cppcheck-report.xml
cat results/nunit-cppcheck-report.xml