# Introduction

The code in this repo is deisgned to be used to create an instance of Thycotic Secret Server that can be used in a dev/test environment.  It relies on the user having a free account with Thycotic and both Azure RM and Azure DevOps accounts.  The code ca be used to run Azure DevOps Pipelines that can build and then destroy an instance of Secret Server.

# Pre-requisites

You will need the following setup before you can use this repo:

1. Thycotic Secret Server Download (web site files & setup.exe)
2. Azure RM Account
3. Storage account in Azure (used for holding Terrafomr state & software for Secret Server)
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

TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)