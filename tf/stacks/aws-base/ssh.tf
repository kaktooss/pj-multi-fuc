resource "tls_private_key" "admin_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "admin" {
  key_name   = "${var.environment}-admin-key"
  public_key = tls_private_key.admin_key.public_key_openssh
}

resource "local_file" "admin_private_key" {
  filename = "keys/${var.environment}-admin.key"
  content  = tls_private_key.admin_key.private_key_pem

  file_permission = "0400"
}
