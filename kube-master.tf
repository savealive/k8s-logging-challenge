resource "aws_eks_cluster" "kube" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.kube-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.kube-cluster.id}"]
    subnet_ids         = ["${aws_subnet.kube.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.kube-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.kube-cluster-AmazonEKSServicePolicy",
  ]
}
