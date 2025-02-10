import os
import subprocess
import re
from flask import Flask, jsonify, request

app = Flask(__name__)

PROJECT_DIR = "."  
BACKEND_DIR = "backend"  
TFVARS_FILE = "terraform.tfvars" 
ANSIBLE_DIR = "ansible-ssm"
def run_terraform_command(command, directory):
    try:
        result = subprocess.run(
            command, cwd=directory, capture_output=True, text=True, shell=True
        )
        return {"stdout": result.stdout, "stderr": result.stderr, "returncode": result.returncode}
    except Exception as e:
        return {"error": str(e)}

@app.route("/setup-backend", methods=["POST"])
def setup_backend():
    commands = [
        "terraform init",
        "terraform plan -var-file=backend.tfvars",
        "terraform apply -var-file=backend.tfvars -auto-approve"
    ]
    
    output = {}
    
    for cmd in commands:
        output[cmd] = run_terraform_command(cmd, BACKEND_DIR)
        if output[cmd]["returncode"] != 0:
            return jsonify({"error": f"Command failed: {cmd}", "details": output}), 500
    
    return jsonify({"message": "Terraform backend setup completed successfully", "output": output})

@app.route("/update-tfvars", methods=["POST"])
def update_tfvars():
    try:
        if not request.is_json:
            return jsonify({"error": "Invalid request format. Expected JSON"}), 400

        data = request.get_json()

        # Extract only the values to update
        updates = {}
        if "postgres_worker_replicas" in data:
            updates["postgres_worker_replicas"] = str(data["postgres_worker_replicas"])  # Ensure it's a number
        if "instance_type" in data:
            updates["instance_type"] = f'"{data["instance_type"]}"'  # Ensure it's a quoted string

        if not updates:
            return jsonify({"error": "No valid keys provided. Allowed keys: postgres_worker_replicas, instance_type"}), 400

        # Read existing terraform.tfvars content line by line (to preserve formatting)
        updated_lines = []
        with open(TFVARS_FILE, "r") as f:
            for line in f:
                original_line = line  # Preserve original line for safety
                key_value_match = re.match(r'^(\S+)\s*=\s*(.+)$', line.strip())

                if key_value_match:
                    key, value = key_value_match.groups()
                    if key in updates:
                        line = f"{key} = {updates[key]}\n"  # Replace with updated value

                updated_lines.append(line)

        # Write back updated values while preserving others
        with open(TFVARS_FILE, "w") as f:
            f.writelines(updated_lines)

        return jsonify({"message": "terraform.tfvars updated successfully", "updated_values": updates})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/terraform-init", methods=["POST"])
def terraform_init():
    output = run_terraform_command("terraform init", PROJECT_DIR)
    if output["returncode"] != 0:
        return jsonify({"error": "Terraform init failed", "details": output}), 500
    return jsonify({"message": "Terraform init successful", "output": output})

@app.route("/terraform-plan", methods=["POST"])
def terraform_plan():
    output = run_terraform_command("terraform plan -var-file=terraform.tfvars", PROJECT_DIR)
    if output["returncode"] != 0:
        return jsonify({"error": "Terraform plan failed", "details": output}), 500
    return jsonify({"message": "Terraform plan successful", "output": output})

@app.route("/terraform-apply", methods=["POST"])
def terraform_apply():
    output = run_terraform_command("terraform apply -var-file=terraform.tfvars -auto-approve", PROJECT_DIR)
    if output["returncode"] != 0:
        return jsonify({"error": "Terraform apply failed", "details": output}), 500
    return jsonify({"message": "Terraform apply successful", "output": output})

@app.route("/setup-config", methods=["POST"])
def setup_config():
    try:
        if not request.is_json:
            return jsonify({"error": "Invalid request format. Expected JSON"}), 400
        
        data = request.get_json()

        ansible_command = [
            "ansible-playbook", "playbooks/playbook.yaml",
            "-i", "inventory/aws_ec2.yml"
        ]

        # Append extra vars if provided in the request
        if "postgres_version" in data:
            ansible_command.append(f"-e postgres_version={data['postgres_version']}")
        if "max_connections" in data:
            ansible_command.append(f"-e max_connections={data['max_connections']}")
        if "shared_buffers" in data:
            ansible_command.append(f"-e shared_buffers={data['shared_buffers']}")

        result = subprocess.run(ansible_command, cwd=ANSIBLE_DIR, capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({"error": "Ansible playbook execution failed", "stderr": result.stderr}), 500

        return jsonify({"message": "Postgres configured successfully via Ansible", "stdout": result.stdout})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)