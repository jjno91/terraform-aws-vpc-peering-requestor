output "vpc_peering_connection_id" {
  description = "https://www.terraform.io/docs/providers/aws/r/vpc_peering.html#id"
  value       = "${aws_vpc_peering_connection.this.id}"
}

output "accept_status" {
  description = "https://www.terraform.io/docs/providers/aws/r/vpc_peering.html#accept_status"
  value       = "${aws_vpc_peering_connection.this.accept_status}"
}

output "security_group_id" {
  description = "Security group that grants access to and from the peer's CIDR"
  value       = "${aws_security_group.this.id}"
}
