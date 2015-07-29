FROM debian:jessie
MAINTAINER Nakit.com.br <odoo@nakit.com.br>

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates \
        curl \
        nodejs \
        npm \
        python-support \
        python-pyinotify && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        python-pip \
        git-core && \
    npm install -g less less-plugin-clean-css && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    mkdir -p /tmp/wkhtmltox && \
    cd /tmp/wkhtmltox && \
    curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb && \
    echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - && \
    dpkg --force-depends -i wkhtmltox.deb && \
    apt-get -y install -f --no-install-recommends --no-install-suggests && \
    rm -fr /tmp/wkhtmltox && \
    apt-get purge -y --auto-remove \
       -o APT::AutoRemove::RecommendsImportant=false \
       -o APT::AutoRemove::SuggestsImportant=false npm

# Install Odoo
RUN set -x; \
    curl https://nightly.odoo.com/odoo.key | apt-key add - && \
    echo "deb http://nightly.odoo.com/8.0/nightly/deb/ ./" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests odoo

# Install odoo-magento connector
RUN mkdir -p /tmp/addons && \
    cd /tmp/addons && \
    pip install magento && \
    git clone https://github.com/OCA/account-closing.git -b 8.0 && \
    mv  account-closing/account_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/connector.git -b 8.0 && \
    mv  connector/connector* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/connector-ecommerce.git -b 8.0 && \
    mv  connector-ecommerce/connector_ecommerce \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/connector-magento.git -b 8.0 && \
    mv  connector-magento/customize_example \
        connector-magento/magentoerpconnect \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/e-commerce.git -b 8.0 && \
    mv  e-commerce/product_links \
        e-commerce/sale_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/product-attribute.git -b 8.0 && \
    mv  product-attribute/product_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/sale-workflow.git -b 8.0 && \
    mv  sale-workflow/partner_prepayment \
        sale-workflow/sale_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/server-tools.git -b 8.0 && \
    mv  server-tools/admin_technical_features \
        server-tools/auditlog \
        server-tools/auth_* \
        server-tools/base_* \
        server-tools/cron_run_manually \
        server-tools/database_cleanup \
        server-tools/dbfilter_from_header \
        server-tools/disable_openerp_online \
        server-tools/fetchmail_attach_from_folder \
        server-tools/import_odbc \
        server-tools/language_path_mixin \
        server-tools/mail_environment \
        server-tools/mass_editing \
        server-tools/qweb_usertime \
        server-tools/scheduler_error_mailer \
        server-tools/server_* \
        server-tools/shell \
        server-tools/super_calendar \
        server-tools/users_* \
        server-tools/web_context_tunnel \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/stock-logistics-transport.git -b 8.0 && \
    mv  stock-logistics-transport/purchase_* \
        stock-logistics-transport/sale_* \
        stock-logistics-transport/stock_* \
        stock-logistics-transport/transport_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    git clone https://github.com/OCA/stock-logistics-workflow.git -b 8.0 && \
    mv  stock-logistics-workflow/picking_dispatch \
        stock-logistics-workflow/stock_* \
        /usr/lib/python2.7/dist-packages/openerp/addons && \
    rm -fr /tmp/addons

# Cleanup
RUN set -x; \
    rm -rf /var/lib/apt/lists/* && \
    apt-get purge -y --auto-remove python-pip git-core && \
    apt-get autoclean && \
    apt-get clean

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
