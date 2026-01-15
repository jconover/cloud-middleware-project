# Gemini Project: DevOps Cloud Middleware Portfolio

This document provides a comprehensive overview of the DevOps Cloud Middleware Portfolio project, intended to be used as a quick-start guide and for instructional context.

## Project Overview

This project showcases a complete, end-to-end CI/CD and Infrastructure-as-Code (IaC) pipeline. It deploys a Java Jakarta EE application on an IBM Liberty server running on AWS. The infrastructure is provisioned using Terraform, servers are configured with Ansible, the pipeline is orchestrated by Jenkins, and the entire stack is monitored using Prometheus and Grafana.

### Key Technologies

*   **Cloud Provider**: AWS
*   **Infrastructure as Code**: Terraform (modularized for `dev` and `prod` environments)
*   **Configuration Management**: Ansible (with AWX for orchestration on EKS)
*   **CI/CD**: Jenkins (declarative pipelines)
*   **Application Stack**: Java 17, Jakarta EE 10, IBM Open Liberty
*   **Monitoring**: Prometheus, Grafana, Node Exporter, and MicroProfile Metrics

### Architecture

The architecture consists of:
*   A custom VPC with public and private subnets.
*   An EKS cluster in the private subnet for running AWX.
*   An EC2 instance in a private subnet hosting the IBM Liberty application.
*   An Application Load Balancer in the public subnet to expose the Liberty application.
*   EC2 instances in the public subnet for Jenkins and the Monitoring stack (Prometheus/Grafana).
*   Security Groups to control traffic between the components.

## Building and Running

The project is designed to be deployed and managed through a combination of Terraform, Ansible, and Jenkins.

### 1. Infrastructure Deployment (Terraform)

The infrastructure is defined in the `terraform/` directory, with separate environments for `dev` and `prod`.

**To deploy the `dev` environment:**
1.  Navigate to the `dev` environment directory:
    ```bash
    cd terraform/environments/dev
    ```
2.  Create a `terraform.tfvars` file from the example:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
3.  **Important:** Edit `terraform.tfvars` to provide your specific values (e.g., `ami_id`, `key_name`).
4.  Initialize and apply Terraform:
    ```bash
    terraform init
    terraform apply
    ```

### 2. Server Configuration (Ansible)

Once the infrastructure is provisioned, use Ansible to configure the EC2 instances. The main playbook is `ansible/playbooks/site.yml`.

**To run the configuration:**
1.  Update the Ansible inventory (e.g., `ansible/inventory/`) to point to the public IPs of the newly created EC2 instances. For dynamic discovery, an AWS dynamic inventory plugin can be used.
2.  Execute the main playbook:
    ```bash
    cd ansible
    ansible-playbook -i inventory/ playbooks/site.yml
    ```

### 3. Application CI/CD (Jenkins)

The CI/CD pipeline for the Java application is defined in `jenkins/pipelines/application/Jenkinsfile`.

**Pipeline Stages:**
1.  **Checkout**: Checks out the source code from the Git repository.
2.  **Build**: Compiles the Java code and packages it into a `.war` file using Maven.
3.  **Archive Artifacts**: Stores the built `.war` file for deployment.
4.  **Deploy to Dev**: Runs an Ansible playbook to deploy the application artifact to the Liberty server.

**To run the pipeline:**
1.  Access your Jenkins instance.
2.  Create a new Pipeline job.
3.  Configure the pipeline to use the `jenkins/pipelines/application/Jenkinsfile` script from SCM.
4.  Trigger a build.

## Development Conventions

*   **Infrastructure**: Terraform code is modular, with shared modules in `terraform/modules/` and environment-specific configurations in `terraform/environments/`.
*   **Configuration**: Ansible roles are used to separate concerns for different server types (`common`, `jenkins`, `liberty`, `monitoring`).
*   **Application**: The Java application follows standard Maven project structure.
*   **CI/CD**: Jenkins pipelines are defined as code (`Jenkinsfile`) and stored in the repository.
