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
5. Add the 'Replace Tokens' extension to your Azure DevOps Organisaion, available from here:
<https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens&targetId=b28c0c12-65e8-4fa7-9a45-28ac8368c6c5&utm_source=vstsproduct&utm_medium=ExtHubManageList>

# Description of Build Pipeline yml tasks

# Stages

There are two distinct stages to this pipeline: Build and Config.
The Build Stage uses Terraform to build the basic infrastructure in Azure RM.
The Config Stage uses Ansible to configure the server created by the previous stage.
Both stages utilise the Microsoft ADO Agent Ubuntu-latest VM.

# Build
## Variables

I am using variables set in the pipeline for the servername and the name of the Azure Resource Group the server will reside within.
There is also a Variable Group referenced.  This variable group is created in the Pipeline Library and it is linked to the Azure Key Vault created in Azure RM.  You can then decide which variables you wish to use in the pipeline (the ones I used are listed below).  You will need to make sure that the Service Principal you are using has access to at least 'Get' secrets from the Key Vault.

## Task 'Replace tokens in Terraform Files'

This first task in the build stage uses the 'Replace Tokens' extension to replace all references to secrets or variables that I don't want to include in my code I check in to github.  I require the values of these secrets at run time.  In the code the 'tokens' are referenced by enclosing them in #{}# - for example the below code in variables.tf the 'value' for default will become the value of the Key Vault Secret 'kv-win-admin-password.'

```
variable "kv-win-admin-password" {
  type    = string
  default = "#{kv-win-admin-password}#"
}
```
## Terraform Init

I use a 'bash' task and explicitly use environemnt variables to configure the location of the terraform state file.

## Terraform Validate

Again I use a 'bash' task.  Terraform validate is good way to capture errors before you even begin (was veery useful when I was first configuring variables from the Azure Key Vault).

## Terraform Plan

Terraform Plan will display what terraform will do if given the chnace to apply.

## Terraform Apply

Assuming the previous terraform commands have been successful this command will build the infrastructure described in the plan.

# Config

## Run Ansible Config ps1 on Az VM

In order for Ansible to be able to 'talk' to a Windows machine the machine itself requires some configuration to be run on it.  This can be easily done by running a powershell script that Ansible provide.  This task uses the Azure CLI's ability to run a script within a VM (as long as you have credentials for Azure that have the right to do so).  I have a copy of the script from Ansible in the repo and I use credentials for my Azure RM subscription that are stored in the Key Vault - the credentials of the Service Principal - and then linked as variables in the pipeline variable group.

## Set secretserver_pub_ip as var

I need to know the public IP of the server that terraform built for me.  I was using terraform outputs to do this, but I often found that nothing would get outputted by terraform - I suspect a delay between terraform telling Azure RM to create the resource and the resource being created caused this.  In order to get round this I use Azure CLI to look in to my subscription and grab the publci IP of the server (using the 'pl' variables I set in the beginning for the server name and resource group name).  I then set the result as a pipeline variable that can be used further down.

```
secretserver_pub_ip=$(az vm show -d -g $(PL-RG-NAME) -n $(PL-SERVER-NAME) --query publicIps -o tsv)
echo "##vso[task.setvariable variable=secretserver_pub_ip;]$secretserver_pub_ip"
```
The first line sets the ip as a variable within the Azure CLI session.
The second line sets that variable as a pipeline variable.
ref
<https://colinsalmcorner.com/azure-pipeline-variables/>

## echo $(secretserver_pub_ip)

This is really a debug message left over from when I was looking for reasons why my code didn't work...

## Install pywinrm

This task is required because although the unbuntu-latest Microsoft ADO Agent has Ansible installed on it it doesn't have the required libraries for pywinrm and therefore cannot communicate with Windows servers via WinRM.

## Install Ansible Community.Windows

The default ubuntu-latest Microsoft ADO Agent doesn't have all the Windows Ansible modules needed either - this command installs what is required.

## 'Replace tokens in inventory,*.yml, *.sql'

Similar to what I did with the Build stage I need to replace the #{....}# tokens with values.
I do it at this stage in the pipeline as it will include the value for the secretserver_pub_ip which we only found out a cpouple of tasks ago.

## Remaining Ansible Tasks

The remaining tasks split the Ansible playbooks I have written into separate tasks - they could all be in one big playbook or, better still, included in a role.  I have left them in a list of smaller tasks to aid initial trouble shooting and make it easier for those less experienced in Ansible to easily read through what is being done.  The playbooks are easy to understand.
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
|secretserver_pub_ip|Pipeline|Public IP of the Server (queried after it is created)|

