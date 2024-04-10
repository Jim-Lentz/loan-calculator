# loan-calculator

# Testing dev  


Sample three tier application in Azure


to run dev you will want to create a branch called dev
git branch dev
git checkout dev

make your changes then
git add .
git commit -m "Your commit message"

git push -u origin dev

This will run the GitHub Actions on the Dev environment.
Once you have confirmed that these changes are good then
git checkout main
git merge dev
git push origin main

terraform init -backend-config=key=prod-terraform.tfstate
terraform plan -var-file="./prod.tfvars"
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -var-file="./prod.tfvars" -auto-approve
