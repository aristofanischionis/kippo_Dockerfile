# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' app
USER app

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Switch back to root to install dependencies
USER root

# Install necessary packages and clean up
RUN apt-get update && apt-get install -y \
    python-dev=2.7.* \
    build-essential=* \
    mariadb-client=* \
    libmariadbclient-dev=* && \
    rm -rf /var/lib/apt/lists/*

# Create the data and log directory and set their permissions
RUN mkdir -p /app/data /app/log /app/log/tty && \
    chown -R 777 /app/log/tty && \
    chown -R app:app /app/data /app/log

# Install Python packages
RUN pip install --no-cache-dir zope.interface==5.5.2 Twisted==15.1.0 pycrypto==2.6.1 pyasn1==0.5.0

# Switch back to the non-root user
USER app

# Make port 2222 available to the world outside thiscontainer
EXPOSE 2222

# Run twistd command when the container launches
CMD ["twistd", "-n", "-y", "kippo.tac", "-l", "log/kippo.log", "--pidfile", "kippo.pid"]
