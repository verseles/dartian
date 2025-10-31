# Installation Guide

This guide will walk you through the process of setting up your development environment and creating your first Dartian project.

## 1. Install the Dart SDK

Dartian requires the Dart SDK version 3.0.0 or greater. If you don't have it installed, please follow the official instructions at [dart.dev/get-dart](https://dart.dev/get-dart).

To verify your installation, run the following command in your terminal:

```bash
dart --version
```

You should see output similar to this:

```
Dart SDK version: 3.x.x (stable) ...
```

## 2. Install the Dartian CLI

The Dartian command-line interface (CLI) provides a number of helpful commands for generating code and managing your application.

*(Note: The CLI is not yet published to pub.dev. The following are instructions for when it is available. For now, you will need to set up the project manually.)*

Once available, you can install it globally using `pub`:

```bash
dart pub global activate dartian_cli
```

Make sure the `~/.pub-cache/bin` directory is in your system's `PATH` to be able to run `dartian` from anywhere.

## 3. Create a New Project

With the CLI installed, you can create a new Dartian project with the `new` command:

```bash
dartian new my_app
```

This will create a new directory called `my_app` with the default project structure, including controllers, models, routes, and configuration files.

## 4. Project Setup

Navigate into your newly created project directory:

```bash
cd my_app
```

Next, install the project dependencies:

```bash
dart pub get
```

## 5. Environment Configuration

Dartian uses a `.env` file to manage environment-specific variables. The `new` command will automatically create a `.env.example` file. Copy it to create your local configuration:

```bash
cp .env.example .env
```

Now, open the `.env` file and customize the variables for your local environment, such as database credentials and application keys.

## 6. Run the Development Server

You're all set! To start the development server, run the `serve` command from the root of your project:

```bash
dartian serve
```

The server will start, and your application will be accessible at `http://localhost:8080` by default.
