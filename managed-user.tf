# resource "aws_eks_access_entry" "std4_eks_access_entry" {
#     cluster_name = aws_eks_cluster.std4_eks_cluster.name
#     principal_arn = "arn:aws:iam::476293896981:user/std-001" # 변수로 따로 설정을 권장함
#     kubernetes_groups = ["masters"]
#     type = "STANDARD"
# }

# # 사용자에게 클러스터 권한 연결
# resource "aws_eks_access_policy_association" "std4_eks_access_policy_association" {
#     cluster_name = aws_eks_cluster.std4_eks_cluster.name
#     policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#     principal_arn = aws_eks_access_entry.std4_eks_access_entry.principal_arn

#     access_scope {
#       type = "cluster" # 클러스에 대한 전체 권한
#     }
#     depends_on = [ aws_eks_access_entry.std4_eks_access_entry ] # 사용자 지정 후에 실행되도록 설정
# }

# tfvars 사용 방법
resource "aws_eks_access_entry" "std4_eks_access_entry" {
    for_each = toset (var.eks_admins)
    cluster_name = aws_eks_cluster.std4_eks_cluster.name
    principal_arn = each.value # 변수로 따로 설정을 권장함
    kubernetes_groups = ["masters"]
    type = "STANDARD"
}

# 사용자에게 클러스터 권한 연결
resource "aws_eks_access_policy_association" "std4_eks_access_policy_association" {
    for_each = toset (var.eks_admins)
    cluster_name = aws_eks_cluster.std4_eks_cluster.name
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    principal_arn = aws_eks_access_entry.std4_eks_access_entry[each.key].principal_arn

    access_scope {
      type = "cluster" # 클러스에 대한 전체 권한
    }
    depends_on = [ aws_eks_access_entry.std4_eks_access_entry ] # 사용자 지정 후에 실행되도록 설정
}