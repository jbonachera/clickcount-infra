data "aws_ami" "nomad" {                                                                           
  most_recent = true
  filter {
    name = "name"
    values = ["nomad-host-*"]
  }
  most_recent = true
}
