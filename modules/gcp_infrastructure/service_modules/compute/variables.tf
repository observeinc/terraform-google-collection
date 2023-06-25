variable "observe" {
  description = "variables for agent config"
  type = object({
    domain                        = string,
    customer_id                   = string,
    datastream_token              = string,
    install_linux_host_monitoring = bool
  })
  default = {
    domain : "observe-staging.com",
    install_linux_host_monitoring : true,
    customer_id : null,
    datastream_token : null
  }
}

variable "public_key_path" {
  description = "Public key path"
  nullable    = true
  default     = "~/.ssh/id_rsa_ec2.pub"
  type        = string
}

# variable "private_key_path" {
#   description = "Private key path"
#   nullable    = false
#   default     = "~/.ssh/id_rsa_ec2"
#   type        = string
# }

# variable "use_branch_name" {
#   default     = "main"
#   description = "git repository branch to use"
#   type        = string
# }

variable "compute_values" {
  description = "variable for what compute instances to create"
  type        = map(any)
  default = {
    #https://cloud.google.com/compute/docs/images/os-details#ubuntu_lts
    UBUNTU_22_04_LTS = {
      recreate       = "changethistorecreate1"
      version        = "ubuntu-os-cloud/ubuntu-2204-lts"
      machine_type   = "e2-medium"
      description    = "Ubuntu 22_04 LTS"
      default_user   = "ubuntu"
      zone           = "us-west1-b"
      wait           = "120"
      user_data_file = "ubuntu_user_data.sh"
    }

    UBUNTU_20_04_LTS = {
      recreate       = "changethistorecreate1"
      version        = "ubuntu-os-cloud/ubuntu-2004-lts"
      machine_type   = "e2-micro"
      description    = "Ubuntu 20_04 LTS"
      default_user   = "ubuntu"
      zone           = "us-west1-b"
      wait           = "120"
      user_data_file = "ubuntu_user_data.sh"
    }

    # UBUNTU_18_04_LTS = {
    #   recreate       = "changethistorecreate1"
    #   version        = "ubuntu-os-cloud/ubuntu-1804-lts"
    #   machine_type   = "e2-medium"
    #   description    = "Ubuntu 18_04 LTS"
    #   default_user   = "ubuntu"
    #   zone           = "us-west1-b"
    #   wait           = "120"
    #   user_data_file = "ubuntu_user_data.sh"
    # }

    # RHEL_8 = {
    #   recreate       = "changethistorecreate1"
    #   version        = "rhel-cloud/rhel-8"
    #   machine_type   = "e2-medium"
    #   description    = "Red Hat Enterprise Linux 8"
    #   default_user   = "redhat"
    #   zone           = "us-west1-b"
    #   wait           = "300"
    #   user_data_file = "rhel_user_data.sh"
    # }

    # CENTOS_8 = {
    #   recreate       = "changethistorecreate1"
    #   version        = "centos-cloud/centos-stream-8"
    #   machine_type   = "e2-medium"
    #   description    = "CentOS Stream 8"
    #   default_user   = "centos"
    #   zone           = "us-west1-b"
    #   wait           = "120"
    #   user_data_file = "rhel_user_data.sh"
    # }
  }
}

variable "compute_filter" {
  type        = list(any)
  description = "list of compute instances to filter"
  default     = ["UBUNTU_20_04_LTS"]
  # default     = ["UBUNTU_18_04_LTS", "UBUNTU_20_04_LTS", "RHEL_8"]
}

variable "zone" {
  type        = string
  default     = "a"
  description = "zone to deploy to"
}

variable "project_id" {
  type        = string
  description = "GCP project to deploy sample env"
}

variable "region" {
  type        = string
  description = "GCP region to deploy sample env"
}

variable "name_format" {
  type        = string
  default     = "gcp-test-%s"
  description = "Name format"
}

variable "compute_instance_count" {
  type        = number
  default     = 2
  description = "Number of compute instances to instantiate"
}

variable "config_bucket_name" {
  type        = string
  description = "The name of the configuration bucket"
}