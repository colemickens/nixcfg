{
  pkgs,
  config,
  lib,
  ...
}:
let
  nixos_ami_x86_uswest2 = "ami-07b76928ebb374b39";
  nixos_ami_a64_uswest2 = "ami-0171c94647389312c";
  pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== cardno:17_928_325";
in
{

  provider.aws.region = "us-west-2";

  # provide ssh key
  resource.aws_key_pair."colemickens" = {
    key_name = "colemickens-yubikey-pubkey";
    public_key = pubkey;
  };

  # security group
  resource.aws_security_group."oz-main-sg" = {
    name = "oz-main-sg";
    vpc_id = "\${resource.aws_vpc.oz-main.id}";
  };
  resource.aws_vpc_security_group_ingress_rule."oz-main-sg-allow-in-ipv4" = {
    security_group_id = "\${resource.aws_security_group.oz-main-sg.id}";
    cidr_ipv4 = "0.0.0.0/0";
    ip_protocol = "tcp";
    from_port = 22;
    to_port = 22;
  };
  resource.aws_vpc_security_group_ingress_rule."oz-main-sg-allow-in-ipv6" = {
    security_group_id = "\${resource.aws_security_group.oz-main-sg.id}";
    cidr_ipv6 = "::/0";
    ip_protocol = "tcp";
    from_port = 22;
    to_port = 22;
  };
  resource.aws_vpc_security_group_egress_rule."oz-main-sg-allow-out-ipv4" = {
    security_group_id = "\${resource.aws_security_group.oz-main-sg.id}";
    cidr_ipv4 = "0.0.0.0/0";
    ip_protocol = -1;
  };
  resource.aws_vpc_security_group_egress_rule."oz-main-sg-allow-out-ipv6" = {
    security_group_id = "\${resource.aws_security_group.oz-main-sg.id}";
    cidr_ipv6 = "::/0";
    ip_protocol = -1;
  };

  # network
  resource.aws_vpc."oz-main" = {
    cidr_block = "172.18.0.0/16";
    tags = {
      Name = "oz-main";
    };
  };

  resource.aws_subnet."oz-subnet1" = {
    vpc_id = "\${resource.aws_vpc.oz-main.id}";
    cidr_block = "172.18.0.0/24";
  };

  resource.aws_internet_gateway."oz-gw" = {
    vpc_id = "\${resource.aws_vpc.oz-main.id}";
  };

  resource.aws_route_table."oz-rt" = {
    vpc_id = "\${resource.aws_vpc.oz-main.id}";
  };

  resource.aws_route."igw-ipv4" = {
    route_table_id = "\${resource.aws_route_table.oz-rt.id}";
    destination_cidr_block = "0.0.0.0/0";
    gateway_id = "\${resource.aws_internet_gateway.oz-gw.id}";
  };
  resource.aws_route."igw-ipv6" = {
    route_table_id = "\${resource.aws_route_table.oz-rt.id}";
    destination_ipv6_cidr_block = "::/0";
    gateway_id = "\${resource.aws_internet_gateway.oz-gw.id}";
  };
  resource.aws_route_table_association."subnet-rt-as" = {
    subnet_id = "\${resource.aws_subnet.oz-subnet1.id}";
    route_table_id = "\${resource.aws_route_table.oz-rt.id}";
  };

  # create machines
  resource.aws_instance."ozex" = {
    subnet_id = "\${resource.aws_subnet.oz-subnet1.id}";
    ami = nixos_ami_x86_uswest2;
    instance_type = "m7i.2xlarge";
    key_name = config.resource.aws_key_pair."colemickens".key_name;

    associate_public_ip_address = true;

    vpc_security_group_ids = [
      "\${resource.aws_security_group.oz-main-sg.id}"
    ];

    root_block_device = {
      encrypted = true;
      volume_size = "256";
      volume_type = "gp3";
    };

    tags = {
      Name = "ozex";
    };
  };
  resource.aws_instance."ozarm" = {
    subnet_id = "\${resource.aws_subnet.oz-subnet1.id}";
    ami = nixos_ami_a64_uswest2;
    instance_type = "m8g.2xlarge";
    key_name = config.resource.aws_key_pair."colemickens".key_name;

    associate_public_ip_address = true;

    vpc_security_group_ids = [
      "\${resource.aws_security_group.oz-main-sg.id}"
    ];

    root_block_device = {
      encrypted = true;
      volume_size = "256";
      volume_type = "gp3";
    };

    tags = {
      Name = "ozarm";
    };
  };
}
