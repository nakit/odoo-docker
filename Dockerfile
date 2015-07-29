FROM debian:jessie
MAINTAINER Nakit.com.br <odoo@nakit.com.br>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            nodejs \
            npm \
            python-support \
            python-pyinotify \
	    python-pip \
	    git-core \
        && npm install -g less less-plugin-clean-css \
        && ln -s /usr/bin/nodejs /usr/bin/node \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install Odoo
ENV ODOO_VERSION 8.0
ENV ODOO_RELEASE 20150401
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Install odoo-magento connector
RUN cd /mnt/extra-addons \
	&& git clone https://github.com/OCA/connector.git -b 8.0 \
	&& git clone https://github.com/OCA/connector-ecommerce.git -b 8.0 \
	&& git clone https://github.com/OCA/connector-magento.git -b 8.0 \
	&& git clone https://github.com/OCA/e-commerce.git -b 8.0 \
	&& git clone https://github.com/OCA/product-attribute.git -b 8.0 \
	&& git clone https://github.com/OCA/sale-workflow.git -b 8.0 \
	&& pip install magento

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
