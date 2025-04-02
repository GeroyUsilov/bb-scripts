#!/bin/bash
#SBATCH --job-name=chunk_manager
#SBATCH --output=chunk_manager_%j.out
#SBATCH --error=chunk_manager_%j.err
#SBATCH --time=35:00:00  # Adjust as needed
#SBATCH --mem=1G

# Define all ranges
ranges=("5114-5119" "5120-5183" "5184-5247" "5248-5311" "5312-5375" "5376-5439" "5440-5503" "5504-5567" "5568-5631" "5632-5695" "5696-5759" "5760-5823" "5824-5887" "5888-5951" "5952-6015" "6016-6079" "6080-6143" "6144-6207" "6208-6271" "6272-6335" "6336-6399" "6400-6463" "6464-6527" "6528-6591" "6592-6655" "6656-6719" "6720-6783" "6784-6847" "6848-6911" "6912-6975" "6976-7039" "7040-7103" "7104-7167" "7168-7231" "7232-7295" "7296-7359" "7360-7423" "7424-7487" "7488-7551" "7552-7615" "7616-7679" "7680-7743" "7744-7807" "7808-7871" "7872-7935" "7936-7999" "8000-8063" "8064-8127" "8128-8191")


# Create a temporary file to store chunk information
CHUNK_FILE=$(mktemp)
CURRENT_CHUNK=0
CHUNK_SIZE=7
CURRENT_JOB=$SLURM_JOB_ID

# Function to get the current state
get_state() {
    if [ -f "chunk_state.txt" ]; then
        cat "chunk_state.txt"
    else
        echo "0"  # Start with the first chunk if no state file exists
    fi
}

# Function to save the current state
save_state() {
    echo "$1" > "chunk_state.txt"
}

# Function to check if there are other jobs running
check_other_jobs() {
    # Get all running jobs for current user
    running_jobs=$(squeue -u $USER -h -o "%i")
    
    # Count jobs (excluding this one)
    other_jobs=0
    for job in $running_jobs; do
        if [ "$job" != "$CURRENT_JOB" ]; then
            other_jobs=$((other_jobs + 1))
        fi
    done
    
    echo "Found $other_jobs other running jobs"
    return $other_jobs
}

# Function to submit a chunk of jobs
submit_chunk() {
    local chunk_num=$1
    local start_idx=$((chunk_num * CHUNK_SIZE))
    local end_idx=$((start_idx + CHUNK_SIZE - 1))
    
    # Check if we've reached the end of the array
    if [ $start_idx -ge ${#ranges[@]} ]; then
        echo "All chunks have been processed. Exiting."
        return 1
    fi
    
    # Adjust end_idx if it exceeds array size
    if [ $end_idx -ge ${#ranges[@]} ]; then
        end_idx=$((${#ranges[@]} - 1))
    fi
    
    echo "Submitting chunk $chunk_num (indexes $start_idx to $end_idx)"
    
    # Submit each job in the chunk
    for i in $(seq $start_idx $end_idx); do
        range=${ranges[$i]}
        echo "Submitting job with array range: $range"
        sbatch --array=$range scripts/array_task.sbatch
    done
    
    # Save the next chunk number
    save_state $((chunk_num + 1))
    return 0
}

# Main loop
while true; do
    # Get the current chunk
    CURRENT_CHUNK=$(get_state)
    
    # Check if there are other jobs running (besides this script)
    check_other_jobs
    job_count=$?
    
    if [ $job_count -eq 0 ]; then
        echo "No other jobs running, submitting next chunk..."
        
        # Submit the next chunk
        submit_chunk $CURRENT_CHUNK
        
        if [ $? -ne 0 ]; then
            echo "No more chunks to process. Exiting."
            break
        fi
        
        echo "Chunk submitted, waiting for jobs to start..."
        sleep 60
    else
        echo "Other jobs are still running. Waiting before checking again..."
    fi
    
    # Wait before checking again (5 minutes)
    sleep 300
done

echo "All chunks processed successfully"
rm -f $CHUNK_FILE