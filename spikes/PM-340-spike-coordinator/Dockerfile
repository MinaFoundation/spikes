# Use the official Python image
FROM python:latest

# Create a directory for your application
RUN mkdir /app

# Copy your Python files into the container
COPY *.py /app/
COPY requirements.txt /app/

# Set the working directory
WORKDIR /app

# Install Python dependencies from requirements.txt
RUN pip install -r requirements.txt

# Expose the port your application will listen on
EXPOSE 8080
