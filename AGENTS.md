# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Repository Overview

Monorepo demonstrating agentic AI workflows for engineering applications, combining real-world datasets with MATLAB/Simulink simulation and cloud infrastructure. Contains two independent sub-projects.

## Tech Stack

- **MATLAB R2025a+** (primary language for both projects)
- **Simulink** + Powertrain Blockset + Vehicle Dynamics Blockset (autocloud vehicle models)
- **Parallel Computing Toolbox** (`parsim`, `parfor`, `batchsim` — same API for local and cloud)
- **AWS S3** for cloud data storage
- **Python 3.12** (secondary, for archive extraction via py7zr in `autocloud/.venv/`)

## Projects

### autocloud/ — Automotive Fleet Data + Virtual Vehicle Simulation

Pipeline: Load fleet driving data (VED, 383 vehicles, 22 weekly CSVs) → extract drive cycles → build virtual EV model (Powertrain Blockset + Virtual Vehicle Composer) → parallel simulation via `parsim` → energy/range analysis.

- **Key files**: `fleet_virtual_vehicle.m` (main orchestration, ~700KB plain-text Live Script), `VED_Analysis.m` (data exploration), `VEDExplorer.m` (interactive GUI), `VED_Fleet_Report.m`
- **Simulink models**: `EVFleetProject/` contains three VirtualVehicle variants (VirtualVehicle, VirtualVehicle1, VirtualVehicle2). Each is a Simulink project with subsystem projects (CI, Driveline, Electrical, Thermal, etc.). `VirtualVehicle2/` is the most complete.
- **Has its own `AGENTS.md`** with S3 access patterns and bucket structure
- **Has a Codex skill** at `.Codex/skills/cloud-based-virtual-vehicle-simulation/` — 5-stage workflow (Build → Configure → Scale → Integrate → Validate)
- **AWS**: S3 bucket `s3://automotivecloud/`, profile name `autocloud`
- **CI/CD**: GitLab Pages deployment (`.gitlab-ci.yml`)
- **No buildtool/test pipeline** — run scripts directly in MATLAB

### nasa-aircraft-big-data/ — NASA Aircraft Sensor Data Engineering

ETL pipeline for NASA Dashlink flight sensor data (~280GB full dataset). This is a **MATLAB project** (`nasa-aircraft-big-data.prj`) — must be opened before running code.

- **Key files**: `Demos/ExtractTransformLoad.mlx` (ETL), `Demos/SearchAndAnalyze.mlx` (analysis), `Demos/exploreFlightData.m` (GUI)
- **Helpers/**: Data transformation utilities (`downloadRawData.m`, `extractCruise.m`, `nested2wide.m`, `returnNested.m`, `tNformat.m`)
- **Tests**: `Tests/SmokeTests.m` (data pipeline validation), `Tests/ProjectIntegrityTests.m` (project structure integrity checks)
- **CI/CD**: GitLab with `check` and `test` stages

## Build & Test Commands (nasa-aircraft-big-data)

The nasa-aircraft-big-data project uses MATLAB's `buildtool` with tasks defined in `buildfile.m`:

```matlab
% First, open the MATLAB project (required — sets paths and dependencies)
openProject('nasa-aircraft-big-data');

% Run static code analysis
buildtool check

% Run all tests (depends on check passing first)
buildtool test

% Run a single test class
runtests('Tests/SmokeTests.m')

% Run a specific test method
runtests('Tests/SmokeTests.m', 'ProcedureName', 'downloadRawDataShouldNotWarn')
```

The `buildtool` pipeline: `check` (CodeIssuesTask — static analysis) → `test` (TestTask — runs all tests in `Tests/`). The `test` task depends on `check`.

**Test data flow**: SmokeTests first downloads raw data to `data/mat/`, then ETL converts it to parquet in `data/parquet_sample/`. Tests run sequentially — later tests assume earlier ones produced data.

## Architecture Pattern

Both projects follow a data-driven simulation pipeline: ingest real-world data → transform → simulate/analyze → visualize. MATLAB Live Scripts (`.m` plain-text format) serve as executable documentation. The `parsim` API enables zero-code-change scaling from local to cloud execution — only the cluster profile changes.

## Working with MATLAB Files

- `.m` files in this repo are primarily **plain-text Live Scripts** (contain `%% ` section breaks and rich-text markers like `%[text]` and `%[output:...]`), not plain functions. Some are very large (e.g., `fleet_virtual_vehicle.m` ~700KB) — use `offset`/`limit` when reading.
- `.mlx` files are **binary** Live Scripts (in nasa-aircraft-big-data) — cannot be read as text
- `.slx` files are Simulink models (binary)
- `.sldd` files are Simulink data dictionaries
- `.prj` files are MATLAB/Simulink project files — open with `openProject()` to set up paths
- Use the MATLAB MCP tools (`evaluate_matlab_code`, `run_matlab_file`, `check_matlab_code`, `run_matlab_test_file`) for execution and analysis
