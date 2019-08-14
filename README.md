# BIIGLE GPU Server Distribution

This is the production setup of the BIIGLE GPU server. You can fork this repository to customize your own production instance.

## Installation

Perform these steps on the machine that should run the BIIGLE GPU server.

1. Create a user for the BIIGLE GPU server and find out the user and group ID:
   ```bash
   $ sudo useradd biigle -U
   $ id -u biigle
   <user_id>
   $ id -g biigle
   <group_id>
   ```

2. Change the owner of the `storage` directory:
   ```bash
   $ sudo chown -R biigle:biigle storage/
   ```

2. Move `.env.example` to `.env`.

3. Now set the configuration variables in `.env`:

   - `USER_ID` should be `<user_id>`.
   - `GROUP_ID` should be `<group_id>`.

2. Move `build/.env.example` to `build/.env`.

3. Now set the build configuration variables in `build/.env`:

   - `GITHUB_OAUTH_TOKEN` is an [OAuth token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) of your GitHub account.
   - `APP_KEY` is the secret encryption key. Generate one with: `head -c 32 /dev/urandom | base64`. Then set `APP_KEY=base64:<your_key>`.
   - `APP_URL` is `https://<your_domain>`.
   - `REMOTE_QUEUE_ACCEPT_TOKENS` is the comma separated list of tokens that are accepted for authentication of incoming remote queue qobs. Set this to the `QUEUE_GPU_TOKEN` of your BIIGLE application.
   - `QUEUE_GPU_RESPONSE_URL` is the remote queue API endpoint of your BIIGLE application where the responses of the incoming jobs are submitted to. Set it to the API endpoint of your BIIGLE application.
   - `QUEUE_GPU_RESPONSE_TOKEN` is the token used to authenticate the responses. Set it to the `REMOTE_QUEUE_ACCEPT_TOKENS` of your BIIGLE application.
   - `MAIA_MAX_WORKERS` is the number (or number-1) of available CPU cores that is used by the MAIA module.
   - `MAIA_AVAILABLE_BYTES` is the estimated GPU memory size in bytes that is used by the MAIA module.

4. Now build the Docker images for production: `cd build && ./build.sh`. You can build the images on a separate machine, too, and transfer them to the production machine using [`docker save`](https://docs.docker.com/engine/reference/commandline/save/) and [`docker load`](https://docs.docker.com/engine/reference/commandline/load/). `build.sh` also supports an optional argument to specify the version tag of the Docker containers to build (e.g. `v2.8.0`). Default is `latest`.

5. Go back and run the containers: `cd .. && docker-compose up -d`.

## Updating

1. Get the newest versions of the `biigle/gpus-app`, `biigle/gpus-web` and `biigle/gpus-worker` images.

2. Run `cd build && ./build.sh`. This will fetch and install the newest versions of the BIIGLE modules, according to the version constraints configured in `build.sh`. Again, you can do this on a separate machine, too (see above). In this case the images mentioned above are not required on the production machine.

3. Update the running Docker containers: `docker-compose up -d`.

4. Run `docker image prune` to delete old Docker images that are no longer required after the update.
