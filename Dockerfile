FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
        git build-essential libpq-dev \
        libsasl2-dev libldap2-dev libxml2-dev libxslt1-dev \
        libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        libblas-dev libatlas-dev gettext-base \
        xfonts-75dpi xfonts-base fontconfig libssl-dev libxrender1 libxext6 \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bullseye_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.bullseye_amd64.deb \
    && apt-get install -f -y \
    && rm wkhtmltox_0.12.6-1.bullseye_amd64.deb \
    && rm -rf /var/lib/apt/lists/*


# Set workdir
WORKDIR /opt/odoo

# Copy Odoo source (your fork)
COPY . /opt/odoo

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt

# Copy Odoo config template
COPY ./odoo.conf.template /etc/odoo/odoo.conf.template

# Expose Odoo port
EXPOSE 8069

# Entrypoint: substitute env vars into config and run Odoo
CMD envsubst < /etc/odoo/odoo.conf.template > /etc/odoo/odoo.conf && \
    python3 odoo-bin -c /etc/odoo/odoo.conf
