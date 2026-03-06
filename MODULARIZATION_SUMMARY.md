# PureCN Pipeline Modularization Summary

## Overview
The monolithic `PURECN` process has been refactored into three separate, modular processes for better maintainability, testability, and reusability.

## New Modular Structure

### 1. PURECN_PREPARE (`modules/purecn_prepare.nf`)
**Purpose**: Environment setup and configuration preparation

**Inputs**:
- `val sample_id`: Sample identifier

**Outputs**:
- `tuple val(sample_id), stdout`: Sample ID and PureCN installation path

**Function**: Determines the PureCN installation path dynamically from the R package system, making the pipeline portable across different container environments.

### 2. PURECN_RUN (`modules/purecn_run.nf`)
**Purpose**: Main PureCN analysis execution

**Inputs**:
- `val sample_id`: Sample identifier
- `val purecn_path`: PureCN installation path (from PURECN_PREPARE)
- `path seg`: Segmentation file (from CNS_TO_SEG)
- `path snp_blacklist`: SNP blacklist BED file
- `path tumor_cnr`: Tumor coverage file
- `path vcf`: Variant call file

**Outputs**:
- `tuple val(sample_id), path("${sample_id}_purecn_output")`: Complete PureCN output directory

**Function**: Executes the main PureCN.R script with all necessary parameters and generates comprehensive analysis results.

### 3. PURECN_PARSE_RESULTS (`modules/purecn_parse_results.nf`)
**Purpose**: Results parsing and summary generation

**Inputs**:
- `tuple val(sample_id), path(purecn_output_dir)`: Sample ID and PureCN output directory

**Outputs**:
- `tuple val(sample_id), path("${sample_id}_summary.txt")`: Human-readable summary
- `tuple val(sample_id), path(purecn_output_dir)`: Full results directory (pass-through)

**Function**: Extracts key metrics (purity, ploidy, sex, contamination, QC flags) from PureCN results and creates a concise summary file.

## Workflow Flow

```
ch_samplesheet
    │
    ├──► CNS_TO_SEG ──────────────┐
    │                              │
    └──► PURECN_PREPARE ──────┐   │
                              │   │
                              ▼   ▼
                         PURECN_RUN
                              │
                              ▼
                    PURECN_PARSE_RESULTS
```

## Benefits of Modularization

### 1. **Improved Testability**
- Each module can be tested independently
- Easier to write targeted nf-tests for specific components
- Stub implementations are simpler and more focused

### 2. **Better Maintainability**
- Clear separation of concerns
- Easier to identify and fix issues in specific stages
- Simpler code review process

### 3. **Enhanced Reusability**
- Individual modules can be imported into other pipelines
- PURECN_PREPARE can be reused for any PureCN-based workflow
- PURECN_PARSE_RESULTS can be extended or replaced with custom parsers

### 4. **Flexible Workflow Design**
- Easy to add parallel processing steps
- Simple to insert additional QC or validation steps between modules
- Straightforward to implement conditional execution logic

### 5. **Clearer Data Flow**
- Explicit inputs and outputs for each step
- Better documentation of data dependencies
- Easier to understand the overall pipeline logic

## Migration Notes

The original monolithic `PURECN` process has been preserved as `modules/purecn_monolithic.nf.backup` for reference. 

### Changes in main.nf:
- Updated includes to reference new modular processes
- Modified workflow to chain processes with explicit data flow
- Added step-by-step comments for clarity

### Test Data:
- Created `tests/data/samplesheet.csv` for test profile support
- Verified with stub run mode

## Future Enhancement Opportunities

With this modular structure, you can easily:

1. **Add QC modules**: Insert quality control checks between steps
2. **Parallel processing**: Run PURECN_PREPARE once and reuse for multiple samples
3. **Custom analysis**: Replace PURECN_PARSE_RESULTS with domain-specific parsers
4. **Checkpointing**: Add resume capabilities at specific module boundaries
5. **Multi-step validation**: Insert validation processes between each major step

## Testing

Verified with stub run:
```bash
nextflow run main.nf -profile test -stub-run
```

All processes execute successfully with proper data flow and output generation.
