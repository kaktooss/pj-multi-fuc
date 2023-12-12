aws_region = "eu-west-1"
launch_block_size = 32

amd64_instance_type = "c5.4xlarge"
arm64_instance_type = "m7g.4xlarge"

amd64_aws_source_ami       = "ami-0694d931cee176e7d" #Ubuntu 22.04 LTS
amd64_aws_source_ami_owner = "099720109477" # Canonical
amd64_aws_ssh_username     = "ubuntu"

arm64_aws_source_ami       = "ami-0d3407241b2b6ec62" #Ubuntu 22.04 LTS
arm64_aws_source_ami_owner = "099720109477" # Canonical
arm64_aws_ssh_username     = "ubuntu"

subnet_name = "sandbox2-main-public-subnet"