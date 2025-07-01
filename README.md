# ISSP - Vulnerable Active Directory Testing Lab

ISSP is an intentionally vulnerable Active Directory testing lab. It is designed for myself or others to explore and practice AD exploitation techniques in a controlled environment.

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
packer build -force .

# test connectivity and run playbooks
cd ../../../ansible
ansible windows -i inventories/virtualbox/inventory.ini -m win_ping
ansible-playbook -i inventories/virtualbox/inventory.ini issp.yml
```

### Option 2: AWS Deployment

```bash
# build AMI images
cd packer/aws/[jet-dc and spike-clt and ed-atk]
packer build -force .

# deploy infrastructure
cd ../../../terraform
terraform init
terraform apply

# test connectivity and run playbooks on instances
cd ../ansible
ansible windows -i inventories/aws/inventory.ini -m win_ping
ansible-playbook -i inventories/aws/inventory.ini issp.yml
```

## Vulnerabilities
inspired by [this script](https://github.com/safebuffer/vulnerable-AD)
- Weak Password Policy
- Kerberoasting
- AS-REP Roasting 
- SMB Signing Disabled
- Privilege Escalation (DNS Admins, Group Nesting)
- Anonymous LDAP Bind
- Constrained Delegation
- Unconstrained Delegation
- DCSync Rights Exposure
- Weak ACLs
- Weak Shares
- AdminSDHolder Abuse

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
- [Similar project](https://github.com/dteslya/win-iac-lab)
- [Similar project #2](https://github.com/blink-zero/ansible-ad-lab)
- [Packer Docs for VirtualBox](https://developer.hashicorp.com/packer/integrations/hashicorp/virtualbox/latest/components/builder/iso)
- [Ansible modules for Active Directory](https://galaxy.ansible.com/ui/repo/published/microsoft/ad/docs/?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW)
