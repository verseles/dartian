FROM archlinux:latest AS builder
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm dart base-devel
WORKDIR /app
COPY . .
RUN dart pub get && \
    for dir in packages/*/; do cd "$dir" && dart pub get && cd ../..; done && \
    dart compile exe packages/dartian_cli/bin/dartian.dart -o dartian-aot

FROM archlinux:latest AS runtime
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm ca-certificates
WORKDIR /app
COPY --from=builder /app/dartian-aot /app/dartian-aot
ENV PORT=8000
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /app/dartian-aot health || exit 1
ENTRYPOINT ["/app/dartian-aot"]
