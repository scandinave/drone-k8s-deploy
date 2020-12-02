FROM bitnami/kubectl:1.19.4

WORKDIR /plugin
USER root
COPY plugin.sh /plugin
RUN chmod +x /plugin/plugin.sh
RUN chown -R 1001:1001 /plugin

USER 1001
ENTRYPOINT /plugin/plugin.sh
