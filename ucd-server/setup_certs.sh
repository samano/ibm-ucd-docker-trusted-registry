#!/usr/bin/env bash
# Export the server cert then import any agent certs that are found
set -e
[[ ${DEBUG_STARTUP,,} = true ]] && set -x

if ! grep -q server.jms.mutualAuth=true conf/server/installed.properties; then
    echo "server.jms.mutualAuth must be set to true during install"
    cat conf/server/installed.properties
    exit 1
fi

keystore=conf/server.keystore
echo keytool -export -keystore $keystore -storepass changeit -alias server \
    -file conf/server.crt
keytool -export -keystore $keystore -storepass changeit -alias server \
    -file conf/server.crt
cp conf/server.crt /ucddata/conf

echo "Waiting for agent certificate"
for i in $(seq 1 20); do
    sleep 1
    crts=$(ls -1 /ucddata/conf/*.crt | grep -v '/server.crt' || true)
    if [[ $crts ]]; then
        for crt in $crts; do
            agent=$(basename $crt .crt)
            echo "Found $agent.crt"
            echo keytool -importcert -keystore $keystore -storepass changeit \
                -alias $agent -file $crt -keypass changeit -noprompt
            status=$(keytool -importcert -keystore $keystore -storepass changeit \
                -alias $agent -file $crt -keypass changeit -noprompt || echo "status=$?")
            if [[ $status != *status=* ]]; then
                echo $status
            elif [[ $status != *'Certificate not imported, alias '*' already exists'* ]]; then
                # This error is OK, others are fatal
                echo $status
                exit 1
            fi
        done
        break
    fi
done
