
# Traccar on AWS ECS with RDS and Secrets Manager Integration

This project deploys a [Traccar docker container](https://github.com/traccar/traccar-docker) on AWS ECS, connecting securely to a MySQL database hosted on AWS RDS. The database password is managed by AWS Secrets Manager and retrieved dynamically at container startup for a secure and streamlined setup.

## Contents

- **Dockerfile**: Defines the Docker image based on the official Traccar image, adding tools for securely retrieving database credentials from AWS Secrets Manager.
- **init_traccar.sh**: A startup script that fetches the database password from AWS Secrets Manager, updates `traccar.xml` with the retrieved password, and starts the Traccar server.
- **traccar.xml**: A modified Traccar configuration file with placeholders for database credentials. The `[PASSWORD]` placeholder is dynamically replaced by `init_traccar.sh` at runtime.  
  > For a sample configuration, refer to the official [Traccar MySQL template](https://www.traccar.org/mysql/).

## Prerequisites

- **AWS RDS Instance**: A MySQL instance configured for Traccar, with a dedicated database. Create the database for Traccar by running:
  ```sql
  CREATE DATABASE [dbname];
  ```
  
- **AWS Secrets Manager**: Stores the database password securely. Generate a new secret from your RDS settings or store the password manually.  
  ![Database Configuration Example](docs/rds_config.png)

- **AWS IAM Credentials (credential.csv)**: Required to grant the ECS task access to AWS Secrets Manager and RDS.  
  Generate these credentials:
    1. Go to AWS IAM → Users → Security Credentials → Create Access Key.  
    ![IAM Access Key](docs/iam_access_key.png)
    2. Save the access key as a `credential.csv` file.
  
   > **Note**: Edit the CSV header to include "User Name" for compatibility, though the user name value is not essential:
   ```
   User Name,Access key ID,Secret access key
   username,AKIAIOSFODNN7EXAMPLE,wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

## Usage

1. **Create a Docker Image and Push to ECR**:
    - In Amazon ECR, create a new private repository.
    - Follow the provided push commands to publish your Docker image to ECR.

2. **Deploy to Amazon ECS**:
    - In Amazon ECS, create a new task definition using the image in your ECR repository.
    - Configure the task to retrieve the database password from AWS Secrets Manager, ensuring appropriate IAM permissions are set.

3. **Set Up a Network Load Balancer (Optional)**:
    - If needed, create an NLB to allow secure, public access to the Traccar instance.
    - Configure port forwarding:
        - `TLS:443` → `TCP 8082` (for secure access to the Traccar web interface)
        - Device-specific ports as required; see [Traccar Device List](https://www.traccar.org/devices/).

4. **Adjust Security Groups**:
    - Ensure that security groups for the ECS task, RDS instance, and load balancer (if applicable) are configured to allow traffic over the necessary ports.  

