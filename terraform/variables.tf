variable "region" {
  type    = string
  default = "us-east-1"
}


variable "node_group_name" {
  type    = string
  default = "NODE-MATRIX"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_size" {
  default = 2
  type    = number
}

variable "min_size" {
  default = 2
  type    = number
}

variable "max_size" {
  default = 2
  type    = number
}

variable "aws_eks_cluster" {
  default = "MATRIX"
  type    = string
}

variable "aws_subnets" {
  default = "vpc-id"
  type    = string
}

variable "aws_iam_role" {
  default = "eks-node-group-k8s"
  type    = string
}

variable "eks_cluster" {
  default = "eks-cluster-role-k8s"
  type    = string
}

variable "instance_type" {
  default = "t2.large"
  type    = string
}

variable "key_name" {
  default = "zorin"
  type    = string
}

variable "instance_count" {
  default = 2
  type    = number
}