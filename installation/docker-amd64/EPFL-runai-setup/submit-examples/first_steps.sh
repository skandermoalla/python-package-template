runai submit \
  --name example-first-steps \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:dev \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  -e EPFL_RUNAI=1 \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e SSH_ONLY=1 \
  -- sleep infinity

## Notes:
# This will start an ssh server in the container, without setting the paths for your project.
# The important bits here are:
# -e EPFL_RUNAI=1
# -e EPFL_RUNAI_INTERACTIVE=1
# -e SSH_SERVER=1
# -e SSH_ONLY=1
# --pvc your_pvc_name:/where_to_mount_your_pvc (you can mount it anywhere)

## Useful commands.
# runai describe job example-first-steps
# runai logs example-first-steps
# kubectl port-forward example-first-steps-0-0  2222:22
# ssh-keygen -R '[127.0.0.1]:2222'
# ssh -p 2222 moalla@127.0.0.1
