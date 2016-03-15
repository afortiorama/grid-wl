import itertools
import os
import re
import sys
import collections

def flatten_jobs(jobs):
    js = []
    for job in jobs:
        if job.subjobs:
            js+=job.subjobs
        else:
            js.append(job)
    return js

def job_histogram_by_ce(jobs):
    key = lambda j: j.backend.actualCE
    jobs = flatten_jobs(jobs)
    jobs = sorted(jobs, key=key)
    for ce, js in itertools.groupby(jobs, key):
        print ce
        job_histogram(js)
        print


def job_histogram(jobs):
    js = flatten_jobs(jobs)
    counts = collections.defaultdict(int)
    for j in js:
        counts[j.status]+=1
    total = sum(counts.values())
    for status, count in counts.items():
        print 'Tot %d, Perc %.1f%% %s' % (count, count*100.0/total, status)

def rerun_lancs(jobs):
    for sj in flatten_jobs(jobs):
        if sj.backend.actualCE=='LCG.UKI-NORTHGRID-LANCS-HEP.uk' and (sj.status=='completed' or sj.status=='failed'):
            sj.backend.settings['BannedSites']=['LCG.UKI-NORTHGRID-LANCS-HEP.uk']
            sj.fqid
            sj.resubmit()

def rerun_failed(jobs,tree_name):
    jobtree = Ganga.GPI.JobTree()
    for j in jobtree.getjobs(tree_name):
        if sj.status=='failed':
            sj.fqid
            sj.resubmit()

