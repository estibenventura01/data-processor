# Data Processor

## Prerequisites

Everything runs from your own machine. Nothing is installed on the target host by hand —
Ansible installs Docker and the Compose v2 plugin.

- Terraform (>= 1.6) — `brew install terraform`, or HashiCorp's apt repository
- Ansible — `brew install ansible`, or `pip3 install ansible`
- The `community.general` Ansible collection:

        ansible-galaxy collection install -r ansible/requirements.yml

- An SSH keypair:

        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_dataproc

- `curl` — preinstalled on macOS and most Linux distributions
- A Linode account and a Personal Access Token (see below)

### Linode API token scopes

Create the token in Linode Cloud Manager under Profile -> API Tokens -> Create a
Personal Access Token, and set these scopes:

- Linodes — Read/Write
- Firewalls — Read/Write
- Account — Read Only
- Events — Read Only
- Images — Read Only
- IPs — Read Only
- Everything else (Databases, Domains, Kubernetes, Longview, Monitor, NodeBalancers,
  Object Storage, StackScripts, Volumes, VPCs) — No Access

Read/Write on Linodes and Firewalls is what creates and destroys the instance and its
Cloud Firewall. The four Read Only scopes are what Terraform needs to look up the image,
region and IP address, and to read back the state of what it created.

## Run it from scratch

All commands are run from the repository root.

**1. Initialise Terraform**

    terraform -chdir=terraform init

**2. Create the instance**

    terraform -chdir=terraform apply

Terraform prompts for every variable that has no default. There are three:

- `authorized_keys` — the contents of your SSH **public** key. Print it with
  `cat ~/.ssh/id_ed25519_dataproc.pub` and paste the whole line.
- `root_pass` — a root password of your choosing. Linode requires one when deploying
  from an image.
- `token` — your Linode API token.

`token` and `root_pass` are declared `sensitive`, so Terraform hides what you type at
those two prompts — nothing appears on screen, not even dots. That is expected: type or
paste the value and press Enter even though the line looks empty. `authorized_keys` is
not sensitive and will be visible as you paste it, which is fine — it is a public key.

Two settings are not prompted for:

- **Region** — declared in `terraform/variables.tf` with a default of `us-east`. To
  deploy somewhere else, edit that variable's `default` before running `apply`. For a
  one-off change without editing the file,
  `terraform -chdir=terraform apply -var region=us-west` also works.
- **Instance type** — set literally to `g6-standard-1` on the `linode_instance`
  resource in `terraform/main.tf`. Edit it there to use a different plan. A 1GB Nanode
  can struggle with the Docker build, so `g6-standard-1` or larger is recommended.

On success, Terraform writes the instance's public IP into `ansible/inventory.ini`. You
can also print it at any time:

    terraform -chdir=terraform output instance_ip

Everywhere below, replace `<IP>` with that address.

**3. Clear a stale SSH host key (optional)**

Linode reuses IP addresses. If `apply` hands you an address you have connected to
before, SSH refuses the new host's key with `REMOTE HOST IDENTIFICATION HAS CHANGED`.
If that happens, clear the old entry and continue:

    ssh-keygen -R <IP>

Host key checking is set to `accept-new`, not disabled — a host that has never been seen
is trusted automatically, while a host whose key has changed is still rejected.

**4. Configure the host and start the stack**

    ansible-playbook -i ansible/inventory.ini ansible/deploy.yml

**5. Confirm it works**

    curl -i http://<IP>:8080/

Expect `HTTP/1.1 200 OK`.

## Verifying it further (optional)

A second run of the playbook should report `changed=0`:

    ansible-playbook -i ansible/inventory.ini ansible/deploy.yml

The stack should also come back on its own after a reboot:

    ssh root@<IP> reboot
    sleep 75
    curl -i http://<IP>:8080/

## Tear it down

    terraform -chdir=terraform destroy

Terraform evaluates the whole configuration before it can plan a destroy, so it prompts
for the same three values again — `authorized_keys`, `root_pass` and `token`. Supply the
same ones you used for `apply`.

Afterwards, revoke the API token in the Linode Cloud Manager.
