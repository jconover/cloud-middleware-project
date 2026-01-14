# DevOps Cloud Middleware Portfolio Project

A comprehensive DevOps showcase demonstrating an end-to-end CI/CD and Infrastructure-as-Code pipeline.
This project hosts a Java Jakarta EE application on **IBM Liberty**, running on **AWS**, provisioned by **Terraform**, configured by **Ansible**, orchestrated by **Jenkins**, and monitored by **Prometheus/Grafana**.

## Tech Stack
-   **Cloud Provider**: AWS
-   **IaC**: Terraform (Modular with Dev/Prod environments)
-   **Configuration**: Ansible & AWX (deployed on EKS)
-   **CI/CD**: Jenkins (Declarative Pipelines)
-   **Application**: Java 17 / Jakarta EE 10 / IBM Open Liberty
-   **Observability**: Prometheus, Grafana, Node Exporter, MicroProfile Metrics

## Prerequisites
-   AWS CLI configured (`aws configure`)
-   Terraform installed
-   Ansible installed
-   `kubectl` and `helm` installed (for AWX/EKS)

## 1. Infrastructure Deployment (Terraform)
Navigate to the desired environment (e.g., `dev`) and apply the infrastructure.

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

**Outputs to note:**
-   `eks_cluster_endpoint`: URL for the EKS cluster.
-   `liberty_app_url`: URL for the Load Balancer (will return 503 until app is deployed).
-   `monitoring_server_ip`: Public IP of the Monitoring Server.

## 2. Configuration Management (Ansible)
Once infrastructure is up, configure the instances.

**Update Inventory:**
Ensure your inventory points to the new EC2 Public IPs (or use an AWS dynamic inventory plugin).

**Run Site Playbook:**
Configures Jenkins, Liberty, and Monitoring servers.
```bash
cd ansible
ansible-playbook -i inventory/ hosts playbooks/site.yml
```

**Deploy AWX:**
Deploys AWX Operator to the EKS cluster.
```bash
ansible-playbook playbooks/setup_awx.yml
```

## 3. Jenkins Setup
Access Jenkins at `http://<JENKINS_IP>:8080`.
1.  Unlock Jenkins using the initial admin password (`/var/lib/jenkins/secrets/initialAdminPassword`).
2.  Install suggested plugins.
3.  Create two Pipelines pointing to this git repo:
    -   **Infrastructure**: Script Path `jenkins/pipelines/infrastructure/Jenkinsfile`
    -   **Application**: Script Path `jenkins/pipelines/application/Jenkinsfile`

## 4. Application Deployment
Run the **Application** pipeline in Jenkins.
-   It will build the `liberty-demo.war` using Maven.
-   It will deploy it to the Liberty server via Ansible.

**Verify:**
Access the application at `http://<ALB_DNS_NAME>/api/hello`.

## 5. Observability
The monitoring stack (Prometheus & Grafana) is deployed to a dedicated EC2 instance via Ansible.

**Access:**
-   **Prometheus**: `http://<MONITORING_SERVER_IP>:9090`
-   **Grafana**: `http://<MONITORING_SERVER_IP>:3000` (default creds: admin/admin)

**Dashboards:**
Create a new Dashboard in Grafana and import metrics from Prometheus.
-   `up`: Check if targets are online.
-   `base_cpu_system_load_average`: Check Liberty server load (via MicroProfile metrics).
