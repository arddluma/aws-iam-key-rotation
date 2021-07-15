set -o errexit
cat << "EOF"
      #    #     #    #    # ####### #     #    ######  ####### #######    #    ####### ### ####### #     # 
 #   # #   ##   ##    #   #  #        #   #     #     # #     #    #      # #      #     #  #     # ##    # 
 #  #   #  # # # #    #  #   #         # #      #     # #     #    #     #   #     #     #  #     # # #   # 
 # #     # #  #  #    ###    #####      #       ######  #     #    #    #     #    #     #  #     # #  #  # 
 # ####### #     #    #  #   #          #       #   #   #     #    #    #######    #     #  #     # #   # # 
 # #     # #     #    #   #  #          #       #    #  #     #    #    #     #    #     #  #     # #    ## 
 # #     # #     #    #    # #######    #       #     # #######    #    #     #    #    ### ####### #     # 
                                            by: Ardd
                ~ Usage: ./aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>

EOF
PROFILE=$1
USER_NAME=$2
function main() {
        echo "Profile set:" $PROFILE
        echo "Username set:" $USER_NAME "\n"
        GET_ACCESSKEY_ID=$(aws iam list-access-keys --user-name $USER_NAME  --profile $PROFILE 2>/dev/null | jq -r '.AccessKeyMetadata[].AccessKeyId')
        GET_STATUS=$(aws iam list-access-keys --user-name $USER_NAME --profile $PROFILE 2>/dev/null | jq -r '.AccessKeyMetadata[].Status')
        if [ ! "$GET_ACCESSKEY_ID" ]; then
            echo "ERORR: Profile: $PROFILE or Username: $USER_NAME doesn't exist! "
            exit 0
        else 
            echo "Existing Access KEY(s):" $GET_ACCESSKEY_ID
            echo "Status:" $GET_STATUS "\n"
            CHECK_IF_TWO_KEYS=$(aws iam list-access-keys --user-name $USER_NAME --profile $PROFILE | jq -r '.AccessKeyMetadata[1].AccessKeyId')
            if [[ "$CHECK_IF_TWO_KEYS" != "null" ]]; then
                echo "Found that you are using two KEYs! Removing the oldest one ..."
                GET_OLD_ACCESS_KEY=$(aws iam list-access-keys --user-name $USER_NAME --profile $PROFILE | jq -r '.AccessKeyMetadata[0].AccessKeyId')
                echo "Key that will be deactivated and removed: " $GET_OLD_ACCESS_KEY
                DEACTIVATE_ACCESSKEY=$(aws iam update-access-key --access-key-id $GET_OLD_ACCESS_KEY --status Inactive --profile $PROFILE )
                echo "Access KEY $GET_OLD_ACCESS_KEY deactivated !\n"
                echo "Started process of removing Access KEY $GET_OLD_ACCESS_KEY ... "
                REMOVE_ACCESS_KEY=$(aws iam delete-access-key --access-key-id $GET_OLD_ACCESS_KEY --user-name $USER_NAME --profile $PROFILE )
                echo "Access KEY $GET_OLD_ACCESS_KEY successfully removed! "
            else
                echo "Found that you are using 1 KEY..."
                echo "Creating new Access KEY..."
                CREATE_NEW_KEY=$(aws iam create-access-key --user-name $USER_NAME --profile $PROFILE | jq -r '[.AccessKey.AccessKeyId, .AccessKey.SecretAccessKey]')
                array=($CREATE_NEW_KEY)
                echo "Setting up AWS CLI config in .aws/credentials"
                ACCESS_KEY=$(echo "${array[1]}" | sed 's/"//g' | sed 's/,//g')
                echo "NEW Access KEY generated:" $ACCESS_KEY
                SECRET_ACCESS_KEY=$(echo "${array[2]}" | sed 's/"//g')
                SET_ACCESS_KEY=$(aws configure set aws_access_key_id $ACCESS_KEY --profile $PROFILE)
                SET_SECRETACCESS_KEY=$(aws configure set aws_secret_access_key $SECRET_ACCESS_KEY --profile $PROFILE)
                SET_REGION=$(aws configure set region eu-west-2 --profile $PROFILE)
                echo "AWS CLI configured successfully! yayy"
                removeKey
            fi
        fi
    
}

function removeKey {
        echo "\nVerifying new Access KEY... \nPlease wait..."
        for i in $(seq 1 30); do
            GET_FIRST_ACCESS_KEY=$(aws iam list-access-keys --user-name $USER_NAME  --profile $PROFILE 2>/dev/null | jq -r '.AccessKeyMetadata[0].AccessKeyId')
        done
        echo "Old Access KEY that will be removed:" $GET_FIRST_ACCESS_KEY
        DEACTIVATE_ACCESS_KEY=$(aws iam update-access-key --access-key-id $GET_FIRST_ACCESS_KEY --status Inactive --profile $PROFILE)
        echo "Old Access KEY $GET_FIRST_ACCESS_KEY deactivated !\n"
        echo "Started process of removing the old Access KEY ... "
        REMOVE_ACCESSKEY=$(aws iam delete-access-key --access-key-id $GET_FIRST_ACCESS_KEY --user-name $USER_NAME --profile $PROFILE)
        echo "Access KEY $GET_FIRST_ACCESS_KEY is removed successfully !"
        exit 0
    }

if [[ -n "$1" ]] && [[ -n "$2" ]]; then
    main
else
    echo "Please set your AWS CLI profile and AWS IAM User as parameter !"
    echo "Usage: ./aws-iam-key-rotation.sh <aws-cli-profile> <iam-user-name>"
    exit 0
fi