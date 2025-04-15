resource "aws_instance" "node" {
  for_each               = var.node_map
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.development-public-1b.id
  key_name               = aws_key_pair.nodes.key_name
  instance_type          = each.value.type
  associate_public_ip_address = true
  
  tags          = {
    Name        = each.key
  }

  root_block_device {
    volume_type     = "gp2"
    volume_size     = each.value.size
    delete_on_termination   = true
  }  
}

output "instance_public_ips" {
  value = {
    for node_key, node in aws_instance.node
    node_key => node.public_ip
  }
  description = "The public IP addresses of the EC2 instances."
}
