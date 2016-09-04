#!/usr/bin/env python
"""
Import all jobs from /etc/nomad/jobs into Nomad if they do no exist
Jobs are only imported from the Cluster leader
"""

import glob
import json
import time
import subprocess
import requests

class Main:
    """
    Import all the jobs defined in /etc/nomad/jobs if they do not exist
    """
    def __init__(self):
        while not self.cluster_ready():
            time.sleep(1)
        if self.cluster_leader:
            job_ids = [job_id.split('.', 2)[0].split('/')[-1]
                       for job_id in glob.glob('/etc/nomad/jobs/*.nomad')]
            for job_id in job_ids:
                if not self.is_job_running(job_id):
                    print("%s is not defined. Importing." % job_id)
                    self.import_job(job_id)
    def import_job(self, job_id): 
        """
        Import a job from /etc/nomad/jobs using nomad CLI client
        (Don't use HTTP API here to dodge HCL-to-JSON convertion
        """
        subprocess.run(["nomad", "run", "/etc/nomad/jobs/%s.nomad" % job_id])
    def is_job_running(self, job_id): 
        """
        Check if a job exists in Nomad
        """
        response = requests.get("http://localhost:4646//v1/job/%s" % job_id)
        return response.status_code == 200
    def cluster_leader(self):
        """
        Check if the curent node is a cluster leader
        """
        response = requests.get('http://localhost:4646/v1/agent.self')
        self_status = response.json()
        nomad_stats = self_status.get('stats').get('nomad')
        return nomad_stats.get('leader') is "true"
    def cluster_ready(self):
        """
        Check if the current node is in a ready cluster
        """
        try:
            response = requests.get('http://localhost:4646/v1/status/leader')
            if response.status_code is 200:
                return True
        except requests.exceptions.ConnectionError:
            print("Connection refused")
        print("No leader is present")
        return False
Main()
