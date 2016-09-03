#/bin/bash
# Ask the user for any required variables, export them,
# then run packer and terraform.

askvar(){
  read -rp "${1}: " a
  echo "$a"
}

# Voodoo magic is happening right there!
# (Default variable value is a bash function asking the user for the value)

export TF_VAR_aws_access_key=${aws_access_key:-$(askvar aws_access_key)}
export TF_VAR_aws_secret_key=${aws_secret_key:-$(askvar aws_secret_key)}
export TF_VAR_aws_region=${aws_region:-$(askvar aws_region)}
export TF_VAR_aws_ssh_key=${aws_ssh_key:-$(askvar aws_ssh_key)}
export TF_VAR_lb_auth_token=${lb_auth_token:-$(askvar lb_auth_token)}
export TF_VAR_zone=${zone:-$(askvar zone)}
export TF_VAR_zone_id=${zone_id:-$(askvar zone_id)}

echo "running $@"
make $@
