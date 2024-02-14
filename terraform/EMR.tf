resource "aws_emr_cluster" "cluster" {
  name          = "emr-test-arn"
  release_label = "emr-6.15.0"
  applications  = ["Spark"]

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true

  ec2_attributes {
    emr_managed_master_security_group = aws_security_group.main.id
    emr_managed_slave_security_group  = aws_security_group.main.id
    instance_profile                  = aws_iam_instance_profile.mayur_instance.role
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  ebs_root_volume_size = 15

  tags = {
    role = "rolename"
    env  = "env"
  }

  service_role = "arn:aws:iam::126751535369:role/EMR_DefaultRole"
}


resource "aws_iam_instance_profile" "mayur_instance" {
  name = "Second_EMR"
  role = "EMR_EC2_DefaultRole"
}
