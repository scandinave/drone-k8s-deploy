FROM bitnami/kubectl:1.19.4

WORKDIR /plugin
USER root
RUN apt-get update && apt-get install -y curl jq
COPY plugin.sh /plugin
RUN chmod +x /plugin/plugin.sh
RUN chown -R 1001:1001 /plugin

USER 1001
ENTRYPOINT /plugin/plugin.sh
