locals {
  # Ubuntu 22.04-amd64-server AMI in eu-west-1
  ubuntu_ami = "ami-0a3a484e07ffb6be7" # amazon/ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20221101.1
}

data "aws_iam_policy_document" "assume_role_router" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "router" {
  name               = "${var.environment}-router"
  assume_role_policy = data.aws_iam_policy_document.assume_role_router.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_iam_instance_profile" "router" {
  name = "${var.environment}-router"
  role = aws_iam_role.router.name
}

resource "aws_instance" "router" {
  associate_public_ip_address = true
  ami                         = local.ubuntu_ami
  key_name                    = aws_key_pair.admin.key_name
  instance_type               = "t2.micro"
  availability_zone           = module.vpc.azs[0]
  iam_instance_profile        = aws_iam_instance_profile.router.name

  subnet_id = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.router.id,
    aws_security_group.wireguard_ssh_check.id,
  ]

  tags = {
    Name = "${var.environment}-router"
  }

  root_block_device {
    volume_size = 8
  }
  user_data = data.template_cloudinit_config.user_data.rendered

  source_dest_check = false

  connection {
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("keys/${var.environment}-admin.key")
  }

  provisioner "file" {
    source      = "keys/wg0.conf"
    destination = "/tmp/wg0.conf"
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    content = templatefile("scripts/init-router.yaml", {
      hostname : "router",
      domain : "${var.environment}.local",
    })
    merge_type = "list(append)+dict(no_replace,recurse_array)+str()"
  }
}

resource "aws_route" "upstream" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "192.168.1.0/24"
  network_interface_id   = aws_instance.router.primary_network_interface_id
}

###################################
# Router access security group
###################################
resource "aws_security_group" "router" {
  name   = "${var.environment}-router"
  vpc_id = module.vpc.vpc_id

  ingress {
    description      = "WG from anywhere"
    from_port        = 53145
    to_port          = 53145
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
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
