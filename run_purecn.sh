#!/bin/bash
#SBATCH --job-name="purecn"
#SBATCH --cluster=your-cluster
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --account=your-account
#SBATCH --cpus-per-task=16
#SBATCH --mem=258G
#SBATCH --time=3:00:00
#SBATCH --output=/path/to/project/purecn/slurm-%j.out
#SBATCH --error=/path/to/project/purecn/slurm-%j.err
#SBATCH --mail-user=your.email@example.com
#SBATCH --mail-type=ALL

# Java environment (locally installed)
export JAVA_HOME="/path/to/java/jdk-21.0.2"
export PATH="$JAVA_HOME/bin:$PATH"

# Nextflow environment variables
export TMPDIR=/path/to/tmp
export SINGULARITY_LOCALCACHEDIR=/path/to/tmp
export SINGULARITY_CACHEDIR=/path/to/tmp
export SINGULARITY_TMPDIR=/path/to/tmp
export NXF_SINGULARITY_CACHEDIR=/path/to/singularity_cache
export NXF_HOME=/path/to/tmp/.nextflow
export NXF_WORK=/path/to/workdir/purecn

# Container environment variables
export SINGULARITYENV_TMPDIR=/tmp
export APPTAINERENV_TMPDIR=/tmp
export SINGULARITYENV_HOME=/tmp
export APPTAINERENV_HOME=/tmp

# Add your Python virtualenv's bin directory to PATH so tools like samtools, tabix, etc. are available
export PATH="/path/to/python_venv/bin:$PATH"

# Optional: activate the Python virtual environment for Python packages, env vars, and LD_LIBRARY_PATH
source /path/to/python_venv/bin/activate

# Create and set permissions for tmp directories
mkdir -p "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"
chmod 755 "$TMPDIR" "$NXF_SINGULARITY_CACHEDIR"

# Source your Nextflow setup script if needed
source /path/to/setup_nextflow_env.sh

# Verify environment
echo "=== Environment Check ==="
echo "Java version: $(java -version 2>&1 | head -1)"
echo "Nextflow version: $(nextflow -version 2>&1 | grep version)"
echo "=========================="

nextflow run main.nf -resume
