FROM alpine:3.20.1

COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache curl python3 ca-certificates bash && \
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz && \
    tar -xzf helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    curl -fsSL -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-483.0.0-linux-x86_64.tar.gz && \
    tar -xzf google-cloud-sdk.tar.gz && \
    google-cloud-sdk/install.sh -q && \
    rm -rf linux-amd64 helm.tar.gz linux-amd64 && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  && \
    mv kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    chmod +x /entrypoint.sh && \
    /google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin && \
    addgroup --gid 1000 gke && adduser -S --uid 1000 gke -G gke && chown -R gke:gke /home/gke

SHELL ["/bin/bash", "-c"]

RUN source /google-cloud-sdk/completion.bash.inc && \
    source /google-cloud-sdk/path.bash.inc && \
    echo "source /google-cloud-sdk/completion.bash.inc" >> /home/gke/.bashrc && \
    echo "source /google-cloud-sdk/path.bash.inc" >> /home/gke/.bashrc

ENV PATH="/google-cloud-sdk/bin:${PATH}"

USER gke

WORKDIR /home/gke

ENTRYPOINT [ "/entrypoint.sh" ]