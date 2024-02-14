provider "aws" {
    region = "us-east-1"
    access_key = "ASIAR3AX26EEWSPQWYM2"
    secret_key = "bEep1RmUP403e5Oz7I06xOPB/0JVQUP+qT1vokR2"
    token = "FwoGZXIvYXdzEJD//////////wEaDL4p505xb0mZXzavxiLJAVzts5/n9KlpBPHL4DjTx6ZW4rnGSHzz1hIr3F8y9mgtPkcmtuvQrNQql9I4oWToeqkm11GVX0wu3YL5L+hnN/94PFBmTDH3gkqOVIy26MGieh26TJ/I2FDiwBXdR8W8yKrfw0Yggk+ptbEeoqSenr+12C4vkCB4tnDihlexjVKSkfhYvwymiFEX8rXQtDICX6EODqlg4VvRxO8xGsCMUAnox6lvJIbxItm3gQ8mfjjz0i6Iph7TGMXFrOf7+5wZZ55gk96qSrEf+SiT76auBjItVLBIjeW7IWYShEjEjH4OTZ7Z1ORh0AgD3fwi9OA4gLUHJoZUn1bLTUv3xFpd"
}

# resource "aws_instance" "name" {
#     ami = "ami-0e731c8a588258d0d"
#     instance_type = "t2.micro"
# }


resource "aws_instance" "clouddata" {
  ami           = "ami-0cf10cdf9fcd62d37" 
  instance_type = "t2.micro"
  key_name      = "Mayur_Bonde"
  vpc_security_group_ids = [aws_security_group.main.id]
  # user_data = file("userdata.sh")
}

resource "aws_ebs_volume" "ebsvolume" {
  availability_zone = "us-east-1a"
  size              = 30
}


resource "aws_security_group" "main" {
  name         = "EC2-kaggle"
  
  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port  = 0
    protocol   = "-1"
    to_port    = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
