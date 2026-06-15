#!/bin/bash

#Get user input for projects name
read -p "Enter project name: " input
PROJECT_DIR="attendance_tracker_${input}"

#Trap - Handle Ctrl+C (SIGINT)
cleanup() {
	echo ""
	echo "Interrupt detected! Bundling current state..."
	tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR" 2>/dev/null
	rm -rf "$PROJECT_DIR"
	echo "Archive created: ${PROJECT_DIR}_archive.tar.gz"
	echo "Incomplete directory deleted. Exiting."
	exit 1

}

trap cleanup SIGINT 
# SECTION 2 - Create Directory Structure
echo "Creating project directory structure..."

mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# Create attendance_checker.py
cat > "$PROJECT_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Create assets.csv
cat > "$PROJECT_DIR/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# Create config.json
cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
  "total_sessions": 15,
  "run_mode": "live",
  "thresholds": {
    "warning": 75,
    "failure": 50
  }
}
EOF

# Create reports.log
cat > "$PROJECT_DIR/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo "Directory structure created successfully!"
# SECTION 3 - Dynamic Configuration
echo ""
read -p "Do you want to update attendance thresholds? (yes/no) : " update_choice
if [ "$update_choice" == "yes" ]; then
	read -p "Enter new Warning threshold (default 75): " new_warning
	read -p "Enter new Failure threshold (default 50): " new_failure
	if ! [[ "$new_warning" =~ ^[0-9]+$ ]] || ! [[ "$new_failure" =~ ^[0-9]+$ ]]; then
		echo "Invalid input! Thresholds must be numbers. Using defaults."
	else

		sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" "$PROJECT_DIR/Helpers/config.json"
      
	      	sed -i "s/\"failure\": [0-9]*/\"failure\": $new_failure/" "$PROJECT_DIR/Helpers/config.json"

		echo "Thresholds updated! Warning: $new_warning%, Failure: $new_failure%"
	fi
else
	echo "Keeping default thresholds. Warning: 75%, Failure: 50%"
fi
#SECTION 4 - Environment Validation
echo ""
echo "Running Health Check..."
if command -v python3 &>/dev/null; then
	echo "Python3 is installed!"
	python3 --version
else
	echo "WARNING: Python3 is not installed!"
fi
echo ""
echo "Verifying directory structure..."
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
     echo "All files verified successfully!"
else 
   echo "Warning: Some files are missing!"
fi
echo ""
echo "Project setup complete!"


