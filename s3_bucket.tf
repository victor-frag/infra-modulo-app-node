# Creating a S3 Bucket resource to store the application and the ansible scripts
resource "aws_s3_bucket" "repository_bucket" {
  bucket = "repofinalwork"
  acl = "private"

  tags = {
    Name = "Repository"
  }
}

# Creating a Bucket Object to upload the ansible script
resource "aws_s3_bucket_object" "bucket_object_ansible_upload" {
  # Repository Bucket reference
  bucket = aws_s3_bucket.repository_bucket.bucket

  # The name of the object once is in the Bucket
  key = "ansible/ansible.zip"

  # The path to a file that will be read and uploaded as raw bytes for the object content.
  source = "${path.module}/ansible/ansible.zip"

  acl = "private"

  tags = {
      Name = "Bucket Object Ansible"
  }
}

# Creating a Bucket Object to upload the application
resource "aws_s3_bucket_object" "bucket_object_application_upload" {
  # Repository Bucket reference
  bucket = aws_s3_bucket.repository_bucket.bucket

  # The name of the object once is in the Bucket
  key = "node_app/node-js-getting-started.zip"

  # The path to a file that will be read and uploaded as raw bytes for the object content.
  source = data.archive_file.compress_source.output_path

  acl = "private"

  tags = {
      Name = "Bucket Object Node Application"
  }
}

# Creating IAM Role
resource "aws_iam_role" "ec2_s3_iam_access_role" {
  name = "allow-sts-assume-role"

  # The policy that grants an entity permission to assume the role
  assume_role_policy = file("${path.module}/policies/allow_sts_assume_role_policy.json")

  tags = {
      Name = "IAM Role EC2 to S3"
  }
}

# Creating Policy
resource "aws_iam_policy" "s3_iam_policy" {
  name = "allow-s3-policy"
  description = "Policy to allow access to S3"

  # The policy document
  policy = file("${path.module}/policies/allow_s3_policy.json")
}

# Attaches a Managed IAM Policy to the IAM Role
resource "aws_iam_policy_attachment" "policy-attach" {
  name = "attachment-of-policy-and-iam-role"

  # IAM Role reference
  roles = [aws_iam_role.ec2_s3_iam_access_role.name]

  # Policy reference
  policy_arn = aws_iam_policy.s3_iam_policy.arn
}

# IAM Instance profile
resource "aws_iam_instance_profile" "s3_instance_profile" {
  name  = "s3_instance_profile"

  # IAM Role reference
  role = aws_iam_role.ec2_s3_iam_access_role.name
}
