# Deploy Agent -Automated Project Bootstrapping

## Description
A shell script that sets up a Student Attendance Tracker workspace with directory structure,configuration,and process management.

## How to run the script

1. Clone the repository from Github by running this code:
git clone https://github.com/skemboi-kossy/deploy_agent_skemboi-kossy.git

2. Navigate into the directory already cloned:
cd deploy_agent_skemboi-kossy

3. Make the script executable by running this code:
chmod +x  setup_project.sh

4. Run the script:
bash setup_project.sh

5. Follow the following prompts:
-Enter a project name
-Choose whether to update attendance thresholds
-Enter new Warning and Failure thresholds if needed

## How to Trigger the Archive Feature

1. Run the script: bash setup_project.sh
2. Enter the project name
3. Press Ctrl+C at any point during execution
4. The script will automatically :
-Bundle the incomplete project into a .tar.gz archive
-Delete the incomplete directory
-Exit cleanly


## Project Structure Created 


The script creates the following :
- attendance_checker.py
- Helpers/assets.csv
- Helpers/config.json
- reports/reports.log


## Requirements

-bash
-python3
