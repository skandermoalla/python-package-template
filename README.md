# Python Machine Learning Research Project Template

## Overview

This is a template used for starting python machine learning research
projects with hardware acceleration at the EPFL <insert-lab-name> lab.
It features and encourages good practices for:

- Reproducible environments that can be used/deployed on multiple platforms with hardware acceleration.
  E.g. local computers (macOS + Apple Silicon, WSL + GPU), linux servers (like HaaS at EPFL), the EPFL RunAI Kubernetes
  platform.
- Experiment management, tracking, and sharing with `wandb` and `hydra`.
- Python project packaging inspired from
  the [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- TODO. Code quality and style with `flake8` and `black`.

With this template, open-sourcing your code will be a breeze, and its adoption will be straightforward,
maximizing the impact of your work.

Because of its focus on reproducibility, this template can readily be used by other labs et EPFL and beyond.
It can also be adapted to suit many other use cases.
However, it's maintained form will be tailored to the needs of the <insert-lab-name> lab.
It also contains extra EPFL-specific instructions for deployment on the RunAI Kubernetes platform.

## Getting started with the template

Click on the `Use this template` (GitHub button) to create a new repo, clone it, and

1. Fill the template variables in `template/template_variables.sh` and run the script
   ```bash
   ./template/fill_template.sh
   ```
   Then, delete the `template` directory.
2. Edit the `LICENCE`
   file.
   Or delete it and remember to add one when open-sourcing your
   code. [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT licence is to replace the `2022 Skander Moalla` with your year and name.
3. Setup and edit the development environment instructions for the platforms you'll use/support.
   We support the following platforms:
    - **macOS with Apple Silicon (`osx-arm64`)**, with support for MPS hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.
    - **Docker on AMD64 platforms** (e.g. linux server like the EPFL HaaS servers, WSL on a local machine, Kubernetes
      platforms like the EPFL RunAI Platform), with support for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`.

   Delete the _Template info_ section in the installation instructions of the platforms you plan to support, and the
   whole installation directory for the platforms you don't use.

   In addition, it is good to list your direct dependencies (with major versions when relevant) for users with other
   needs.
   For that, edit the section `Dependencies` as described below.
4. Edit this `README.md` file.
    1. Replace the [_Overview_](#overview) section with description of your project.
    2. Delete the [installation instructions](#development-environment) for the platforms you don't support.
    3. List your direct dependencies (with major versions when relevant) in the Dependencies section. (Todo: link.)
    4. Delete this getting started, to only keep the project [Getting Started](#getting-started)
       section.
5. You're off to a good start! Here are a few tips for keeping your project in a good shape.
    - Todo.
    - Remember to pin your dependencies whenever you install new news.
      More details on this in the installation guides.
    - 

## Getting Started

TODO. This will be the public getting started.

### Development environment

Todo. This will be the public instructions.

We support the following platforms for installing the project dependencies and running the code.

* macOS with Apple Silicon (`osx-arm64`); using a [Conda](https://docs.conda.io/en/latest/) environment.
    - Refer to `installation/osx-arm64/README.md`.

### Repository structure

Todo.
Mention the directory structure. (This is independent of the deployment platform.)