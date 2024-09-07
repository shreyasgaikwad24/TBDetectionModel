# Use a base image with Miniconda installed
FROM continuumio/miniconda3

# Set the working directory
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the environment YAML file into the container
COPY dl.yaml .

# Use bash shell for the RUN command
SHELL ["/bin/bash", "-c"]

# Run conda search to find the available versions of each conda package and update the dl.yaml file
RUN while read -r line; do \
      if [[ "$line" == -* && "$line" != *pip:* ]]; then \
        package=$(echo "$line" | cut -d'=' -f1 | tr -d ' -'); \
        version=$(conda search "$package" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+=[a-z0-9_]+' | head -n 1); \
        if [[ -n "$version" ]]; then \
          sed -i.bak "s/$package=[^ ]*/$package=$version/" dl.yaml; \
        fi; \
      fi; \
    done < <(grep -E '^- ' dl.yaml)

# Create the conda environment from the updated YAML file
RUN conda env create -f dl.yaml

# Activate the environment and ensure it's activated when the container starts
RUN echo "source activate tb" > ~/.bashrc
ENV PATH /opt/conda/envs/tb/bin:$PATH

# Install pip dependencies separately to handle potential issues
COPY requirements.txt .
RUN conda run -n tb pip install -r requirements.txt

# Copy your Python script into the Docker image
COPY main.py /app/main.py

# Set the default command to run your Python script
CMD ["conda", "run", "-n", "tb", "python", "main.py"]