data "aws_iam_policy_document" "assume_role_client" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "client" {
  name = "${var.environment}-client"
  role = aws_iam_role.client.name
}

resource "aws_security_group" "client" {
  name   = "${var.environment}-client"
  vpc_id = var.vpc_id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "client" {
  name                = "${var.environment}-client"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_client.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "tls_private_key" "client_admin_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "client_admin" {
  key_name   = "${var.environment}-client-admin-key"
  public_key = tls_private_key.client_admin_key.public_key_openssh
}

resource "local_file" "client_admin_private_key" {
  filename = "keys/${var.environment}-admin.key"
  content  = tls_private_key.client_admin_key.private_key_pem

  file_permission = "0400"
}

data "aws_subnets" "client" {
  tags = {
    Type = "private"
  }
}

resource "aws_instance" "client_priv" {
  count = var.client_count

  associate_public_ip_address = false
  ami                         = local.client_ami
  key_name                    = aws_key_pair.client_admin.key_name
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.client.name

  subnet_id = var.client_subnets[count.index % 2]

  vpc_security_group_ids = [
    aws_security_group.client.id,
  ]

  tags = {
    Name = "${var.environment}-client-${count.index}"
  }

  root_block_device {
    volume_size = 32
  }
}
