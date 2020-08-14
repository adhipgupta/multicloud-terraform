# multicloud-terraform
This repo includes the example (main.tf) and the Terraform modules required to
deploy a secure Ipsec VPN between AWS and Azure using their cloud native VPN solutions. 

You can follow my blogpost which takes you through the deployment [here](https://medium.com/@adhip12/starting-your-multi-cloud-journey-with-terraform-part-1-b240155036d8).

## Getting Started
### Download Terraform
You can download the latest Terraform executable from [here](https://www.terraform.io/downloads.html)

### Set you AWS and Azure credentials.
Terraform has great documentation on how you can setup your [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and [Azure](https://www.terraform.io/docs/providers/azurerm/index.html) credentials.
You can either set your environment variabless or the set the provider section in your main.tf file.

```
provider "azurerm" {
  features {}
  subscription_id = 
  tenant_id       = 
  client_secret   = 
  client_id       = 
}

provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}
```

### Deploy
Run the following commands to deploy the modules defined in the main.tf file
1. `terraform init`

2. `terraform plan`

3. `terraform apply`

As part of the apply, we will be deploying VMs in AWS and Azure and will need the following variables to be set to SSH onto these instances.

`azure_username` : Username to SSH into the Azure instance

`azure_password` : Password to SSH into the Azure instance

`aws_public_ssh_key`  : Public portion of your local SSH key.

Note: You can always change the Azure instance to use SSH keys by modifying the modules/azure/vnet/vnet.tf file

### Destroy
`terraform destroy`


