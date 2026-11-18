# Argilla background worker (imports, exports, webhooks, distribution updates)
# for the Argilla Railway template. Same pinned image as the server.
FROM argilla/argilla-server:v2.8.0@sha256:6f4af8fcf4b809d25aa88a6a4f8838dbacab9296c83b055a9a58f1db7526431a

COPY --chmod=0755 start.sh /home/argilla/railway-worker.sh
CMD ["/bin/bash", "/home/argilla/railway-worker.sh"]
