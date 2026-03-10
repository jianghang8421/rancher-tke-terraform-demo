resource "tencentcloud_kubernetes_cluster" "tke_control_plane" {
  for_each                = var.tke_clusters
  vpc_id                  = each.value.vpc_id
  cluster_cidr            = each.value.cluster_cidr
  cluster_max_pod_num     = 32
  cluster_name            = "tke-${each.key}"
  cluster_desc            = "Managed by Terraform"
  cluster_max_service_num = 32
  cluster_deploy_type     = "MANAGED_CLUSTER"
  cluster_version         = "1.34.1"
}


resource "tencentcloud_kubernetes_node_pool" "tke_node_pool" {
  for_each           = var.tke_clusters
  name               = "np-${each.key}"
  cluster_id         = tencentcloud_kubernetes_cluster.tke_control_plane[each.key].id
  vpc_id             = each.value.vpc_id
  subnet_ids         = [each.value.subnet_id]
  desired_capacity   = each.value.desired_capacity
  max_size           = each.value.desired_capacity + 1
  min_size           = 1
  enable_auto_scale  = true

  auto_scaling_config {
    key_ids                    = [each.value.key_id]
    orderly_security_group_ids = [each.value.security_group_id]
    instance_type              = each.value.instance_type
    system_disk_type           = "CLOUD_PREMIUM"
    system_disk_size           = "50"
    public_ip_assigned         = true
    internet_charge_type       = "TRAFFIC_POSTPAID_BY_HOUR"
    internet_max_bandwidth_out = 10
  }
}


resource "tencentcloud_kubernetes_cluster_endpoint" "tke_endpoint" {
  for_each                        = var.tke_clusters
  cluster_id                      = tencentcloud_kubernetes_cluster.tke_control_plane[each.key].id
  cluster_internet                = true
  cluster_internet_security_group = each.value.security_group_id
  cluster_intranet                = true
  cluster_intranet_subnet_id      = each.value.subnet_id

  depends_on = [
    tencentcloud_kubernetes_node_pool.tke_node_pool
  ]
}
