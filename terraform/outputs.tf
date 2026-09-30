output "instance_ip" {
  description = "Public IPv4 of the host for the Ansible inventory"
  value       = linode_instance.data-process.ip_address
}
