#!/bin/bash

# Check if start and end indices are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <start_index> <end_index>"
    echo "Example: $0 0 100"
    exit 1
fi

# Validate indices
if [ $1 -lt 0 ] || [ $2 -gt 8191 ] || [ $1 -gt $2 ]; then
    echo "Error: Invalid index range. Must be between 0 and 8191, with start <= end"
    exit 1
fi

# Create output directories for each array task
for i in $(seq $1 $2); do
    mkdir -p "combinatoric_results/${i}_output"
done

echo "Created output directories for tasks $1 to $2" 