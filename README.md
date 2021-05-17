# Introduction

The code in this repo is deisgned to be used to create an instance of Thycotic Secret Server that can be used in a dev/test environment.  It relies on the user having a free account with Thycotic and both Azure RM and Azure DevOps accounts.  The code can be used to run Azure DevOps Pipelines that can build and then destroy an instance of Secret Server.

# Pre-requisites

You will need the following setup before you can use this repo:

1. Thycotic Secret Server Download (web site files & setup.exe)
2. Azure RM Account
3. Storage account in Azure (used for holding Terraform state & software for Secret Server)
4. Azure Key Vault (used to store all passwords and Service Principal details)
5. Service Principal for Azure RM with contributor access to Azure and access to the Key Vault
6. Azure DevOps Account

# Azure RM Steps

Below are the detailed steps required to get your Azure subscription ready to use this repo.

1. Create a resource group ado config details (eg ado-config)
2. Create a storage account within that resource group.
3. Create a container in the storage account to house Terraform state (eg terraform)
4. Create a Key Vault
5. Create a Service Principal
6. Add details of the Service Principal (eg client-id, password) to the Key Vault as Secrets

# Azure DevOps Steps

1. Create a Project in ADO
2. Import this repo
3. Add a service connection for the Project, this is the service principal created in Azure RM
4. Create a variable group in the Projetc's pipeline libray and link it to the Azure Key Vault
5. Add the 'Replace Tokens' extension to your Azure DevOps Organisaion

# List of Variables Used

| Var | Type | Usage |
|-----|------|-------|
|kv-ado-spn-client-id|Azure Key Vault|Service Principal Client Id|
|kv-ado-spn-key|Azure Key Vault|Service Principal password|
|kv-ado-spn-subscription-id|Azure Key Vault|Service Principal Subscription Id|
|kv-ado-spn-tenant-id|Azure Key Vault|Service Principal Tenant Id|
|kv-sa-dleonard02-key1|Azure Key Vault|torage Account Access Key|
|kv-secretserver-source|Azure Key Vault|url location of Secret Server source files|
|kv-ss-setup|Azure Key Vault|url location of Secret Server setup.exe|
|kv-tf-state-blob-account|Azure Key Vault|storage account for terraform state|
|kv-tf-state-blob-container|Azure Key Vault|container for terraform state|
|kv-tf-state-blob-file|Azure Key Vault|file name of terraform state|
|kv-win-admin-password|Azure Key Vault|Password used for windows server (and others)|
|pl-rg-name|Pipeline|Name of Azure resource group to be created|
|pl-server-name|Pipeline|Name of Azure VM to be created|
|secrectserver_pub_ip|Pipeline|Public IP of the Server (queried after it is created)|
