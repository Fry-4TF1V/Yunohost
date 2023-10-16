# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.openstack_credentials.user_name
  tenant_name = var.openstack_credentials.tenant_name
  password    = var.openstack_credentials.password
  auth_url    = var.openstack_credentials.auth_url
  region      = var.openstack_credentials.region
}

resource tls_private_key key {
  algorithm = "ED25519"
}

# variable private_key {
#   type        = string
#   description = "Public Key used by Openstack"
#   default     = "~/.ssh/id_rsa_ed25519"
# }

# variable public_key {
#   type        = string
#   description = "Public Key used by Openstack"
#   default     = "~/.ssh/id_rsa_ed25519.pub"
# }

# Import SSH Public Key
resource openstack_compute_keypair_v2 keypair {
  name       = var.public_cloud_instance.keypair_name
  public_key = tls_private_key.key.public_key_openssh
  region     = var.openstack_credentials.region
}

# Define a Security group for this project
resource openstack_networking_secgroup_v2 secgroup {
  name        = "yunohost_secgroup"
  description = "Security group for Yunohost"
  region      = var.openstack_credentials.region
}

# Define SecurityGroup rules
resource openstack_networking_secgroup_rule_v2 ingress {
  for_each = var.rule
  direction         = each.value["direction"]
  ethertype         = each.value["ethertype"]
  protocol          = each.value["protocol"]
  port_range_min    = each.value["port_range_min"]
  port_range_max    = each.value["port_range_max"]
  remote_ip_prefix  = each.value["remote_ip_prefix"]
  region            = var.openstack_credentials.region
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Create a Yunohost instance on PCI
resource openstack_compute_instance_v2 instance {
  count            = 1
  region           = var.openstack_credentials.region
  name             = var.public_cloud_instance.name
  image_name       = var.public_cloud_instance.image
  flavor_name      = var.public_cloud_instance.flavor
  key_pair         = var.public_cloud_instance.keypair_name
  network {
    name           = "Ext-Net"
    access_network = true
  }
}

# Save SSH Private key locally
resource local_file id_rsa {
  content         = tls_private_key.key.private_key_openssh
  filename        = "/tmp/id_rsa"
  file_permission = "0600"
}

# Save SSH Public key locally
resource local_file id_rsa_pub {
  content         = tls_private_key.key.public_key_openssh
  filename        = "/tmp/id_rsa.pub"
  # file_permission = "0600"
}

# Run the install script inside the instance
resource null_resource install {
  triggers = {
     server_id =  openstack_compute_instance_v2.instance[0].id
  }

  provisioner "remote-exec" {
    connection {
      host          = openstack_compute_instance_v2.instance[0].access_ip_v4
      type          = "ssh"
      user          = var.public_cloud_instance.user
      private_key   = tls_private_key.key.private_key_openssh
    }

    inline = ["sudo apt update -y", "echo Done!"]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${openstack_compute_instance_v2.instance[0].access_ip_v4},' -u ${var.public_cloud_instance.user} --private-key ${local_file.id_rsa.filename} -e 'public_key_file=${local_file.id_rsa_pub.filename}' install.yaml"
  }
}

output private_key {
  description   = "Generated private key"
  value         = nonsensitive(tls_private_key.key.private_key_openssh)
}

output public_ip {
  description   = "Public IP"
  value         = openstack_compute_instance_v2.instance[0].access_ip_v4
}
