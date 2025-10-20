# OpenShift-friendly Python container
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Add model and API
COPY model.pkl /app/model.pkl
COPY api.py /app/api.py

# OpenShift runs as an arbitrary UID; make directories world-readable
RUN chmod -R g=u /app

ENV PORT=8080
EXPOSE 8080

CMD ["gunicorn","-b","0.0.0.0:8080","api:app"]
