from google.cloud import bigquery
admin_project_id = "terraflood-345116"
client = bigquery.Client(project=admin_project_id)

print("client")
print(f"BigQuery version: {bigquery.__version__}")
result_dict = []

query_job = client.query(
    """
    SELECT
    CONCAT(
        'https://stackoverflow.com/questions/',
        CAST(id as STRING)) as url,
    view_count
    FROM `bigquery-public-data.stackoverflow.posts_questions`
    WHERE tags like '%google-bigquery%'
    ORDER BY view_count DESC
    LIMIT 10"""
)
print("before")
results = query_job.result()
print("after")

for row in results:
    result_dict.append({"url": row.url, "count": row.view_count})

print(result_dict)
