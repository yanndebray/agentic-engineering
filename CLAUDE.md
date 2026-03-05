# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Monorepo demonstrating agentic AI workflows for engineering applications, combining real-world datasets with MATLAB/Simulink simulation and cloud infrastructure. Contains two independent sub-projects.

## Projects

### autocloud/ — Automotive Fleet Data + Virtual Vehicle Simulation
Pipeline: Load fleet driving data (VED, 383 vehicles, 22 weekly CSVs) → extract drive cycles → build virtual EV model (Powertrain Blockset + Virtual Vehicle Composer) → parallel simulation via `parsim` → energy/range analysis.

- **Key files**: `fleet_virtual_vehicle.m` (main orchestration), `VED_Analysis.m` (data exploration), `VEDExplorer.m` (interactive GUI)
- **Simulink models**: `EVFleetProject/VirtualVehicle2/` contains the most complete variant with engine, driveline, electrical, and thermal subsystems
- **Has its own `CLAUDE.md`** with S3 access patterns and bucket structure
- **Has a Claude skill** at `.claude/skills/cloud-based-virtual-vehicle-simulation/` describing a 5-stage workflow (Build → Configure → Scale → Integrate → Validate)
- **AWS**: S3 bucket `s3://automotivecloud/`, profile name `autocloud`
- **CI/CD**: GitLab Pages deployment (`.gitlab-ci.yml`)

### nasa-aircraft-big-data/ — NASA Aircraft Sensor Data Engineering
ETL pipeline for NASA Dashlink flight sensor data (~280GB full dataset).

- **Key files**: `Demos/ExtractTransformLoad.mlx` (ETL), `Demos/SearchAndAnalyze.mlx` (analysis), `Demos/exploreFlightData.m` (GUI)
- **Helpers/**: Data transformation utilities (`downloadRawData.m`, `extractCruise.m`, `nested2wide.m`)
- **Build & Test**:
  ```matlab
  buildtool check   % Static code analysis (CodeIssuesTask)
  buildtool test    % Run unit tests (depends on check)
  ```
- **Tests**: `Tests/SmokeTests.m` (data pipeline validation), `Tests/ProjectIntegrityTests.m` (project structure)
- **CI/CD**: GitLab with `check` and `test` stages

## Tech Stack

- **MATLAB R2025a+** (primary language for both projects)
- **Simulink** + Powertrain Blockset + Vehicle Dynamics Blockset (autocloud vehicle models)
- **Parallel Computing Toolbox** (`parsim`, `parfor`, `batchsim` — same API for local and cloud)
- **AWS S3** for cloud data storage
- **Python 3.12** (secondary, for archive extraction via py7zr in `autocloud/.venv/`)

## Architecture Pattern

Both projects follow a data-driven simulation pipeline: ingest real-world data → transform → simulate/analyze → visualize. MATLAB Live Scripts (`.m` plain-text format) serve as executable documentation. The `parsim` API enables zero-code-change scaling from local to cloud execution — only the cluster profile changes.

## Working with MATLAB Files

- `.m` files in this repo are primarily **plain-text Live Scripts** (contain `%% ` section breaks and rich formatting markers), not plain functions
- `.mlx` files are binary Live Scripts (in nasa-aircraft-big-data)
- `.slx` files are Simulink models (binary)
- `.sldd` files are Simulink data dictionaries
- Use the MATLAB MCP tools (`evaluate_matlab_code`, `run_matlab_file`, `check_matlab_code`, `run_matlab_test_file`) for execution and analysis
