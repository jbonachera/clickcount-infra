variable "nomad_instance_count" {
    default = "3"
}
variable "aws_access_key" {}
variable "aws_ssh_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "lb_auth_token" {}
variable "zone_id" {}
variable "zone" {}
variable "nomad_cname" {
    default = "nomad"
}
variable "service_cname" {
    default = "*.app"
}
