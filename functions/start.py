import boto3

client = boto3.client('ec2')

instance_list = client.describe_instances(Filters=[{"Name": "tag:Patch Group", "Values":["BocBackupProxy"]}, {"Name": "tag:Stack State", "Values": ["Offline"]}])
instances = [instance["InstanceId"] for instance in instance_list["Reservations"][0]["Instances"]]

def start(event, context):
    response = client.start_instances(
    InstanceIds=instances,
    )
    return response