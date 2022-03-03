FROM paulej/rfctools
RUN dnf update -y --refresh && \
    dnf install -y java && \
    dnf clean all
