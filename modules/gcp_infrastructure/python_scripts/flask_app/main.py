"""flask app for creating api"""
from subprocess import check_output
import urllib.request
import urllib.parse
import requests
import json
from flask import Flask, render_template, request
from google.cloud import bigquery
import mysql.connector
from mysql.connector import Error
import psycopg2
from psycopg2.extras import RealDictCursor

print("Flask App Statrtup")


def callurl(url):
    """Call a url and return response"""

    try:
        response = urllib.request.urlopen(url)
        new_data = response.read()

        return new_data
    # pylint: disable=broad-except;
    except Exception as call_error:
        return {"error": response}


app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def hello():
    """Simple HeathCheck"""

    return "Do you know what you are doing?"


@app.route("/bigquery_add_ip", methods=["POST"])
def add_ip():
    """Call biqquery"""
    print("called")
    print(f"BigQuery version: {bigquery.__version__}")

    print(request.form["biq_query_table"])
    table_connection = request.form["biq_query_table"]
    print(table_connection)
    # example - "content-testpproj-stage-1.test_stg_dataset.test-stg-table"

    # ip_list = open("../bucket/ip/bigquery_addresses.json", encoding="utf-8")
    # table_connections = json.load(ip_list)

    # result_dict = []

    # # pylint: disable=too-many-nested-blocks;
    # for key in table_connections:

    client = bigquery.Client()

    print("client")
    insert_job = client.query(
        f"""
        insert into `{table_connection}`
        (ip_address,resource_name, timestamp)
        values (
        "test", "test", CURRENT_DATETIME()
        )
        """
    )
    results = insert_job.result()
    print(results)

    #     query_job = client.query(
    #         f"""
    #         select permalink,state,timestamp
    #         from `{big_query_table}`
    #         order by timestamp desc
    #         limit 10
    #         """
    #     )
    #     results = query_job.result()
    #     print("after")

    #     for row in results:
    #         # print("{} : {} views".format(row.url, row.view_count))
    #         print(row)
    #         result_dict.append(
    #             {
    #                 "big_query_table": big_query_table,
    #                 "permalink": row.permalink,
    #                 "state": row.state,
    #                 "timestamp": row.timestamp,
    #             }
    #         )
    #         print(result_dict)

    return "OK"
