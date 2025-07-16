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

## What I use
- [Ansible](https://www.ansible.com/)
- [Packer](https://developer.hashicorp.com/packer)
- [VirtualBox](https://www.virtualbox.org/)
- [Terraform](https://developer.hashicorp.com/terraform)
- [Kali Linux](https://www.kali.org/)
- [Windows Server 2025](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025)
- [Windows 10 Enterprise](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)

## Other resources that helped me
- [Create the answer file for Windows Server](https://github.com/chef/bento/blob/main/packer_templates/win_answer_files/2025/Autounattend.xml)
- [Guest Additions Script](https://github.com/eaksel/packer-Win2022/blob/main/scripts/virtualbox-guest-additions.ps1)
- [Disable Password Complexity Requirement](https://www.windows-commandline.com/net-accounts-command/)
- [Answer File Components](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/components-b-unattend)
- [Disable SMB Signing](https://umatechnology.org/how-to-disable-smb-signing-by-default-on-windows-11/)
- [VBoxManage modifyvm properties](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifyvm.html)
- [Similar project](https://github.com/dteslya/win-iac-lab)
- [Similar project #2](https://github.com/blink-zero/ansible-ad-lab)
- [Packer Docs for VirtualBox](https://developer.hashicorp.com/packer/integrations/hashicorp/virtualbox/latest/components/builder/iso)
- [Ansible modules for Active Directory](https://galaxy.ansible.com/ui/repo/published/microsoft/ad/docs/?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW)
- [Terraform Documentation for AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
