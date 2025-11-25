FROM odoo:18.0 AS dev

USER root
RUN pip3 install --no-cache-dir --break-system-packages \
    packaging \
    fsspec \
    s3fs \
    boto3
USER odoo

COPY ./odoo/conf/dev.conf /etc/odoo/odoo.conf
COPY ./odoo/addons/ /mnt/extra-addons/
