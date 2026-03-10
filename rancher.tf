# kubeconfig files of TKE Clusters created before
resource "local_file" "kubeconfig" {
  for_each = var.tke_clusters
  filename = "${path.module}/.kube/kubeconfig-${each.key}.yaml"
  content  = tencentcloud_kubernetes_cluster_endpoint.tke_endpoint[each.key].kube_config
}

# Create rancher imported clusters
resource "rancher2_cluster" "imported_tke" {
  for_each    = var.tke_clusters
  name        = "tke-${each.key}"
  description = "Imported TKE cluster: ${each.key}"
}

# exec import command for TKE clusters
resource "null_resource" "rancher_registration" {
  for_each = var.tke_clusters

  triggers = {
    manifest_url = rancher2_cluster.imported_tke[each.key].cluster_registration_token.0.manifest_url
  }

  provisioner "local-exec" {
    command = "curl --insecure -sfL ${rancher2_cluster.imported_tke[each.key].cluster_registration_token.0.manifest_url} | kubectl --kubeconfig ${local_file.kubeconfig[each.key].filename} apply -f -"
  }

  depends_on = [
    local_file.kubeconfig
  ]
}
