runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  --environment EPFL_RUNAI_INTERACTIVE=1 \
  --environment PYCHARM_IDE_LOCATION=/mlodata1/moalla/remote-development/pycharm \
  -- sleep infinity

# Note the following:
# The -dev suffix in the path to my-project, that where I keep my dev copy of the project
# It will not interfere with unattended jobs.