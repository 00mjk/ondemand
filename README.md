# OOD My Jobs

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-myjobs.svg)](https://badge.fury.io/gh/OSC%2Food-myjobs)

OOD Rails app for Open OnDemand for creating and managing batch jobs from template directories.

## New Install

**Installation assumptions: you have an Open OnDemand installation with File Explorer and Shell apps installed and a cluster config added to /etc/ood/config/clusters.d directory.**

1. Starting in the build directory for all sys apps (i.e. `cd ~/ood_portals/ondemand/sys`), clone and check out the latest version of myjobs (make sure the app directory's name is "myjobs"):

  ```sh
  scl enable git19 -- git clone https://github.com/OSC/ood-myjobs.git myjobs
  cd myjobs
  scl enable git19 -- git checkout tags/v2.0.0
  ```

2. Build the app (install dependencies and build assets)

  ```sh
  scl enable rh-ruby22 -- bin/bundle install --path vendor/bundle
  scl enable rh-ruby22 nodejs010 -- bin/rake assets:precompile RAILS_ENV=production
  scl enable rh-ruby22 -- bin/rake tmp:clear
  ```

3. Copy the built app directory to the deployment directory, and start the server.

4. Access the app through dashboard by going to /pun/sys/dashboard and then clicking "My Jobs" from the Jobs menu

## Updating to a New Stable Version

**TODO**

# Old documentation

**TODO** - replace with updated documentation

* default template
* templates/ directory and osc-myjobs-templates example repo
* template manifest

## Templates

A template consists of a folder and (optionally) a `manifest.yml` file.

The folder contains files and scripts related to the job.

The manifest contains additional metadata about a job, such as a name, the default host, the submit script file name, and any notes about the template.

## Building a Template

Prepare a manifest with `name` (string), `host` (string \[options: `oakley` or `ruby`\]), `script` (string \[the relative path of the file to be submitted\]), and `notes` (string) variables and name it `manifest.yml`

```
name: A Template Name
host: ruby
script: ruby.sh
notes: Notes about the template, such as content and function.
```

## Template Defaults

In the event that a folder exists in the template source location but no `manifest.yml` is present, or if the variables missing, the Job Constructor will assign the following default values:

* `name` The name of the template folder.
* `host` The first server listed in `config/servers.yml` (Currently Oakley)
* `script` The first `.sh` file appearing in the template folder.
* `notes` The path to the location where a template manifest should be located.
