#!/bin/bash


function generate_manifest() {
cat << EOF > ./scdf-manifest.yml

applications:
- name: scdf-server
  path: ./scdf-server.jar
  memory: 1G
  host: dataflow-server-\${random-word}
  buildpack: java_buildpack
  services:
    - mysql
    - redis
EOF
if [ $LOG_SERVICE_NAME ]; then
    cat << EOF >> ./scdf-manifest.yml
    - $LOG_SERVICE_NAME
EOF
fi
cat << EOF >> ./scdf-manifest.yml
    - rabbit2
    - cloud-config-server
  env:
    EXTERNAL_SERVERS_REQUIRED: true
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_TASK_SERVICES: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_TASK_SERVICES
    MAVEN_REMOTE_REPOSITORIES_REPO1_URL: $MAVEN_REMOTE_REPOSITORIES_REPO1_URL
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_API_TIMEOUT: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_API_TIMEOUT
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_TASK_API_TIMEOUT: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_API_TIMEOUT
    TRUST_CERTS: $TRUST_CERTS
    SPRING_PROFILES_ACTIVE: $SPRING_PROFILES_ACTIVE
    SPRING_CLOUD_DATAFLOW_APPLICATIONPROPERTIES_STREAM_TRUST_CERTS: $TRUST_CERTS
    SPRING_CLOUD_DATAFLOW_APPLICATIONPROPERTIES_TASK_TRUST_CERTS: $TRUST_CERTS
    SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_ENABLE_RANDOM_APP_NAME_PREFIX: false
    SPRING_CLOUD_DATAFLOW_FEATURES_SKIPPER_ENABLED: $SPRING_CLOUD_DATAFLOW_FEATURES_SKIPPER_ENABLED

EOF

}

function push_application() {
  cf push -f scdf-manifest.yml
  rm -f scdf-manifest.yml
}

download $PWD
generate_manifest
push_application
run_scripts "$PWD" "config.sh"
