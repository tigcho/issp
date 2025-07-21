# ISSP - Inter-Solar System Police

ISSP is an intentionally vulnerable Active Directory testing lab. It is designed for myself or others to explore and practice AD exploitation techniques in a controlled environment. In the world of Cowboy Bebop, you are taking the role of Edward Wong Hau Pepelu Tivrusky IV, a brilliant hacker who is trying to infiltrate the ISSP's Active Directory.

## How to Deploy
### Prerequisites
```bash
# - Ansible
# - Packer
# - VirtualBox (for local) 
# - AWS CLI + Terraform (for AWS)

# Install Packer plugins
packer plugin install github.com/hashicorp/virtualbox
packer plugin install github.com/hashicorp/amazon
```

### Option 1: Local Deployment

```bash
# build images
cd packer/virtualbox/[jet-dc and spike-clt and ed-atk]
packer build .

# test connectivity and run playbooks
cd ../../../ansible
ansible windows -i virtualbox/inventory.ini -m win_ping
ansible-playbook -i virtualbox/inventory.ini issp.yml
```

### Option 2: AWS Deployment

```bash
# configure aws creds
aws configure

# create a keypair for ssh access
aws ec2 create-key-pair --key-name [name] --query 'KeyMaterial' --output text > [name].pem
chmod 400 [name].pem

# build images
cd packer/aws/[jet-dc and ed-atk]
packer build .

# edit terraform/terraform.tfvars to include custom ami etc
nvim terraform/terraform.tfvars

# deploy the infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# edit aws/inventory.ini to include public ip
nvim ../ansible/aws/inventory.ini

# run playbooks
cd ../ansible/aws
ansible-playbook -i inventory.ini issp.yml
```

## Vulnerabilities
inspired by [this script](https://github.com/safebuffer/vulnerable-AD)
- Weak Password Policy
- Kerberoasting
- AS-REP Roasting 
- SMB Signing Disabled
- Privilege Escalation (DNS Admins, Group Nesting)
- Constrained Delegation
- Unconstrained Delegation
- Weak Shares
