import redis
import json
import time
import os
import tracing
import traceback
import typing
import sys
from google.cloud import bigquery


# based on Luke's work here - https://github.com/observeinc/google-cloud-functions/blob/main/main.py
def main(request) -> typing.List[dict]:
    """Call biqquery"""
    my_trace = tracing.tracer

    res = []
    try:
        print("called")
        print(f"BigQuery version: {bigquery.__version__}")

        is_str = isinstance(request, str)
        if is_str == True:
            print(is_str)
            print(request)
            jstr = json.loads(request)

        if is_str == False:
            jstr = request.get_json()

        method = jstr["method"]
        biq_query_table = jstr["biq_query_table"]
        print(f"method = {method}")
        print(f"biq_query_table = {biq_query_table}")
        # example - "content-testpproj-stage-1.test_stg_dataset.test-stg-table"

        with my_trace.start_as_current_span(f"{method}bigquery") as span:
            span.set_attribute("BIQ_QUERY_TABLE", biq_query_table)

    except Exception as e:
        print("ERROR")
        print(e)
        with my_trace.start_as_current_span("bigquery ERROR") as span:
            span.set_attribute("ERROR", e)
        print(repr(e))
        return repr(e), 500

    client = bigquery.Client()

    if method == "error":
        try:
            raise ValueError("A very specific bad thing happened")
        except Exception as e:
            print(repr(e))
            return repr(e), 500

    if method == "write":

        t = time.time()
        ml = int(t * 1000)

        start_string = f"""
insert into `{biq_query_table}`
(id,name, timestamp)
values (
"start", "start", CURRENT_DATETIME()
),
        """
        # create a set of fake keys and values based on current time
        range_num = 10
        for number in range(range_num):
            part1 = f'("{ml}-{number}", "Name-{ml}-{number}", CURRENT_DATETIME())'
            if number == (range_num - 1):
                part2 = ""
            else:
                part2 = ",\n"
            start_string = start_string + part1 + part2

        print(start_string)
        insert_job = client.query(start_string)
        results = insert_job.result()
        return "OK", 200

    if method == "read":
        query_job = client.query(
            f"""
                select count(*)
                from `{biq_query_table}`
                """
        )
        results = query_job.result()

        with my_trace.start_as_current_span(f"{method}bigquery") as span:
            span.set_attribute("BIQ_QUERY_TABLE", biq_query_table)
            span.set_attribute("results", results)
        return "OK", 200


if __name__ == "__main__":
    args = len(sys.argv)

    if args == 1:
        print("Need 1 args")
    elif args == 2:
        request = sys.argv[1]
    else:
        print("Need 1 args")
        exit()

    print(sys.argv)
    print(f"args={args}")
    main(request)


# '{"method": "write","biq_query_table": "content-eng-sample-infra.sample_infra_dataset.sample-infra-table-2",}'
