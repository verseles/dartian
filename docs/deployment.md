# Deployment

When you're ready to deploy your Dartian application to production, there are a few things you should do to ensure your application runs as efficiently as possible.

## Ahead-of-Time (AOT) Compilation

Dart is unique in its ability to be compiled to a self-contained, native machine code executable. This process is called Ahead-of-Time (AOT) compilation. AOT-compiled applications start faster and can use less memory than their JIT (Just-in-Time) compiled counterparts, making them ideal for production server environments.

### Building for Production

To build a production-ready executable for your application, you can use the `build exe` command provided by the Dartian CLI:

```bash
dartian build exe
```

This command will compile your application and place the resulting binary in the `build/` directory. This single file is all you need to run your application on a server with the same operating system.

### Running in Production

To run your compiled application, you can simply execute the binary:

```bash
./build/server
```

Be sure to configure your production environment by providing a `.env` file with your production-specific settings (database credentials, application keys, etc.). The application will automatically load the `.env` file from its current working directory.

## Deploying with Docker

Dartian comes with a multi-stage `Dockerfile` that simplifies the process of creating a lean, production-ready container image for your application.

### The `Dockerfile`

The provided `Dockerfile` has two stages:

1.  **`build` stage**: This stage uses the official `dart:stable` image, which contains the full Dart SDK. It copies your application code, installs dependencies, and runs the `dartian build exe` command to create the production executable.
2.  **`runtime` stage**: This stage uses a minimal `debian:stable-slim` image. It copies only the compiled executable from the `build` stage. The result is a small, secure Docker image that contains only what's necessary to run your application.

### Building the Docker Image

To build the Docker image, run the `docker build` command from the root of your project:

```bash
docker build -t my-dartian-app .
```

### Running the Container

Once the image is built, you can run it as a container:

```bash
docker run -p 8080:8080 -v ./.env:/app/.env my-dartian-app
```

This command does the following:

- `docker run`: Starts a new container.
- `-p 8080:8080`: Maps port 8080 on your host machine to port 8080 inside the container.
- `-v ./.env:/app/.env`: Mounts your local `.env` file into the container, providing the necessary environment configuration.
- `my-dartian-app`: The name of the image to run.

Your application will now be running inside a Docker container and accessible at `http://localhost:8080`.
