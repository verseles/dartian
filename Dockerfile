# Stage 1: Build the application
FROM dart:stable AS build

WORKDIR /app

# Copy the entire monorepo
COPY . .

# Get dependencies for all packages
RUN dart pub get

# Create the build directory
RUN mkdir -p build

# Build the application
RUN dart compile exe bin/server.dart -o build/server

# Stage 2: Create the production image
FROM debian:stable-slim

WORKDIR /app

# Copy the executable from the build stage
COPY --from=build /app/build/server /app/server

# Expose the port the server will run on
EXPOSE 8080

# Run the executable
CMD ["/app/server"]
