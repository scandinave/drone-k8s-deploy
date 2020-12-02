FROM bitnami/kubectl:1.19.4

WORKDIR /plugin

COPY plugin.sh .
RUN chmod +x plugin.sh

ENTRYPOINT plugin.sh
