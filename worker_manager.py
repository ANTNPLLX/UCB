#!/usr/bin/env python3
"""
worker_manager.py - Worker discovery and management module
"""

import os
import re
import subprocess

class Worker:
    """Represents a worker script"""

    def __init__(self, script_path, question, order, description, enabled=True):
        self.script_path = script_path
        self.question = question  # 16 chars max for LCD
        self.order = order
        self.description = description
        self.enabled = enabled
        self.name = os.path.basename(script_path)

    def __repr__(self):
        status = "enabled" if self.enabled else "disabled"
        return f"Worker({self.name}, order={self.order}, question='{self.question}', {status})"

    def run(self, device):
        """Execute the worker script with device parameter"""
        try:
            result = subprocess.run(
                [self.script_path, device],
                capture_output=True,
                text=True,
                timeout=600  # 10 minute timeout
            )
            return {
                'success': result.returncode == 0,
                'returncode': result.returncode,
                'stdout': result.stdout,
                'stderr': result.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'returncode': -1,
                'stdout': '',
                'stderr': 'Worker timeout after 10 minutes'
            }
        except Exception as e:
            return {
                'success': False,
                'returncode': -1,
                'stdout': '',
                'stderr': str(e)
            }


class WorkerManager:
    """Discovers and manages worker scripts"""

    def __init__(self, workers_dir):
        self.workers_dir = workers_dir
        self.workers = []
        self.discover_workers()

    def parse_worker_metadata(self, script_path):
        """Parse metadata from worker script header"""
        metadata = {
            'question': None,
            'order': 999,  # Default high order number
            'description': '',
            'enabled': True  # Default enabled
        }

        try:
            with open(script_path, 'r') as f:
                # Read first 20 lines for metadata
                for i, line in enumerate(f):
                    if i >= 20:
                        break

                    # Look for metadata comments
                    if 'WORKER_QUESTION=' in line:
                        match = re.search(r'WORKER_QUESTION=(.+)', line)
                        if match:
                            metadata['question'] = match.group(1).strip()

                    elif 'WORKER_ORDER=' in line:
                        match = re.search(r'WORKER_ORDER=(\d+)', line)
                        if match:
                            metadata['order'] = int(match.group(1))

                    elif 'WORKER_DESCRIPTION=' in line:
                        match = re.search(r'WORKER_DESCRIPTION=(.+)', line)
                        if match:
                            metadata['description'] = match.group(1).strip()

                    elif 'WORKER_ENABLED=' in line:
                        match = re.search(r'WORKER_ENABLED=(true|false|yes|no|1|0)', line, re.IGNORECASE)
                        if match:
                            value = match.group(1).lower()
                            metadata['enabled'] = value in ['true', 'yes', '1']

        except Exception as e:
            print(f"Warning: Could not parse metadata from {script_path}: {e}")

        return metadata

    def discover_workers(self):
        """Discover all worker scripts in workers directory"""
        self.workers = []

        if not os.path.exists(self.workers_dir):
            print(f"Warning: Workers directory not found: {self.workers_dir}")
            return

        # Find all .sh files in workers directory
        for filename in os.listdir(self.workers_dir):
            if filename.endswith('.sh'):
                script_path = os.path.join(self.workers_dir, filename)

                # Check if file is executable
                if not os.access(script_path, os.X_OK):
                    print(f"Warning: Worker script not executable: {filename}")
                    continue

                # Parse metadata
                metadata = self.parse_worker_metadata(script_path)

                # Only add workers that have a question defined
                if metadata['question']:
                    worker = Worker(
                        script_path=script_path,
                        question=metadata['question'],
                        order=metadata['order'],
                        description=metadata['description'],
                        enabled=metadata['enabled']
                    )
                    self.workers.append(worker)
                    print(f"Discovered worker: {worker}")
                else:
                    print(f"Skipping {filename}: No WORKER_QUESTION defined")

        # Sort workers by order
        self.workers.sort(key=lambda w: w.order)

        print(f"Total workers discovered: {len(self.workers)}")

    def get_workers(self, include_disabled=False):
        """Get list of all workers sorted by order

        Args:
            include_disabled: If False (default), only return enabled workers
        """
        if include_disabled:
            return self.workers
        return [w for w in self.workers if w.enabled]

    def get_worker_by_name(self, name):
        """Get a worker by its script name"""
        for worker in self.workers:
            if worker.name == name:
                return worker
        return None
