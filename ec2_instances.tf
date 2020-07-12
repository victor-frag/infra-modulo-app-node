data "aws_ami" "ubuntu_18_04" {
  most_recent = true
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

# Generating a keypair to use on the machines
resource "aws_key_pair" "ssh_key_pair" {
  key_name = "ssh_key"
  public_key = file("${path.module}/keys/ssh_key.pub")
}

# Database instance
resource "aws_instance" "database" {
  # Using Ubuntu 18.04 LTS ami reference
  ami = data.aws_ami.ubuntu_18_04.id

  # Instance Type (Default t2.micro)
  instance_type = var.db_instance_type

  # Using private subnet
  subnet_id = aws_subnet.private_subnet.id

  vpc_security_group_ids = [
    aws_security_group.ssh_external.id, # SG that allows SSH only from one public ip
    aws_security_group.ssh_internal.id, # SG that allows SSH only from one from SSH SG
    aws_security_group.database.id # SG that allows traffic over the port 5432(Postgres port)
  ]

  # Using profile IAM profile to access the S3
  iam_instance_profile = aws_iam_instance_profile.s3_instance_profile.name

  # Use the generated ssh key
  key_name = "ssh_key"

  # Script which will run as soon as the instance start
  user_data = templatefile("${path.module}/scripts/user_data_db.sh.tlp", { 
    database_name = var.db_name, 
    database_user = var.db_user, 
    database_password = var.db_password 
  })

  tags = {
    Name = "Database Instance"
  }

  # Need to generate the Key before bring up the machine
  depends_on = [aws_key_pair.ssh_key_pair]
}

# Node application instance
resource "aws_instance" "app_server" {
  # Using Ubuntu 18.04 LTS ami reference
  ami = data.aws_ami.ubuntu_18_04.id

  # Instance Type (Default t2.micro)
  instance_type = var.app_instance_type

  # Using Public subnet
  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.ssh_external.id, # SG that allows SSH only from one public ip
    aws_security_group.node_application.id # SG that allows traffic over the port 5000(Node application port)
  ]

  # Using profile IAM profile to access the S3
  iam_instance_profile = aws_iam_instance_profile.s3_instance_profile.name

  # Enable Public address
  associate_public_ip_address = true

  # Use the generated ssh key
  key_name = "ssh_key"

  provisioner "file" {
    source      = "keys/ssh_key"
    destination = "/home/ubuntu/.ssh/id_rsa"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = self.public_ip
      private_key = file("${path.module}/keys/ssh_key")
    }
  }

  # Script which will run as soon as the instance start
  user_data = templatefile("${path.module}/scripts/user_data_app.sh.tlp", { 
    db_ip = aws_instance.database.private_ip,
    database_name = var.db_name,
    database_user = var.db_user,
    database_password = var.db_password 
  })

  tags = {
    Name = "NodeJs Application Instance"
  }

  # Need to generate the Key before bring up the machine
  depends_on = [aws_key_pair.ssh_key_pair]
}
