FROM python:3.7

ARG GITHUB_TOKEN

RUN pip install --no-cache-dir --upgrade pip setuptools \
    && pip install --no-cache-dir git+https://$GITHUB_TOKEN@github.com/PeakBI/orion.git@0.5.3#egg=orion

ARG STAGE
ARG TENANT
ARG REDSHIFT_USERNAME
ARG REDSHIFT_PASSWORD
ARG REDSHIFT_HOST
ARG REDSHIFT_PORT
ARG REDSHIFT_IAM_ROLE
ENV STAGE=$STAGE\
    TENANT=$TENANT\
    REDSHIFT_USERNAME=$REDSHIFT_USERNAME \
    REDSHIFT_PASSWORD=$REDSHIFT_PASSWORD \
    REDSHIFT_HOST=$REDSHIFT_HOST \
    REDSHIFT_PORT=$REDSHIFT_PORT \
    REDSHIFT_IAM_ROLE=$REDSHIFT_IAM_ROLE
    
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && rm requirements.txt