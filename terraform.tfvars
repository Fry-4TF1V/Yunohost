openstack_credentials = {
    user_name   = "user-AbCdEfGh"
    tenant_name = "1234567890123456"
    password    = "YourOpenstackTenantPassword"
    auth_url    = "https://auth.cloud.ovh.net/v3"
    region      = "GRA11"
}

public_cloud_instance = {
    flavor        = "d2-2"
    image         = "Debian 11"
    user          = "debian"
    name          = "yunohost"
    keypair_name  = "yunohost_publickey"
}

rule = {
  ssh = {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
  }
  http = {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 80
    port_range_max    = 80
    remote_ip_prefix  = "0.0.0.0/0"
  }
  https = {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 443
    port_range_max    = 443
    remote_ip_prefix  = "0.0.0.0/0"
  }
}
