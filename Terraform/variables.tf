variable "aws_region" {
  default = "ap-southeast-2"
}

variable "vpc_availability_zones" {
  type    = list(string)
  default = ["ap-southeast-2a", "ap-southeast-2b"]
}
variable "aws_account_id" {
  type    = string
  default = "339397515655"  
}
variable "image_version" {
  type        = string
  description = "Docker image tag to deploy"
  default     = "latest"
}