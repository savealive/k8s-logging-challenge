variable "cluster-name" {
  default = "eks-cluster"
  type    = "string"
}

variable "ssh_keypair" {
  type = "map"

  default = {
    name             = "ec2_user"
    private_key_path = "~/.ssh/ec2-access.pem"
    public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcSdJg7Ur61z5a6d1Cts1WXoum08fE3EDxzTVs5WmVl/CmfT3v2PWDLkTipQf5Ide8FJuY95+PBprGtja5UDAGkJxRliawJmdNml2IEvRFH3vbm5R+Ljfwyuap4H/NExfnU8qkFheLK+DSQRN3PNxtGRQ87+bGcXOQ6kLSupZGPK/V4SP37Th4BMD9W1bP6rvGCBtsFYOuNsCPtL92d1Iqhpu5qAmiEiBTR+kmAZQTSxOtZNDymQIFeWx5yK6RxWoe4GG13Yi0IZtqJWcfCUJvwAmenwCE5Lza7C/bdndHwgsJn4/2vwoyTv1btLJUEgjNr6GUIL+r6bVw0iltPXIz"
  }
}
