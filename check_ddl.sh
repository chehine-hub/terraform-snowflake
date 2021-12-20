#!/bin/bash

# Check for errors in file name
for file in $(find "./Source/snowflake_scripts" -name *.sql); do

if ! [[ ${file} =~ [.]/Source/snowflake_scripts/[0-9A-Za-z_/]*[A-Z][0-9]+[.0-9]*__[0-9a-zA-Z_]+[.]sql ]]; then
     echo ERROR: La nomenclature du DDL ${file} est incorrecte !
     exit 1
     else echo "La nomenclature du DDL ${file} est correcte "
fi
done

# Check for dev/accp/prod mention
for file in $(find "./Source/snowflake_scripts" -name *.sql); do

if grep -iE '_dev |_prod |_accp |_dev_|_accp_|_prod_' ${file}; then
     echo ERROR: le DDL ${file} est NON conforme, il pointe vers un environnement !
     exit 1
     else echo "le DDL ${file} est conforme car il ne pointe pas vers un environnement (DEV-ACCP-PROD)"
fi
done

# Check for #env# mention
for file in $(find "./Source/snowflake_scripts" -name *.sql); do

if grep -Fq "#env#" ${file}; then
        echo "le DDL ${file} est conforme car il contient le suffixe #env#"
        sed -i -e "s/#env#/${env}/g" ${file}
else echo ERROR: le DDL ${file} est NON conforme car il ne contient pas le suffixe '#env#' !
exit 1
fi
done