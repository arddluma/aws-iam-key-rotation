# aws-iam-key-rotation
Rotate your IAM keys automatically

Usage: `./aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>`

Run as a cronjob:
`crontab -e`

**Important:**

Set the SHELL to be `/bin/bash`
`SHELL=/bin/bash`

E.g run every day at 00:00

`0 0 * * * /path/to/script/aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>`

if you want to see the logs of scheduled jobs you can add `>> /path/to/log/file` at the end.

`0 0 * * * /path/to/script/aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name> >> /path/to/log/file`