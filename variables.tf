variable "tencentcloud_secret_id" {
  description = "Tencent Cloud Secret ID"
  type        = string
  sensitive   = true
}

variable "tencentcloud_secret_key" {
  description = "Tencent Cloud Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Tencent Cloud Region"
  type        = string
  default     = "ap-guangzhou"
}

variable "rancher_api_url" {
  description = "Rancher Server URL"
  type        = string
}

variable "rancher_token_key" {
  description = "Rancher API Bearer Token"
  type        = string
  sensitive   = true
}

variable "tke_clusters" {
  description = "TKE clusters config"
  type = map(object({
    vpc_id            = string
    subnet_id         = string
    security_group_id = string
    key_id            = string
    cluster_cidr      = string
    instance_type     = string
    desired_capacity  = number
  }))
}
