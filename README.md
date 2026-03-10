
# TKE to Rancher Automation Demo

## Overview

This project provides a fully automated Infrastructure as Code (IaC) solution using Terraform. It batches the provisioning of multiple Tencent Kubernetes Engine (TKE) clusters in parallel and seamlessly registers them into an existing Rancher management server as imported clusters.

## Prerequisites

Before running this project, ensure you have the following installed and configured on your host machine (or CI/CD runner):

- Terraform

- kubectl (Required for applying the Rancher registration manifest to the new clusters)

- curl (Required for fetching the Rancher manifest securely)

- Valid Tencent Cloud API Credentials (Secret ID and Secret Key)

- A running Rancher Server and a generated API Bearer Token.

## Project Structure

The codebase is modularized into the following files for better maintainability and readability:

`providers.tf`: Configures the required Terraform providers (tencentcloud, rancher2, local, and null). It establishes the authentication connections to both the Tencent Cloud API and the Rancher server API.

`variables.tf`: Defines the input parameters required for the deployment. This includes sensitive credentials and the tke_clusters dictionary (map of objects) that drives the dynamic batch creation logic.

`tke.tf`: Contains the resource definitions to create the bare TKE control planes and their associated node pools. Decoupling the control plane from the node pool is a best practice that prevents full cluster rebuilds during future node scaling operations.

`rancher.tf`: Handles the logical representation of the clusters inside Rancher. It extracts the raw kube_config from Tencent Cloud, saves it to a local directory, and uses a null_resource with a local-exec provisioner to inject the Rancher registration manifest (manifest_url) directly into the newly created TKE clusters.

`terraform.tfvars`: The user-defined variable file (ignored by version control) where you input your specific credentials and define the cluster topology.

## Usage Guide

1. Initialize the Working Directory
Run the following command to download the necessary Terraform provider plugins:
```
terraform init
```
2. Configure Your Variables
Ensure your `terraform.tfvars` file is present in the root directory and populated with your specific configuration, including your tencentcloud_secret_id, rancher_api_url, and the map of tke_clusters you wish to deploy.

3. Review the Execution Plan
Generate and review the execution plan to see exactly what cloud and logical resources Terraform will create:


```
terraform plan
```

4. Apply the Configuration
Execute the plan to build the infrastructure:

```
terraform apply
```

Type yes when prompted. Terraform will concurrently provision the TKE clusters, wait for the node pools to become active, download the configuration files, and register them to your Rancher server.

## Architecture Notes & Workarounds

Dynamic Provider Limitation: Terraform's dependency graph requires all provider configurations to be statically known before execution. Because the TKE cluster endpoint and certificates are only generated after the cluster is created, we cannot use the native Terraform Kubernetes provider in the same run to apply the Rancher manifest.

Execution Bridge: To work around this limitation and satisfy the requirement of a single-run pipeline, this project uses a local_file to temporarily store the kubeconfig and a null_resource to execute kubectl apply via the local host's shell.

Security Warning: The local .kube directory and the terraform.tfstate file will contain sensitive, cluster-admin level credentials. Ensure your state file is stored securely (e.g., using a remote backend like AWS S3 or Tencent COS with encryption enabled) and never commit these files to public version control.
