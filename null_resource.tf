
resource "null_resource" "std4_update_kubeconfig" {

  # 노드 그룹이 생성 완료된 후 실행되도록 설정
  depends_on = [ aws_eks_node_group.std4_eks_node_group]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ap-south-2 --name ${aws_eks_cluster.std4_eks_cluster.id}"
  }
}
