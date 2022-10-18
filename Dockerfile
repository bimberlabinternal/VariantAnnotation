FROM broadinstitute/gatk:latest

RUN wget https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && apt-key add apt-key.gpg \
	&& rm apt-key.gpg \
	&& apt-get update -y \
	&& apt-get upgrade -y \
	&& apt-get install -y file tabix \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
