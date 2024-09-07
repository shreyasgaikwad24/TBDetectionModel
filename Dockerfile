# Use a base image with Miniconda
FROM continuumio/miniconda3

# Set the working directory
WORKDIR /app

# Copy the environment YAML file into the Docker image
COPY dl.yaml /app/dl.yaml

# Create the Conda environment
RUN conda env create -f dl.yaml

# Activate the environment and ensure it's activated when the container starts
RUN echo "source activate tb" > ~/.bashrc
ENV PATH /opt/conda/envs/tb/bin:$PATH

# Copy your Python script into the Docker image
COPY main.py /app/main.py

# Set the default command to run your Python script
CMD ["python", "main.py"]