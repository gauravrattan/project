# **PostgreSQL Primary-Read-Replica Automation API**

## Overview

This project provides an API that automates the setup of a PostgreSQL primary-read-replica architecture using Terraform and Ansible. The API allows users to configure key parameters such as PostgreSQL version, instance type, and number of replicas. It dynamically generates and applies Terraform configurations to provision AWS infrastructure and executes Ansible playbooks to install and configure PostgreSQL, ensuring seamless replication between the primary and replicas.

## Features

- **Infrastructure as Code (IaC)**: Utilizes **Terraform modules** for flexible, reusable, and maintainable infrastructure provisioning.

- **Configuration Management**: Uses **Ansible** to automate the setup and configuration of **PostgreSQL with replication**.

- **Security Best Practices**: Enhances security by using **AWS Session Manager** instead of SSH for Ansible execution. The PostgreSQL cluster is deployed in a **private subnet** for better security.

- **Modular and Scalable**: Supports **dynamic configurations** for PostgreSQL settings (e.g., `max_connections`, `shared_buffers`), making it adaptable to different environments.

- **End-to-End Automation**: Provides **API endpoints** to generate Terraform and Ansible configurations, apply infrastructure changes, and automate the PostgreSQL setup.


## Terraform Directory Structure

```bash

├── backend
│   ├── backend.tfvars
│   ├── s3_backend.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
├── backend.tf
├── iam.tf
├── main.tf
├── module
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
└── versions.tf

```

###  **Short Explanation for Each Folder**  

```md
## Folder & File Overview

- **backend/** - Stores Terraform state configuration (S3 backend & DynamoDB for state locking).
- **modules/vpc/** - Reusable VPC module for defining networking resources.
- **iam.tf** - Defines IAM roles and permissions.
- **main.tf** - The main Terraform configuration file.
- **provider.tf** - Configures the cloud provider (AWS, GCP, etc.).
- **terraform.tfvars** - Stores variable values.
- **versions.tf** - Specifies required Terraform and provider versions.
```

# Ansible Configuration for PostgreSQL Setup  

This Ansible setup automates the installation and configuration of **PostgreSQL with replication** using a structured and modular approach. It follows best practices by organizing tasks into **roles** to ensure reusability and maintainability.

## Directory Structure  

```bash
├── ansible.cfg                # Ansible configuration file
├── inventory/
│   └── aws_ec2.yml            # Dynamic inventory configuration for AWS EC2
├── playbooks/
│   ├── playbook.yaml          # Main playbook for PostgreSQL setup
│   └── test-ssm.yml           # Playbook for testing AWS Session Manager connection
└── roles/
    └── postgress/
        ├── handlers/
        │   └── main.yaml      # Defines handlers for service restarts
        ├── tasks/
        │   ├── core_config.yml    # Common PostgreSQL configurations
        │   ├── install.yml        # PostgreSQL installation steps
        │   ├── main.yml           # Entry point for task execution
        │   ├── master_config.yml  # Configuration for PostgreSQL master node
        │   └── worker_config.yml  # Configuration for PostgreSQL replica node
        ├── templates/
        │   └── postgresql.conf.j2 # Template for PostgreSQL configuration file
        └── vars/
            └── main.yml           # Variable definitions for PostgreSQL setup
```

## Features  

- **Role-Based Structure** – Separates concerns using Ansible **roles** for better maintainability.  
- **Dynamic Inventory** – Uses **AWS EC2 dynamic inventory** for automatic instance discovery.  
- **Automated PostgreSQL Replication** – Configures **master** and **replica** nodes with predefined roles.  
- **Secure Execution** – Runs through **AWS Session Manager** instead of direct SSH access, enhancing security.  
- **Template-Based Configuration** – Uses **Jinja2 templates** to dynamically generate `postgresql.conf`.  









