#!/usr/bin/env python
"""
Import all jobs from /etc/nomad/jobs into Nomad if they do no exist
Jobs are only imported from the Cluster leader
"""

import glob
import json
import time
import subprocess
import http.client

class Main:
    """
    Import all the jobs defined in /etc/nomad/jobs if they do not exist
    """
    def __init__(self):
        self.nomad = http.client.HTTPConnection('localhost:4646')
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
        self.nomad.request("GET", "/v1/job/%s" % job_id)
        response = self.nomad.getresponse()
        response.read()
        return response.status == 200
    def cluster_leader(self):
        """
        Check if the curent node is a cluster leader
        """
        self.nomad.request("GET", "/v1/agent/self")
        self_status = json.loads(self.nomad.getresponse().read().decode())
        nomad_stats = self_status.get('stats').get('nomad')
        return nomad_stats.get('leader') is "true"
    def cluster_ready(self):
        """
        Check if the current node is in a ready cluster
        """
        try:
            self.nomad.request("GET", "/v1/status/leader")
            response = self.nomad.getresponse()
            leader = response.read().decode()
            if response.status is 200:
                print("%s is a cluster leader." % leader)
                return True
        except ConnectionRefusedError:
            print("Connection refused")
        print("No leader is present")
        return False
Main()
