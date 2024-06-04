"""An AWS Python Pulumi program"""

import pulumi
import json
import pulumi_aws as aws

vpc_on_prem = aws.ec2.Vpc("vpcOnPrem",
    assign_generated_ipv6_cidr_block=False,
    cidr_block="192.168.10.0/24",
    enable_dns_hostnames=True,
    enable_dns_support=True,
    tags={
        "Name": "OnPremVPC",
    })

on_prem_subnet_a = aws.ec2.Subnet("subnetOnPremA",
    vpc_id=vpc_on_prem.id,
    cidr_block="192.168.10.0/25",
    tags={
        "Name": "subnet-onprem-A",
    },
    availability_zone="eu-west-1a")

on_prem_subnet_b = aws.ec2.Subnet("subnetOnPremB",
    vpc_id=vpc_on_prem.id,
    cidr_block="192.168.10.128/25",
    tags={
        "Name": "subnet-onprem-B",
    },
    availability_zone="eu-west-1b")

on_prem_route_table = aws.ec2.RouteTable("routeTableOnPrem",
    vpc_id=vpc_on_prem.id,
    tags={
        "Name": "on-prem-RT",
    })

on_prem_route_table_association_a = aws.ec2.RouteTableAssociation("RTAssociationOnPremA",
    route_table_id=on_prem_route_table.id,
    subnet_id=on_prem_subnet_a.id)

on_prem_route_table_association_b = aws.ec2.RouteTableAssociation("RTAssociationOnPremB",
    route_table_id=on_prem_route_table.id,
    subnet_id=on_prem_subnet_b.id)

onprem_sg = aws.ec2.SecurityGroup("onPremSG",
    name="onprem_sg",
    description="Allow TLS inbound traffic and all outbound traffic",
    vpc_id=vpc_on_prem.id,
    tags={
        "Name": "onprem_sg",
    })

allow_ssh_on_prem = aws.vpc.SecurityGroupIngressRule("allow_ssh_on_prem",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=22,
    ip_protocol="tcp",
    to_port=22)

allow_http_on_prem = aws.vpc.SecurityGroupIngressRule("allow_http_on_prem",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=80,
    ip_protocol="tcp",
    to_port=80)

allow_dns_tcp_on_prem = aws.vpc.SecurityGroupIngressRule("allow_dns_tcp_on_prem",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=53,
    ip_protocol="tcp",
    to_port=53)

allow_dns_udp_on_prem = aws.vpc.SecurityGroupIngressRule("allow_dns_udp_on_prem",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=53,
    ip_protocol="udp",
    to_port=53)

allow_icmp_on_prem = aws.vpc.SecurityGroupIngressRule("allow_icmp_on_prem",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=-1,
    ip_protocol="icmp",
    to_port=-1)

allow_self_on_prem = aws.vpc.SecurityGroupIngressRule("allow_self_on_prem",
    security_group_id=onprem_sg.id,
    referenced_security_group_id=onprem_sg.id,
    from_port=0,
    ip_protocol="tcp",
    to_port=65535)

allow_dns_tcp_on_prem = aws.vpc.SecurityGroupEgressRule("allow_all_outbound",
    security_group_id=onprem_sg.id,
    cidr_ipv4="0.0.0.0/0",
    from_port=-1,
    ip_protocol=-1,
    to_port=-1)


amazon_linux = aws.ec2.get_ami(most_recent=True,
    filters=[
        aws.ec2.GetAmiFilterArgs(
            name="name",
            values=["al2023-ami-*"],
        ),
        aws.ec2.GetAmiFilterArgs(
            name="virtualization-type",
            values=["hvm"],
        ),
    ],
    owners=["amazon"])

ec2_role = aws.iam.Role("ec2_role",
    name="ec2_role",
    assume_role_policy=json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Sid": "",
            "Principal": {
                "Service": "ec2.amazonaws.com",
            },
        }],
    }))

ec2_role_policy = aws.iam.RolePolicy("ec2_role_policy",
    name="ec2_role_policy",
    role=ec2_role.id,
    policy=json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Action": ["ssm:*"],
            "Effect": "Allow",
            "Resource": "*",
        },
        {
            "Action": ["ssmmessages:*"],
            "Effect": "Allow",
            "Resource": "*",
        },
        {
            "Action": ["ec2messages:*"],
            "Effect": "Allow",
            "Resource": "*",
        },
        {
            "Action": ["s3:*"],
            "Effect": "Allow",
            "Resource": "*",
        }
        ],
    }))

ec2_instance_profile = aws.iam.InstanceProfile("ec2_instance_profile",
    name="ec2_instance_profile",
    role=ec2_role.name)

with open('dns_a.sh', 'r') as file:
    user_data_script_a = file.read()

with open('dns_b.sh', 'r') as file:
    user_data_script_b = file.read()

on_prem_dns_a = aws.ec2.Instance("on_prem_dns_a",
    ami=amazon_linux.id,
    instance_type="t2.micro",
    subnet_id=on_prem_subnet_a.id,
    security_groups=[onprem_sg.id],
    user_data=user_data_script_a,
    iam_instance_profile=ec2_instance_profile.name,
    tags={
        "Name": "on_prem_dns_a",
    })

on_prem_dns_b = aws.ec2.Instance("on_prem_dns_b",
    ami=amazon_linux.id,
    instance_type="t2.micro",
    subnet_id=on_prem_subnet_b.id,
    security_groups=[onprem_sg.id],
    user_data=user_data_script_b,
    iam_instance_profile=ec2_instance_profile.name,
    tags={
        "Name": "on_prem_dns_b",
    })

on_prem_app = aws.ec2.Instance("on_prem_app",
    ami=amazon_linux.id,
    instance_type="t2.micro",
    subnet_id=on_prem_subnet_b.id,
    security_groups=[onprem_sg.id],
    iam_instance_profile=ec2_instance_profile.name,
    tags={
        "Name": "on_prem_app",
    })

ssm_endpoint = aws.ec2.VpcEndpoint("ssm_endpoint",
    vpc_id=vpc_on_prem.id,
    subnet_ids=[on_prem_subnet_a.id, on_prem_subnet_b.id],
    service_name="com.amazonaws.eu-west-1.ssm",
    vpc_endpoint_type="Interface",
    security_group_ids=[onprem_sg.id]
    )

ssm_messages_endpoint = aws.ec2.VpcEndpoint("ssm_messages_endpoint",
    vpc_id=vpc_on_prem.id,
    subnet_ids=[on_prem_subnet_a.id, on_prem_subnet_b.id],
    service_name="com.amazonaws.eu-west-1.ssmmessages",
    vpc_endpoint_type="Interface",
    security_group_ids=[onprem_sg.id]
    )

ssm_ec2messages_endpoint = aws.ec2.VpcEndpoint("ssm_ec2messages_endpoint",
    vpc_id=vpc_on_prem.id,
    subnet_ids=[on_prem_subnet_a.id, on_prem_subnet_b.id],
    service_name="com.amazonaws.eu-west-1.ec2messages",
    vpc_endpoint_type="Interface",
    security_group_ids=[onprem_sg.id]
    )

s3_endpoint = aws.ec2.VpcEndpoint("s3_endpoint",
    vpc_id=vpc_on_prem.id,
    service_name="com.amazonaws.eu-west-1.s3",
    route_table_ids=[on_prem_route_table.id]
    )


# Export the name of the vpc
pulumi.export('vpc_on_prem_id', vpc_on_prem.id)
pulumi.export('on_prem_subnet_a_id', on_prem_subnet_a.id)
