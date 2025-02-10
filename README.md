PostgreSQL Primary-Read-Replica Automation API

Overview

This project provides an API that automates the setup of a PostgreSQL primary-read-replica architecture using Terraform and Ansible. The API allows users to configure key parameters such as PostgreSQL version, instance type, and number of replicas. It dynamically generates and applies Terraform configurations to provision AWS infrastructure and executes Ansible playbooks to install and configure PostgreSQL, ensuring seamless replication between the primary and replicas.

Features

Infrastructure as Code (IaC): Uses Terraform modules for flexible and maintainable infrastructure provisioning.

Configuration Management: Uses Ansible for setting up and configuring PostgreSQL with replication.

Security Best Practices: Uses AWS Session Manager instead of SSH for Ansible execution, enhancing security.

Modular and Scalable: Supports dynamic configurations for PostgreSQL settings (e.g., max_connections, shared_buffers).

End-to-End Automation: Provides API endpoints to generate Terraform and Ansible configurations, apply infrastructure changes, and execute PostgreSQL setup.
