#output "cluster_endpoint" {
#  value = join("", aws_rds_cluster.aurora-db-cluster.*.endpoint)
#}
# 
#output "all_instance_endpoints_list" {
#  value = [concat(
#    aws_rds_cluster_instance.aurora-cluster-instance.*.endpoint,
#  )]
#}
# 
#output "reader_endpoint" {
#  value = join("", aws_rds_cluster.aurora-db-cluster.*.reader_endpoint)
#}
# 
#output "cluster_identifier" {
#  value = join("", aws_rds_cluster.aurora-db-cluster.*.id)
#}