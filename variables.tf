variable openstack_credentials {
  type = object({
    user_name   = string
    tenant_name = string
    password    = string
    auth_url    = string
    region      = string
  })
}

variable public_cloud_instance {
  type = object({
    flavor        = string
    image         = string
    user          = string
    name          = string
    keypair_name  = string
  })
}

variable rule {
  type = map(object({
    direction         = string
    ethertype         = string
    protocol          = string
    port_range_min    = number
    port_range_max    = number
    remote_ip_prefix  = string
  }))
}

