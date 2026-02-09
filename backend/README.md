# Pokr Backend

## Deployment

1. Run `make build-tar` or `make build-tar-remote` to build the Docker image tar
2. Run `make copy-tar` to copy the tar to the server
3. In portainer:
   - Restart the pokr-backend stack (Stacks -> pokr-backend -> Editor -> Update the stack)
   - Remove the old image (Images -> Remove the unused image)
