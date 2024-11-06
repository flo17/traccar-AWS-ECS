#!/bin/bash

# Generate credential.csv from IAM --> Users --> Security credentials
# Edit header to add "User Name", value is not important
# User Name,Access key ID,Secret access key
# User requires permissions for SecretsManager (could be tested with SecretsManagerReadWrite policy)
aws configure import --csv file:///credential.csv
aws configure set region europe-central-2

# Replace SECRET_NAME with the name of your secret in AWS Secrets Manager
SECRET_NAME="[SECRET_NAME]"

# Recover password from AWS Secrets Manager
PASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text| jq -r .password)

if [ -z "$PASSWORD" ]; then
  echo "Erreur : impossible de récupérer le mot de passe depuis AWS Secrets Manager."
  exit 1
fi
echo "Password ok"
# Replace [PASSWORD] in the traccar.xml configuration file with the recovered password
sed -i "s~\[PASSWORD\]~$PASSWORD~g" /opt/traccar/conf/traccar.xml

# Launch Traccar using the original command
exec java -Xms1g -Xmx1g -Djava.net.preferIPv4Stack=true -jar tracker-server.jar /opt/traccar/conf/traccar.xml
