# Guide for using the template with the EPFL IC RunnAI cluster

## Overview

At this point, you should have an image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL IC RunAI cluster and use for:

1. Remote development (as at <lab-name> we use the RunAI platform as our daily drivers).
2. Running unattended jobs.

Using the image on the HaaS lab machines falls into the public instructions
using the reproducible `local` Docker Compose servie and is covered by the
instructions in the `installation/docker-amd64/README.md` file.

## Prerequisites

**Docker image**:

Your should be able to deploy your docker image locally (on the machine you built it).
It will be hard to debug your image on RunAI if you can't even run it locally.

**RunAI**:

1. You should be familiar with the RunAI platform, be able to run jobs on it, and know how to check their status.
2. You should have access to [Harbor](https://ic-registry.epfl.ch), the EPFL IC Docker registry.
3. You should have one or more PVC(s) (Persistent Volume Claim) that you can use to store your data on the cluster.

Refer to this tutorial for an introduction to these tools (TODO: link to the EPIC guide.)

## First steps

### Push your image to the EPFL IC Docker registry

```bash
# Get your image name from the last line of the build output (ic-registry.epfl.ch/.../:...) 
docker push <image-name>
```

### Clone your repository in your PVCs

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

In addition, if you have multiple PVCs with different performance characteristics,
you may want to put your data and outputs on a different PVC than your code.
This is straightforward with this template and is covered in the examples provided.

If you already have your repository in your PVC, e.g. because you have your PVC mounted on an ssh server that you use
for development,
you can skip to the next section.
Otherwise, the template covers a deployment options that simply opens an ssh server on your container without setting up
the project, forwards your ssh keys, and allows you to clone your repository on the container.

1. Submit your job in the same fashion as `submit-examples/first_steps.sh`,
   specifying your image name, and PVC(s).
   Checking its logs will give:
   ```bash
    $ runai logs example-first-steps     
    Running entrypoint.sh
    SSH_ONLY is set. Only starting an ssh server without setup.
   ```
2. Follow the steps in the [SSH configuration section](#ssh-configuration) and ssh to your container.
3. Clone your repository in your PVCs. (Don't forget to push & pull the changes you did after initializing the
   template.)

   ```bash
   # Somewhere in your PVC.
   mkdir <project-name>
   git clone <repo-url> <project-name>/dev
   git clone <repo-url> <project-name>/run
   ```

### A quick test to understand how the template works

Adapt the `submit-examples/minimal.sh` with the name of your image, your PVC(s), and the correct paths to your project
in the PVC(s).

As in the example, when you specify the `EPFL_RUNAI=1` environment variable with your submit command,
the entrypoint of the container will run an additional setup script that:

- Creates symlinks to the relevant directories in your PVCs on the `${PROJECT_ROOT}=/opt/project/` in the container.
  (Currently this is a workaround as RunAI does not support directly mounting subdirectories of PVCs)
- Installs the project in editable mode. This is a lightweight installation that allows you to edit the code
  on your local machine and have the changes reflected in the container.
- Executes a provided command (e.g. `sleep infinity`), otherwise by default will run a shell and stop.
  The command is given as a `CMD` directive to Docker, passed to the entrypoint, which will run it PID 1.
  You should not have to override the entrypoint itself, i.e. using `--command` flag with `runai submit`.

You need to make sure that this minimal submission works before proceeding.
You can check the logs of the container with `runai logs example-minimal` to see if everything is working as expected.
You should expect to see something like:

```bash
$ runai logs example-minimal    
Running entrypoint.sh
Installing the project.
Obtaining file:///opt/project/machrou3
  Installing build dependencies: started
  Installing build dependencies: finished with status 'done'
  ...
Successfully built machrou3
Installing collected packages: machrou3
Successfully installed machrou3-0.0.1
Project imported successfully.
````

You can then open a shell in the container and check that everything is working as expected:

```bash
runai exec -it example-minimal zsh
```

## Use cases

### Running unattended jobs

By performing the above first steps you should have all the required setup to run unattended jobs.
An example of an unattended job can be found in `submit-examples/unattended.sh`.
Note the emphasis on having a frozen copy of the repository for running unattended jobs.

### Remote development

This would be the typical use case for a researcher at <lab-name> using the RunAI cluster as their daily driver to do
development, testing, and debugging.
Your job would start a remote IDE running on the cluster, and you would only have a lightweight local IDE client running
on you laptop.

When you specify an additional environment variable with your submitted job `EPFL_RUNAI_INTERACTIVE=1`,
the entrypoint will run an additional setup script that:

- starts an ssh server.
- starts a remote development server if you specify the path to the IDE binaries.

You can configure this to your needs with environment variables sent with the `runai submit` command:
An example of an interactive job submission can be found in `submit-examples/remote_development.sh`

The list of environment variables that you can use to configure your interactive job are:

```bash
--environment SSH_FORWARD_PORT=<>       # Port on the local machine that forwards to the ssh server on the container.
                                        # Defaults to 2222.
--environment PYCHARM_IDE_LOCATION=<>   # Path to the PyCharm remote IDE binaries.
                                        # If specified, will start the remote IDE on the container.
--environment PYCHARM_PROJECT_CONFIG_LOCATION=<> # Path to the PyCharm project configuration directory.
                                                 # If specified, will symlink to it, otherwise will be a fresh IDE.
--environment VSCODE_IDE_LOCATION # TODO.
--environment JUPYTER_SOMETHING # TODO.
```

We describe in more detail how you can do remote development below.

#### SSH configuration

The ssh server is configured to run on port 22 of the container.
With RunAI, you can forward a local port on your machine to this port on the container.

That is, when your container is up, run

```bash
# Here 2222 on the local machine is forwarded to 22 on the pod.
# You can change the local port number to another port number.
kubectl port-forward <pod-name> 2222:22
```

You can then ssh to your container by ssh-ing to that port on your local machine.
Connect with the user and password you specified in your `.env` file when you built the image.

```bash
# ssh to local machine is forwarded to the pod.
ssh -p 2222 <user>@127.0.0.1   
```

As the container will each time be on a different machine, you will have to reset the ssh key for the remote server.
You can do this with

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Moreover, so that you don't have to put your ssh keys on the remote server, you can forward your ssh keys with your ssh
agent (e.g. to connect to GitHub).
Follow the guide
[here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding).
With the following changes to your ssh config file.

```bash
Match host 127.0.0.1 exec "test %p = 2222"
	ForwardAgent yes
```

**Limitations**

Note that an ssh connection to the container is not like executing a shell on the container. E.g.

- environment variables created when running the container are not available during ssh connections.
  You can work around this by explicitly adding them to the`.zshrc`
  with `echo "export VARIABLE=${VARIABLE}" >> ~/.zshrc` in the Dockerfile if these are build-time variables
  or in the entrypoint script if those are runtime variables.

#### PyCharm

There are two main ways to use
PyCharm [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html) with an ssh
server (here our container):

1. Using the JetBrains Gateway client to install the IDE in the server and connect to it.
2. The server has access to remote IDE binaries, starts the IDE on its own, and gives you a link to use with
   Gateway to directly connect to it.

The template supports both options.
We suggest using option 1 when you don't have access to the PyCharm remote IDE binaries as a first time.
Then settle with option 2 as it makes using RunAI as your daily driver feel like just opening a local IDE.

Nevertheless, option 2 could have some bugs as we're not sure yet
how safe it is to have the directory containing the binaries of the IDE shared between machines.
Option 1 is bug free as it installs a fresh copy of the IDE on the container.

For both options your project directory will be the `${PROJECT_ROOT}=/opt/project` in the container.

_Option 1_:

1. Submit your job as in the example `submit-examples/remote_development.sh` without specifying the path to the IDE.
2. Enable ssh forwarding.
3. Then follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway).

You can then copy the binaries in `~/.cache/JetBrains/RemoteDev/dist/<some_pycharm_ide_version>` to your PVC
to use option 2. (E.g. to `/mlodata1/moalla/remote-development/pycharm` in the example.)

_Option 2_:

1. In your `runai submit` command,

    - Set the environment variable for the path to PyCharm remote IDE binaries on your PVC `PYCHARM_IDE_LOCATION`.
    - Optionally if your forward port is different from 2222 set `SSH_FORWARD_PORT`.

   You can find an example in `submit-examples/remote_development.sh`.

   Your IDE will start running with your container.
   It will print a link to the IDE in the container logs.

   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
   Gateway link: jetbrains-gateway://connect#idePath=%2Fmlodata1%2Fmoalla%2Fremote_development%2Fpycharm&projectPath=%2Fopt%2Fproject&host=127.0.0.1&port=2222&user=&type=ssh&deploy=false
   ```
2. Enable ssh forwarding.
3. Use the Gateway link to connect to the remote IDE from a local JetBrains Gateway client as
   described [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#use_idea).

**Saving the project IDE configuration**

The remote IDE stores its configuration (e.g. the interpreters you set up, memory ) in `~/.config/JetBrains/RemoteDev-PY/_opt_project`.
This is project-based.
Moreover, the project configuration is stored in `${PROJECT_ROOT}/.idea`.
To have both of these maintained between different dev containers you can create placeholder
directories in your PVC and the template will handle sym-linking them when the container starts.
A good place to create those directories as they are project-dependant is in your project root on your PVC,
which will look like this in the example we provide

    ```bash
    /mlodata1/moalla/machrou3
    ├── dev             # The copy of your repository for development.
    ├── run             # The frozen copy of your repository for unattended jobs.
    └── pycharm-config  
        ├── _config     # To contain the IDE .config for the project.
        └── _idea       # To contain the project .idea.
    ```

# The directory containing the PyCharm IDE configuration for the project.

**Limitations**

- The terminal in PyCharm opens ssh connections to the container, so the limitations in the ssh section apply.
    - If needed, a workaround would be to just open a separate terminal on your local machine
      and directly exec a shell into the container.
- The template does not support storing all the IDE configuration yet (this is work in progress).

#### VSCode

#### JuptyerLab

Note: make a note that jupyter notebooks are harder to reproduce and do not fill well in a codebase.
Use them to experiment with plots maybe, but then copy the code to a proper script that outputs the figure
to a file.

### Examples

We provide examples of how to use the template in the `submit-examples` directory.
We use `submit` commands and not YAML files to specify job configurations because the RunAI API for kubernetes resources
is still in alpha phase.

### Troubleshooting