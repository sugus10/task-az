#!/bin/bash

# Azure App Service startup script for Python Flask app
echo "Starting Azure CRUD Application..."

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Start the application with Gunicorn
echo "Starting Gunicorn server..."
gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 app:app