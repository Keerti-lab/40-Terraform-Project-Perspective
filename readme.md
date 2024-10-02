# Infrastructure as a Code using Terraform

## Infrastructure

- Not only servers but also security group, IAM, VPC, databases, load balancers, Route53 records etc
- Creating manually creates lot of problems i.e. if something goes wrong, we need to terminate and recreate them once again
- Therefore, we use Infrastructure as a Code (IaaC/IaC)
- Ansible: Configuration as a Code

## Terraform

- Terraform is a popular IaaC tool
- 90% of the companies are using Terraform in their DevOps lifecycle
- Terraform is very crucial for a DevOps Engineer
- It is a Hybrid IaaC i.e. with which we can create resources on many platforms
- Terraform uses declarative syntax for Infrastructure automation
- Terraform scripts are written using Hashicorp Configuration Language (HCL)

### Advantanges

1. **Version Control**: Since Terraform is based on scripting, it should be maintained i.e. the history should be preserved and revert to a previous version if something goes wrong
2. **Consistent Infrastructure**:
    - Usually due to inconsistent infrastructure, we have issues in different environments
    - Therefore, we use same code in different environments
3. **CRUD** operations: We can perform CRUD operations on our infrastructure without logging into console
4. **Inventory Management**: Just by looking at the code, we can say which services and resources are being used for a particular project
5. **Cost Management**: When in need we create and when not, we can delete the resources
6. **Dependency Management**: When we need to create an EC2 instance through AWS console, we need to create a security group first
7. **Modules**: Maintain DRY principle i.e. make use of modules in different projects when ever required
8. **Hybrid Cloud**: Can be integrated with many cloud providers

## Environment setup

