#!/bin/bash

# Set the AWS region
REGION="ap-northeast-1"
# Log retention period in days
RETENTION_DAYS=1
# Flag to track log group creation success
ALL_LOG_GROUPS_CREATED=true

# List of CloudWatch Logs log groups and corresponding log streams
declare -A LOG_GROUPS_AND_STREAMS=(
  ["/aws/nginx-bff-srv01/access-log"]="nginx-bff-srv01-access"
  ["/aws/nginx-bff-srv01/error-log"]="nginx-bff-srv01-error"
  ["/aws/nginx-bff-srv02/access-log"]="nginx-bff-srv02-access"
  ["/aws/nginx-bff-srv02/error-log"]="nginx-bff-srv02-error"
  ["/aws/docker/log"]="docker-log"
)

# Create log groups and set retention period to 1 day
{
  for LOG_GROUP in "${!LOG_GROUPS_AND_STREAMS[@]}"; do
    echo "Creating CloudWatch Logs group: $LOG_GROUP"
    
    # Create log group (only if it doesn't exist)
    if aws logs create-log-group --log-group-name "$LOG_GROUP" --region "$REGION" 2>/dev/null; then
      echo "Log group $LOG_GROUP created successfully."
    else
      echo "Log group $LOG_GROUP already exists or an error occurred."
    fi

    # Set retention period to 1 day
    echo "Setting retention policy to $RETENTION_DAYS days for $LOG_GROUP"
    if aws logs put-retention-policy --log-group-name "$LOG_GROUP" --retention-in-days "$RETENTION_DAYS" --region "$REGION"; then
      echo "Retention policy set to $RETENTION_DAYS days for $LOG_GROUP."
    else
      echo "Failed to set retention policy for $LOG_GROUP."
      ALL_LOG_GROUPS_CREATED=false
    fi

    # Create log stream
    LOG_STREAM="${LOG_GROUPS_AND_STREAMS[$LOG_GROUP]}"
    echo "Creating log stream: $LOG_STREAM in group: $LOG_GROUP"
    if aws logs create-log-stream --log-group-name "$LOG_GROUP" --log-stream-name "$LOG_STREAM" --region "$REGION" 2>/dev/null; then
      echo "Log stream $LOG_STREAM created successfully."
    else
      echo "Log stream $LOG_STREAM already exists or an error occurred."
    fi

    # Verify log stream creation
    echo "Verifying log stream: $LOG_STREAM in group: $LOG_GROUP"
    if aws logs describe-log-streams --log-group-name "$LOG_GROUP" --log-stream-name-prefix "$LOG_STREAM" --region "$REGION" | grep -q "$LOG_STREAM"; then
      echo "Log stream $LOG_STREAM exists in group: $LOG_GROUP."
    else
      echo "Log stream $LOG_STREAM does not exist in group: $LOG_GROUP."
    fi
  done

  # Check if all log groups were created and retention policies set successfully
  if [ "$ALL_LOG_GROUPS_CREATED" = true ]; then
    echo "All log groups created and retention policies set successfully."
  else
    echo "Failed to create some log groups or set retention policies."
    exit 1
  fi
} > log_group_creation_output.log 2>&1

