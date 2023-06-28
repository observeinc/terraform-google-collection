# Execute with "--build-arg PROJECT_ID=$PROJECT_ID"
ARG PROJECT_ID=YOURPROJECTID
FROM grafana/k6

COPY avocano.js ./
ENTRYPOINT k6 run avocano.js
