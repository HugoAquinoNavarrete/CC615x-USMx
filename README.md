# CC615x-USMx - Cloud Computing Infrastructure

Script on Terraform to use IaC concepts to automate the deploy BallotOnline web site migration

## 1. Configure AWS (this script runs on us-west-2 region)
Before execute this script, execute `aws configure` in order to enable
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name 
   - Default output format (json,yaml,yaml-stream,text,table)

## 2. Generate a key pair rsa public/private
   ```bash 
   ssh-keygen
   ```
   Save them on the directory where you will run this script `<absolute_path>/cc615-key-iac.pem`, left empty `passphrase`

## 3. To connect through SSH to the VM (validate that in your Security Group you have enabled ingress permission to SSH - port TCP 22)
   ```bash
   ssh -v -l ubuntu -i cc615-key-iac.pem <public_ip_ec2_instance>
   ```

## 4. Script compatible with Terraform version v0.11.3, these are the steps to download and install
   ```bash
  wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
  unzip terraform_0.13.3_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version 
   ```

## 5. To execute the script type `terraform apply -var "minimum=<minumum_instances>" -var "maximum=<maximum_instances>"` when the following message appears, answer writing `yes`:
   ```bash
   Do you want to perform these actions?
     Terraform will perform the actions described above.
     Only 'yes' will be accepted to approve.

     Enter a value:
   ```

The script after beeing executed will generate a message like this:

   ```bash
   Apply complete! Resources: <amount> added, 0 changed, 0 destroyed.
   ```

## 6. To validate that the Load Balancer is responding, on the screen some Outputs variables will be displayed, find `elb_dns_name` and type:
   ```bash
   curl <load_balancer_name>
   ```

## 7. To eliminate the infrastructure created type `terraform destroy` when the follwing message appears, answer writing `yes`:
   ```bash
   Do you really want to destroy?
     Terraform will destroy all your managed infrastructure, as shown above.
     There is no undo. Only 'yes' will be accepted to confirm.

     Enter a value:
   ```

The script after beeing executed will generate a message like this:

   ```bash
   Destroy complete! Resources: <amount> destroyed.
   ```

## 8. Validate on AWS portal that the resources were eliminated
EC2 instances must appear with `Terminated` state and some minutes later will disappear
