# AWX Usage Guide

This guide describes how to access and configure AWX (Ansible Tower open source) running on EKS to manage your Liberty servers.

## 1. Accessing AWX

### Retrieve Admin Password
AWX is deployed via the AWX Operator on EKS. The default admin password is stored in a Kubernetes secret.

Run the following command (ensure you have `kubectl` configured):

```bash
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode
```

### Login
1.  Obtain the LoadBalancer URL or External IP of the AWX service:
    ```bash
    kubectl get svc -n awx
    ```
2.  Open the URL in your browser.
3.  **Username**: `admin`
4.  **Password**: (The password retrieved in the previous step)

## 2. Setting Up Credentials

To allow AWX to connect to your EC2 instances, you need to add your SSH private key.

1.  Navigate to **Resources -> Credentials**.
2.  Click **Add**.
3.  **Name**: `Dev-SSH-Key` (or similar).
4.  **Organization**: `Default`.
5.  **Credential Type**: `Machine`.
6.  **Inputs**:
    *   **Username**: `ubuntu` (Assuming Ubuntu AMI, check your `terraform.tfvars`).
    *   **SSH Private Key**: Paste the contents of your `.pem` key file (e.g., `~/.ssh/my-key.pem`).
7.  Click **Save**.

## 3. Creating a Project

The Project tells AWX where to find your Ansible playbooks (this Git repository).

1.  Navigate to **Resources -> Projects**.
2.  Click **Add**.
3.  **Name**: `CloudMiddlewareRepo`.
4.  **Organization**: `Default`.
5.  **Source Control Credential Type**: `Git`.
6.  **Source Control URL**: Enter the URL of your Git repository (e.g., `https://github.com/your-user/cloud-middleware-project.git`).
    *   _Note: If using a private repo, you will need to set up Source Control Credentials first._
7.  Click **Save**.
8.  Wait for the "Sync" to complete (Status indicator will turn green).

## 4. Creating an Inventory

The Inventory defines the hosts (servers) that Ansible will manage. For a quick test, we will create a manual inventory.

1.  Navigate to **Resources -> Inventories**.
2.  Click **Add** -> **Add Inventory**.
3.  **Name**: `Dev-Environment`.
4.  **Organization**: `Default`.
5.  Click **Save**.
6.  Click on the **Hosts** tab (configured inside the Inventory you just created).
7.  Click **Add**.
8.  **Name**: Enter the Public IP or DNS name of your Liberty Server (found in Terraform outputs).
9.  Click **Save**.

## 5. Creating a Job Template

A Job Template combines a Project (playbooks), an Inventory (hosts), and Credentials (auth) to run a specific task. We will specificially use the `test_liberty.yml` playbook for verification.

1.  Navigate to **Resources -> Templates**.
2.  Click **Add** -> **Add Job Template**.
3.  **Name**: `Test Liberty Connectivity`.
4.  **Job Type**: `Run`.
5.  **Inventory**: `Dev-Environment`.
6.  **Project**: `CloudMiddlewareRepo`.
7.  **Playbook**: Select `ansible/playbooks/test_liberty.yml` from the dropdown. 
    *   _Note: If you don't see it, ensure your Project Sync was successful._
8.  **Credentials**: Select `Dev-SSH-Key`.
9.  Click **Save**.

## 6. Running a Test

1.  Navigate to **Resources -> Templates**.
2.  Find `Test Liberty Connectivity` and click the **Launch** (Rocket) icon.
3.  You will be redirected to the **Jobs** output page.
4.  Watch the logs verify:
    *   **Ping**: SUCCESS
    *   **Check Port 9080**: STARTED -> OK

If the job succeeds, AWX has full connectivity to your Liberty infrastructure!