1. [Terraform installation](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
2. [AWS CLI v2](https://awscli.amazonaws.com/AWSCLIV2.msi) for authentication with AWS
3. Create a new user on AWS for command line purpose to authenticate with AWS
4. Run `aws configure` command on Terminal and provide the Access Key ID and Secret Key information in that

- Syntax
  
  ```hcl
  resource "what-resource" "name-your-resource-your-wish"{
    arguments / options / parameters
  }
  ```

- what-resource -> you need to get it from terraform documentation
- For a particular resource type, some arguments are mandatory and some are optional
- If we don't provide values to the optional arguments, default values that are in our AWS account will be choosen automatically by Terraform
  - For e.g. at the time of EC2 instance creation, a default security group is assigned if we don't select a security group

## Creation of any resource with Terraform

- **provider** i.e. we need a provide the information of the provider on which we want to create a resource using `provider.tf`

  `provider.tf`

  ```hcl
  terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.16.2"
      }
    }
  }

  provider "aws" {
    # Configuration options
    region = "us-east-1"
  }
  ```

- We can specify aws_access_key_id and aws_secret_access_key information in provider but for security reasons we don't specify it
- **resource** i.e. we need to provide the information about the resource which we would like to create for e.g. an ec2 instance inside `ec2.tf`

  `ec2.tf`

  ```hcl
  resource "aws_instance" "example" {
    ami           = "ami-03265a0778a880afb"
    instance_type = "t2.micro"

    tags = {
      Name="example"
    }
  }
  ```

- Ideally we can have everything in one single .tf file but it would be very difficult to maintain
- Therefore, we split it into seperate files so that we can easily maintain and others can also understand it easily

## Commands to execute

- terraform init --> this will intialize terraform
- terraform plan --> terraform will tell us what are the resources it is going to create
- terraform apply --> it will create the resources
- terraform destroy --> to destroy the resources created by terraform
- Provider SDKs are downloaded at the time of terraform initilisation and are stored in `.terraform` directory
- We shouldn't push the SDK's to GitHub. Therefore we add it to .gitignore file
- **Commenting a code block inside .tf file, indicates to delete that particular resource**

## Variables and Datatypes

### Datatypes

1. string e.g. "hello"
2. number e.g. "203185"
3. bool e.g. true, false
4. list e.g. ["us-east-1a", "us-west-1c"]
5. map e.g. {name = "Mabel", age = 52}

### Variables

- Instead of storing everything in one single file, we split them into multiple files for better readability and code maintainence
- This is where variables comes in handy to store and access data
- type: indicates the data type
- Syntax
  
  ```hcl
  variable "var_name"{
    type    = datatype
    default = "default-value" # can be overriden
  }
  ```

- For e.g. rather than hardcoding the AMI information, we can store inside a variable and refer it where ever we want

  `variables.tf`

  ```hcl
  variable "ami_id"{
    type    = "string"
    default = "ami-03265a0778a880afb"
  }


  variable "instance_type"{
    type    = "string"
    default = "t2.micro"
  }
  ```

  `ec2.tf`

  ```hcl
  resource "aws_instance" "example" {
    ami           = var.ami_id
    instance_type = var.instance_type
  }
  ```

- Similarly if we want to attach a security group to the instance we created, we can create a security group

  `sg.tf`

  ```hcl
  resource "aws_security_group" "allow_all" {
    name        = var.sg_name
    description = "Allowing All ports"

    ingress {
      description      = "Allowing all inbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "tcp"
      cidr_blocks      = var.sg_cidr
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
      Name = "terraform"
    }
  }
  ```

  `variables.tf`

  ```hcl
  variable "sg_name" {
    default = "allow-all"
  }

  variable "sg_cidr" {
    type = list
    default = ["0.0.0.0/0"]
  }
  ```

  `ec2.tf`

  ```hcl
  resource "aws_instance" "example" {
    ami           = var.ami_id
    instance_type = var.instance_type
    security_groups = [ aws_security_group.allow_all.id ]
  }
  ```
  # Infrastructure as a Code using Terraform (continued)

## Tags and Variables

- Tags for resources on AWS are used for resource filtering and cost-optimisation
- These tags are simple but very powerful
- Usually we have the following tags:

  ```text
  Name=some-name
  Environment=DEV/QA/PROD
  Terraform=true
  Component=MongoDB
  Project=Roboshop
  ```

- Rather than hardcoding, we can store them in variables and access them

  `variables.tf`

  ```hcl
  variable "tags" {
    type = map
    default = {
      Name = "MongoDB"
        Environment = "DEV"
        Terraform = "true"
        Project = "Roboshop"
        Component = "MongoDB"
    }
  }
  ```
  
  `ec2.tf`

  ```hcl
  resource "aws_instance" "example" {
    ami           = var.ami_id
    instance_type = var.instance_type
    tags          = var.tags
  }
  ```

## Outputs

- Variables are used for providing inputs
- Similarly, we have outputs for e.g. fetch the public IP of the EC2 instance once its created
- When Terraform creates resource on our behalf on the provider, it will also fetch outputs information
- For each resource there are certain outputs that Terraform fetches
- Syntax

  ```hcl
  output "output-variable-name"{
    value = "value"
  }
  ```

- For e.g.

  `outputs.tf`

  ```hcl
  output "public_ip"{
    value = aws_instance.example.public_ip
  }
  ```

## Conditions

- Syntax: `expression ? "this will run if true" : "this will run if false"`
- For e.g.: if MongoDB we are creating t3.medium otherwise t2.micro
- OR is represented using: `||`
- To enter into terraform console, we can use: `terraform console`

  `ec2.tf`

  ```hcl
  resource "aws_instance" "test" {
    ami                    = var.ami_id
    instance_type          = var.instance_name == "MongoDB" ? "t3.small" : "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow_all_1.id]

    tags = {
      Name = "web"
    }
  }
  ```

  `variables.tf`

  ```hcl
  variable "instance_name" {
    type = string
    default = "web"
  }
  ```

## Loops

- There are 3 types of loops
  - Count and Count index
  - For each
  - Dynamic Block

1. Count and Count index
    - To iterate over a list, we use count.index
    - Example:

    `count.tf`

    ```hcl
    resource "aws_instance" "test" {
      count                  = 11
      ami                    = var.ami_id
      instance_type          = var.instance_type
      vpc_security_group_ids = [aws_security_group.allow_all_1.id]

      tags = {
        Name = var.instance_names[count.index]
      }
    }
    ```

    `vars.tf`

    ```hcl
    variable "instance_names" {
      type = list
      default = ["mongodb", "redis", "rabbitmq", "mysql", "catalogue", "user", "cart", "shipping", "payment", "dispatch", "web"]
    }
    ```

2. For each
    - To iterate over map or list
    - We use each special variable to access the values

    `foreach.tf`

    ```hcl
    resource "aws_instance" "web" {
      for_each      = var.instance_names
      ami           = var.ami_id 
      instance_type = each.value
      tags = {
        Name = each.key
      }
    }
    ```

    `variables.tf`

    ```hcl
    variable "instance_names" {
      type = map
      default = {
        mongodb = "t3.small"
        redis = "t2.micro"
      }
    }

    variable "ami_id" {
      default = "ami-03265a0778a880afb"
    }
    ```

## Functions

- Using file function, we can read and load the data in that file at runtime
- Syntax: `file("${path.module}/hello.txt")`, in this hello.txt should be present in the current working directory

  `count.tf`

  ```hcl
  resource "aws_instance" "web" {
    count         = length(var.instance_names)
    ami           = var.ami_id #devops-practice
    instance_type = contains(["mongodb", "shipping", "mysql"], var.instance_names[count.index]) ? "t3.small" : "t2.micro"
    tags = {
      Name = var.instance_names[count.index]
    }
  }
  ```

  `vars.tf`

  ```hcl
  variable "instance_names" {
    type = list
    default = ["mongodb", "redis", "rabbitmq", "mysql", "catalogue", "user", "cart", "shipping", "payment", "dispatch", "web"]
  }
  ```

## Locals

- locals is also a type of variable, **but it can have expressions and functions**
- They can validate expressions and store its result inside a local variable

  `count.tf`

  ```hcl
  resource "aws_instance" "web" {
    count         = length(var.instance_names)
    ami           = var.ami_id
    instance_type = local.instance_type
    tags = {
      Name = var.instance_names[count.index]
    }
  }
  ```

  `vars.tf`

  ```hcl
  variable "instance_name" {
    type = list
    default = mongodb"
  }
  ```

  `locals.tf`

  ```hcl
  local {
    instance_type = contains(["mongodb", "shipping", "mysql"], var.instance_name) ? "t3.small" : "t2.micro"
  }
  ```

## Data Sources

- With Data Sources, we can query the data dynamically from the provider for e.g. AWS
- We have old resources that created manually on AWS.
- Now we are using terraform to create resources and that have dependency on old resources.
- So using data sources, we can fetch the info dynamically

`data.tf`

```hcl
data "aws_ami" "aws-linux-2"{
  owners           = ["amazon"]
  most_recent      = true

  filter {
      name   = "name"
      values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

# Fetch default VPC information
data "aws_vpc" "default" {
  default = true
}
```

`output.tf`

```hcl
output "aws_ami_id" {
  value = data.aws_ami.aws-linux-2.id
}

output "vpc_info" {
  value = data.aws_vpc.default
}
```

`ec2.tf`

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.aws-linux-2.id
  instance_type = "t2.small"
  tags = {
    Name = "data-source"
  }
}
```

- When a change is made to an existing resource AWS can either terminate it and create a new resource or just stop and restart it to update the resource
- For e.g. when we change the instance type from
  - t2.micro -> t3.medium, in this case AWS just updates the exisiting resource
  - t2.micro -> m4.xlarge, in this case AWS terminates the exisiting resource and creates a new one

  # Terraform: Foreach, Dynamic Blocks, statefile

## For each

- To access provider documentation: terraform.io -> registry -> (provider) -> Documentation
- Both count based or for each based allows us to create more resources
- E.g. To create 10 instances using For-each loop
- When iterating over a map, it gives us each element inside: **each** variable

`foreach/variables.tf`

```hcl
variable "ami_id" {
  type = string # this is the data type
  default = "ami-03265a0778a880afb" # this is the default value
}

variable "instances" {
  type = map
  default = {
    MongoDB = "t3.medium"
    MySQL = "t3.medium"
    Redis = "t2.micro"
    RabbitMQ = "t2.micro"
    Catalogue = "t2.micro"
    User = "t2.micro"
    Cart = "t2.micro"
    Shipping = "t2.micro"
    Payment = "t2.micro"
    Web = "t2.micro"
  }
}

variable "zone_id" {
  default = "Z0308214GYCUYHGJHT8R"
}

variable "domain" {
  default = "joindevops.online"
}
```

`foreach/ec2.tf`

```tf
resource "aws_instance" "roboshop" {
  for_each = var.instances
  ami = var.ami_id
  instance_type = each.value
  tags = {
    Name = each.key
  }
}

# if web, give public IP else you give private IP
resource "aws_route53_record" "www" {
  for_each = aws_instance.roboshop
  zone_id = var.zone_id
  name    = "${each.key}.${var.domain}"
  type    = "A"
  ttl     = 1
  records = [ each.key == "Web" ? each.value.public_ip : each.value.private_ip ]
}

# output "aws_instance_info" {
#   value = aws_instance.roboshop
# }
```

## Dynamic Block

- E.g. Creating Security Group on AWS using Terraform
- In production environment we need to specify which port needs to be opened
- Count and for each based loops are used for creating entire resource itself
- Whereas with Dynamic block, we can include repeatable nested blocks (for e.g. defining multiple ports in the security group) within the **resource definiton**

`foreach/variables.tf`

```hcl
variable "ingress_rules" {
  type = list
  default = [
    {
        from_port = 80
        to_port = 80
        description = "allowing PORT 80 from public"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {
        from_port = 443
        to_port = 443
        description = "allowing PORT 443 from public"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    },
    {
        from_port = 22
        to_port = 22
        description = "allowing PORT 22 from public"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

`foreach/sg.tf`

```tf
resource "aws_security_group" "roboshop" {
  name        = "roboshop"
  description = "Allow HTTP HTTPS SSH"

  dynamic ingress {
    for_each             = var.ingress_rules
    iterator             = abc # here you will get a variable ingress (default)
    
    content {
        description      = abc.value["description"]
        from_port        = abc.value.from_port
        to_port          = abc.value.to_port
        protocol         = abc.value.protocol
        cidr_blocks      = abc.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "roboshop"
  }
}
```

## State file

- Terraform keeps a track of the resources that it created also known as **state** using the **terraform.tfstate** file.
- Therefore terraform's takes the responsibility to ensure that the information in the .tf files and .tfstate file is the same
- When terraform is performing its validations and operations, it creates and applies a lock on terraform.tfstate file called **.terraform.tfstate.lock.info** to avoid editing the tfstate file
- Once the operations are peformed, terraform releases the tfstate file.
- We cannot delete a certain block within the resource rather we should add everything inside the resource itself
- To avoid unneccessary edits to the file from multiple sources, we add the tfstate files to the gitignore
- In addition there is a possiblity for creating duplicate infrastructure if the track of tfstate file is lost
- To do so, we store the tfstate file in a remote location such as S3 with DynamoDB and apply lock (LockID) to it rather than storing it locally

`foreach/provider.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.15.0"
    }
  }

  backend "s3" {
    bucket         = "learninguser"
    key            = "tfstate_lock"
    region         = "us-east-1"
    dynamodb_table = "terraform_lock"
  }
}
```

- We should run `terraform init -reconfigure` to configure the S3 to store the remote state file

# Terraform: tfvars, Multienvironment, intro to modules

## tfvars

- To maintain consistency across multi ENV, we can use same code but with different variables
- For e.g.:
  - We need 10 instances in DEV and 10 instances in PROD
  - Route53 records for DEV and PROD
  - For e.g. mongodb-dev.learninguser.online for dev and mongodb-prod.learninguser.online
- Values mentioned in `variables.tf` are default values which can always be overwritten using `terraform.tfvars` which will be loaded automatically
- But it is not mandatory to define default values
- We create separate .tfvars file for DEV and PROD for e.g. dev.tfvars, prod.tfvars
- This information can be passed onto terraform using: `terraform plan -var-file=DEV/dev.tfvars`
- Usually in PROD, we expect huge traffic and therefore, we choose larger instance tyes
- If a variable is defined but is not initialised with a default value anywhere in the .tfvars or variables.tf, terraform prompts the user to enter a value at the time of planning or applying
- Once the dev instances are created and after that if we want to create the PROD infrastructure, terrform always replaces the DEV infra and with the PROD infra using the current approach as we are saving the remote state with the same name in S3

## Multi Environment

### Approach 1: Different repos

- Maintain different repos i.e. roboshop-DEV and roboshop-PROD
- But the disadvantage with this approach is that, the code is duplicated and we need to work with different repos
- Preferred for projects with larger infrastructure such as Banking

### Approach 2: Using tfvars

- When using the same code snippets for different envrionments, we need to have different tfvars file and remote state location i.e. s3 bucket
- The remote state file location information can be specified by defining `backend.tf` file for each environment
- We can initialise it at the time of dev environment using `terraform init -reconfigure -backend-config=DEV/backend.tf`, `terraform plan -var-file=DEV/dev.tfvars`, , `terraform destroy -var-file=DEV/dev.tfvars` and when using the same script for production, we should reconfigure using: `terraform init -reconfigure -backend-config=PROD/backend.tf`, `terraform plan -var-file=PROD/prod.tfvars`, `terraform destroy -var-file=PROD/prod.tfvars`
- If we use the same statefile for different environments, Terraform deletes the resources and creates new resources for that environment
- This is because Terraform tries to validate the Terraform scripts with remote tfstate file
- Preferred for projects with smaller infrastructure

### Approach 3: Terraform workspaces

- Terraform Workspace: Using this, we can use single code to manage multiple environments
- To get the list of workspaces: `terraform workspace list`
- By default, terraform creates a **default** workspace
- Only some backends are supported by workspaces
- To create a workspace, we can use: `terraform workspace new <name of the workspace>`
- By default, terraform provides a variable called: `terraform.workspace`
- Workspace also creates different buckets based on the environment in the Remote backend such as S3
- To switch between workspaces, we can run: `terraform workspace select dev`

## Provisioners

- There are useful to integrate with configuration management tools such as Ansible
- The main input for configuration management is that, the server should be up and running
- As Ansible doesn't maintain the state of the infrastructure it created, it is intended for infrastructure creation
- There are 2 types of provisioners
  1. local-exec: The code block will run in the machine where terraform command is executed
      - Works only once
      - Creation Time: local-exec will run at the time of server creation
      - Destroy time: local-exec will be destroyed at the time of server termination `when = destroy`
      - on_failure: Handling errors for e.g. continue the execution of the rest blocks `on_failure = continue`

      `ec2.tf`

      ```hcl
      resource "aws_instance" "example" {
        ami           = "ami-03265a0778a880afb"
        instance_type = "t2.micro"

        tags = {
          "Name" = "test"
        }

        provisioner "local-exec" {
          # self = aws_instance.example
          command = "echo The server's IP address is ${self.private_ip}"
        }
      }
      ```

  2. remote-exec
      - This will run inside the server
      - To run, we should first connect to the server only then we can run something on the server

      `ec2.tf`

      ```hcl
      resource "aws_instance" "example" {
        ami           = "ami-03265a0778a880afb"
        instance_type = "t2.micro"
        vpc_security_group_ids = [aws_security_group.roboshop-all.id]

        tags = {
          "Name" = "test"
        }

        connection {
          type = "ssh"
          user = "centos"
          password = "DevOps321"
          host = self.public_ip
        }

        provisioner "remote-exec" {
          inline = [
            "sudo yum install nginx -y",
            "sudo systemctl start nginx",
          ]
        }
      }
      ```

      `sg,tf`

      ```hcl
      resource "aws_security_group" "roboshop-all" {
        name        = "provisoner"
        description = "provisoner"

        ingress {
          description      = "Allow SSH"
          from_port        = 22
          to_port          = 22 
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
        }

        ingress {
          description      = "Allow HTTP"
          from_port        = 80
          to_port          = 80 
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
        }
        
        egress {
          from_port        = 0
          to_port          = 0
          protocol         = "-1"
          cidr_blocks      = ["0.0.0.0/0"]
        }

        tags = {
            Name = "provisoner"
        }
      }
      ```

## Modules

- Using modules, we can maintain DRY principle
- We can reuse it when ever we want
# Terraform VPC

## Modules

- When defining the module, **provider** information is not necessary
- Only when consuming the module, we need to provide this information

## VPC

- Virtual Private Cloud
- IPv4 Address --> 32 bits --> 4 octets --> each octet consists of 8 bits
- In binary system if you have n bits, you can generate 2^n combinations
- 32 bits --> 2^32 --> 4.3 billion
- All the devices that are connected to the Modem are assigned with Private IP address where as a modem is assigned with both Public and Private IP
- If the communication is going outside of the network, then it uses Public IP address and this is called as NAT (Network Address Translation)
- Ideally every network is isolated and it can contain any number of devices connected to it
- If we select 1 bit out of 2 bits, then how many parts can I divide the entire network? Ans: 2
- If we have k bits and out of this if we select n bits, we can have
  - parts = 2^n
  - each part contains --> 2^n - 1
- For e.g. Total number of bits, we have is 3 (i.e. k = 3). Out of which we select 2 bits (n = 2)
  - This means, we can have 2 ^ 2 = 4 parts and each part consists of 2^(k - n) = 2^(3 - 2) = 2
- CIDR: Classless Inter Domain Routing
- An IP address is a combination of Network ID + Host ID

### Private IP ranges

1. 10.0.0.0 to 10.255.255.255 (10.0.0.0/8)
2. 172.16.0.0 to 172.31.255.255 (172.16.0.0/12)
3. 192.168.0.0 to 192.168.255.255 (192.168.0.0/16)

- Lets consider a CIDR block: 10.0.0.0/8
  - In this the first 8 bits are reserved for Network, remaining 24 bits are for Host
  - Network bits are not allowed to use
- Our task is to split this CIDR block into 2 parts, therefore we need 1 extra bit
- The 1st subnet will be: 10.0.0.0/9 i.e. 10.0.0.0 - 10.127.255.255
- The 2nd subnet will be: 10.128.0.0/9 i.e. 10.128.0.0 - 10.255.255.255
- AWS will only allow 16 - 28 as CIDR notation
- By default, every subnet has its route table set to local i.e. all the devices within the subnet can communicate with each other
- We have 2 types of routes:
  - Public Route
  - Private Route
- A route table consists of routes listed in it
- Each route table should be associated with atleast one subnet
- For e.g. Public Route table is assocated with public subnet

# Terraform: VPC module development


- Agenda: Develop VPC module with High availability, so that anyone in our organisation can use this.
- High Availability can be acheived by creating resources in more than 1 AZ

## VPC Module structure

1. IGW and attach to vpc
2. 2 public subnets --> 1 in 1a, 1 in 1b
3. 2 private subnets --> 1 in 1a, 1 in 1b
4. 2 database subnets --> 1 in 1a, 1 in 1b
5. Group our database subnets
6. Create route table for public
7. Create route table for private
8. Create route table for database
9. Route table and subnet associations
10. NAT gateway

- We create 2 separate repositories i.e. one for VPC module and another one for roboshop infra consuming the VPC module

## Terraform naming best practices

- Ref: [Terraform Naming conventions](https://www.terraform-best-practices.com/naming)

1. Use _ (underscore) instead of - (dash) everywhere (in resource names, data source names, variable names, outputs, etc).
2. Prefer to use lowercase letters and numbers
3. If the resource module creates a single resource of this type (eg, in AWS VPC module there is a single resource of type aws_nat_gateway and multiple resources of typeaws_route_table, so aws_nat_gateway should be named this and aws_route_table should have more descriptive names - like private, public, database)

## Developing VPC module

- When developing VPC module, we need to enable DNS Hostnames and DNS support by setting its value to true
- Usually, its the cloud central teams responsibility to develop modules and DevOps engineers to consume it in their projects
- We can merge two map objects using: `merge()` function
- Using module we can acheive the following functionality:
  1. Code reuse
  2. Enforce some best practices and standards according to the company
- We can create our own modules or use Open-source moduels for our project

# Terraform VPC module enhancement


- We usually have 2 roles i.e. Module Developer and Module user

## Module Developer

- Resource creation/definitions are here
- Variables are must, because diff projects have diff requirements
- data sources, locals, functions to perform certain tasks
- Module developer has to give documentation about the list of inputs and outputs because outputs are used to create other resources such as security group as it needs VPC ID

## Module User

- User should provide values to the variables defined in the module as per the documentation

## Certain enhancements

- Restrict user to create resources in 1a and 1b region only even if he specifies any other regions as values to the variables
- Should only accept 2 public/private/database subnets. If more specifed, throw an error
- Get the project name from the user so that we can some naming convention:
  - `<project-name>-public-<az>`
  - `<project-name>-private-<az>`
  - `<project-name>-database-<az>`
- Values for variables can always be overwritten by user where as the local values cannot be overwritten
- Incoming request is called **Ingress**
- NAT gateway only allows outgoing connections and will not allow any incoming connections
- We can use a module that is published to github using:

  ```hcl
  module "roboshop" {
    source = "git::https://github.com/daws-76s/terraform-aws-vpc.git?ref=main"
  }
  ```

- Once any change is made to the module, they need to pushed to the remote location and need to be fetched by user using: ``terraform init -upgrade` command
- pull = fetch + merge

# Terraform continued: VPN and VPC

## Concepts

1. Variables
2. Data Types
3. Conditions
4. Loops
5. Functions
6. Count and Count Index
7. Outputs
8. Data Sources
9. Locals

- Using these concepts, we understand the service and provision it using Terraform
- Without having the knowledge on how service works, its not possible to provision it using Terraform even though we can fetch it from the documentation

## Securing Roboshop

- VPC is the base for any project either in cloud or on-premise
- Its a general concept and not specific to AWS
- Within VPC, we should have network security
- Therefore we have:
  - public and private subnets
  - public and private route tables
  - Internet gateway
  - NAT gateway as a route to private subnet
    - Ingress is not allowed
    - Egress traffic is always through NAT
  - Route table associations with subnets
- We have created a VPC for our Roboshop project
- We have a Default VPC configured with our AWS account with a Default Public Subnet
- With in the Default VPC, we will create an EC2 instance and install a VPN software in it
- As a user, we should connect to the Roboshop component servers through VPN only

### How can we establish peering between two VPCs?

- We establish a VPC peering connection between Default and Roboshop VPC
  - Requestor: Default VPC
  - Acceptor: Roboshop VPC
- In Default VPC route table, we should have an entry for Roboshop CIDR and in Roboshop VPC, we should have Default VPC CIDR in order to enable VPC peering between both these VPCs.
- Usually there are several teams that manage the e-commerce application. For e.g.:
  - VPC is handled by Networking team and stores the values in the AWS SSM parameter store
  - VPN team will access and store the parameters to the same central place
  - Similarly other teams also perform the same action
- Each team will only provide a document with the information on how to use it as it is not necessary to understand all the details such as AMI, versions they're using etc
- They should be able to receive and process the requests and return response to them
- Terraform has access to the current folder only. It cannot fetch values from different projects
- When we have a big infrastructure, parsing of tf files and refreshing takes lot of time if we maintain it in a single repo
- If we maintain it in a different repo, the read operations will be much faster
- As a module developer, we are setting the is_vpc_peering_required to false by default

## Connecting to instances in private subnet

- There are two ways in which we can acheive this
- Method 1: Using Jump/Bastion host
- Method 2: Using VPN
- For e.g. when we want to connect to MongoDB instance that is in database subnet, we need to first add the route in MongoDB security group to accept connections from VPN
- Installation using scripts: [Source](https://github.com/angristan/openvpn-install)