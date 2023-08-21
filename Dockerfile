# A docker file for configuring AdGuardHome

FROM adguard/adguardhome:latest

ENV ADMIN_PASSWORD password
ENV ADMIN_USERNAME admin
ENV SPACE_SEPARATED_FILTER_ALLOW ""
ENV SPACE_SEPARATED_FILTER_DENY ""
ENV UPSTREAM_DNS "94.140.14.140"

# Install htpasswd
RUN apk update && apk add apache2-utils

# Copy files into the image and make them executable if needed
COPY template.yaml /opt/adguardhome/conf/AdGuardHome.yaml
COPY generate.sh /opt/adguardhome/conf/
COPY entrypoint.sh /opt/adguardhome/
RUN chmod 755 /opt/adguardhome/conf/generate.sh /opt/adguardhome/entrypoint.sh

# Set custom entry point
ENTRYPOINT ["/opt/adguardhome/entrypoint.sh"]

# Arguments to AdGuardHome
CMD [ \
    "--no-check-update", \
    "-c", "/opt/adguardhome/conf/AdGuardHome.yaml", \
    "-w", "/opt/adguardhome/work" \
]
