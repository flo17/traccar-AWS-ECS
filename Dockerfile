# Use Traccar's official image
FROM traccar/traccar:latest

# Install AWS CLI and jq to interact with AWS Secrets Manager
RUN apk update && \
    apk add --no-cache aws-cli jq

# Copy the traccar.xml configuration file into the container
COPY traccar.xml /opt/traccar/conf/traccar.xml
COPY credential.csv /credential.csv

# Copy initialization script to recover database password
COPY init_traccar.sh /init_traccar.sh

# Set script execution permissions
RUN chmod +x /init_traccar.sh

# Replace entry point with initialization script
ENTRYPOINT ["/bin/sh", "/init_traccar.sh"]