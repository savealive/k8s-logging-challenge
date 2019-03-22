data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.kube.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  kube-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
# Fix fds limit for Elastic
cat <<EOF > /etc/docker/daemon.json
{
  "bridge": "none",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  },
  "live-restore": true,
  "max-concurrent-downloads": 10
}
EOF
systemctl restart docker
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.kube.endpoint}' --b64-cluster-ca '${aws_eks_cluster.kube.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "kube" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.kube-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.ec2_key.key_name}"
  name_prefix                 = "terraform-eks-kube"
  security_groups             = ["${aws_security_group.kube-node.id}"]
  user_data_base64            = "${base64encode(local.kube-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.ssh_keypair["name"]}"
  public_key = "${var.ssh_keypair["public_key"]}"
}

resource "aws_autoscaling_group" "kube" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.kube.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-kube"
  vpc_zone_identifier  = ["${aws_subnet.kube.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-kube"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.kube-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}
