# Argilla server for the Argilla Railway template.
# Official image argilla/argilla-server, pinned by version and digest.
FROM argilla/argilla-server:v2.8.0@sha256:6f4af8fcf4b809d25aa88a6a4f8838dbacab9296c83b055a9a58f1db7526431a

COPY --chmod=0755 start.sh /home/argilla/railway-start.sh
EXPOSE 6900
CMD ["/bin/bash", "/home/argilla/railway-start.sh"]
