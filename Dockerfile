FROM debian:bookworm-slim


ENV DEBIAN_FRONTEND=noninteractive

ENV PATH="/usr/games:${PATH}"

# Install required packages 
RUN apt-get update && apt-get install -y \
    fortune-mod \
    cowsay \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app


COPY wisecow.sh .


RUN chmod +x wisecow.sh


EXPOSE 4499


CMD ["./wisecow.sh"]