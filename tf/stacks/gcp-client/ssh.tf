resource "tls_private_key" "admin_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "admin_private_key" {
  filename = "keys/${var.environment}-admin.key"
  content  = tls_private_key.admin_key.private_key_pem

  file_permission = "0400"
}
