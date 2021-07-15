# aws-iam-key-rotation
Rotate your IAM keys automatically

Usage: `./aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>`

Run as a cronjob:
`crontab -e`

E.g run every day at 00:00

`0 0 * * * /path/to/script/aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>`
