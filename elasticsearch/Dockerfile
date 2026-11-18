# Elasticsearch for the Argilla Railway template.
# Argilla 2.8 uses the elasticsearch8 client, so this stays on the 8.x line.
# Official image (same build as docker.elastic.co/elasticsearch/elasticsearch:8.19.25), pinned by version and digest.
FROM elastic/elasticsearch:8.19.25@sha256:5bfdf4313b9bc05c0d46fe219d6e67710eb0c7654ed6c275167bdf9beefc56f0

# Railway volumes are owned by root. The start script runs as root only to fix the
# volume's ownership, then runs Elasticsearch as its normal user (uid 1000).
USER 0
COPY --chmod=0755 start.sh /usr/local/bin/railway-start.sh
ENTRYPOINT ["/bin/tini", "-s", "--", "/usr/local/bin/railway-start.sh"]
