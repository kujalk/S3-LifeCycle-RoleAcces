variable firstbucket {
  type    = string
  default = "jana-client006"
}

variable secondbucket {
  type    = string
  default = "jana-client007"
}

#This IAM user should have access to both S3 buckets, then only Terraform can able to delete it
variable terraformuser {
  type    = string
  default = "janarthanan"
}

#This IAM user should be previously created and have access to only 2nd bucket
variable iamuser {
  type    = string
  default = "myuser"
}

#This IAM role should be previously created for EKS
variable rolename {
  type    = string
  default = "Monitor_EC2"
}

#The name of Policy which is going to be attached to above role
variable policyname {
  type    = string
  default = "eks-cluster-s3"
}



