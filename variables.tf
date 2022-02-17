variable "aws_region" {
    type = string
    description = "The region in which to create the lambda functions"
}

variable "state_bucket" {
    type = string
    description = "The name of the S3 bucket in which to store the terraform state"
}