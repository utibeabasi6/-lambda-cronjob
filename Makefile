up: zip
	@terraform apply --auto-approve

down: 
	@terraform destroy --auto-approve

zip:
	zip -j zips/start_instances.zip functions/start.py 
	zip -j zips/stop_instances.zip functions/stop.py 

init:
	@terraform init