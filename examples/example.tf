variable "env" {
  default = "core-us-dev"
}

variable "first_cidr" {
  default = "10.100.0.0/16"
}

variable "route_tables" {
  default = ["rtb-123", "rtb-456"]
}

variable "second_cidr" {
  default = "10.101.0.0/16"
}

locals {
  tags = {
    Creator     = "Terraform"
    Environment = "${var.env}"
    Owner       = "my-team@my-company.com"
  }
}

module "vpc_peering_requester" {
  source              = "github.com/jjno91/terraform-aws-vpc-peering-requester?ref=master"
  env                 = "${var.env}"
  vpc_id              = "my-vpc"
  vpc_route_tables    = ["${var.route_tables}"]
  peer_env            = "core-ca-dev"
  peer_vpc_id         = "their-vpc"
  peer_owner_id       = "their-aws-account"
  peer_region         = "their-region"
  peer_vpc_cidr_block = "${var.first_cidr}"
  tags                = "${local.tags}"
}

# if the VPC you are peering with has more than one CIDR associated
# then you will have to create additional routes and security group rules outside of the module
resource "aws_route" "this" {
  count                     = "${length(var.route_tables)}"
  route_table_id            = "${element(var.route_tables, count.index)}"
  destination_cidr_block    = "${var.second_cidr}"
  vpc_peering_connection_id = "${module.vpc_peering_requester.vpc_peering_connection_id}"
}

resource "aws_security_group_rule" "ingress" {
  description       = "Ingress peer CIDR"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${module.vpc_peering_requester.security_group_id}"
  cidr_blocks       = ["${var.second_cidr}"]
}

resource "aws_security_group_rule" "egress" {
  description       = "Egress peer CIDR"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${module.vpc_peering_requester.security_group_id}"
  cidr_blocks       = ["${var.second_cidr}"]
}
