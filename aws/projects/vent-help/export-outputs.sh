#!/bin/bash
set -e

# Default output file
OUTPUT_FILE="${1:-../../vent.help/.env.generated}"

# Ensure we are in the right directory
if [ ! -f "main.tf" ]; then
  echo "Error: Run this script from the Terraform project directory (where main.tf is located)."
  exit 1
fi

# Get outputs as JSON
echo "Exporting Terraform outputs to $OUTPUT_FILE ..."
TF_OUTPUT=$(terraform output -json)

# Parse and write to .env format
{
  echo "# Generated from Terraform outputs on $(date)"
  echo
  echo "$TF_OUTPUT" | jq -r 'to_entries[] | select(.value.value != null) | "[0m" + (.key | ascii_upcase) + "=" + (if (.value.sensitive == true) then "<sensitive>" else (.value.value|tostring) end)'
} > "$OUTPUT_FILE"

# Print summary
echo "\nExported the following variables to $OUTPUT_FILE:"
echo "$TF_OUTPUT" | jq -r 'to_entries[] | select(.value.value != null) | (.key | ascii_upcase)'

echo "\nDone. Review and copy these values into your main vent.help app's .env if needed." 