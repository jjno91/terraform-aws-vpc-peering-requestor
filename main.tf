resource "aws_vpc_peering_connection" "this" {
  count         = var.create ? 1 : 0
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  tags = merge(
    {
      "Name" = "${var.env}-peer-${var.peer_env}"
    },
    {
      "Type" = "Requester"
    },
    var.tags,
  )
}

resource "aws_route" "this" {
  count                     = var.create ? var.route_count : 0
  route_table_id            = element(var.vpc_route_tables, count.index)
  destination_cidr_block    = var.peer_vpc_cidr_block
  vpc_peering_connection_id = element(aws_vpc_peering_connection.this.*.id, 0)
}

resource "aws_security_group" "this" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.env}-peer-${var.peer_env}-"
  vpc_id      = var.vpc_id
  tags = merge(
    {
      "Name" = "${var.env}-peer-${var.peer_env}"
    },
    {
      "Type" = "Peer"
    },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  count             = var.create ? 1 : 0
  description       = "Ingress peer CIDR"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = element(concat(aws_security_group.this.*.id, [""]), count.index)
  cidr_blocks       = [var.peer_vpc_cidr_block]
}

resource "aws_security_group_rule" "egress" {
  count             = var.create ? 1 : 0
  description       = "Egress peer CIDR"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = element(concat(aws_security_group.this.*.id, [""]), count.index)
  cidr_blocks       = [var.peer_vpc_cidr_block]
}

