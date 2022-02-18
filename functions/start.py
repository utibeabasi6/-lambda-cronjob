#!/bin/env python3
import boto3

client = boto3.client('ec2')

instance_list = client.describe_instances(
    Filters=[
        {"Name": "tag:Patch Group", "Values":["BocBackupProxy"]},
        {"Name": "tag:Stack State", "Values": ["Offline"]}
        ])
instances = [instance["InstanceId"] for instance in instance_list["Reservations"][0]["Instances"]]

def start(_event, _context):
    """
    This function starts up the instances in the instance list
    """
    response = client.start_instances(
    InstanceIds=instances,
    )
    return response
