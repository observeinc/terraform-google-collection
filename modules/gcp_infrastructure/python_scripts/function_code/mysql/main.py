import typing
import sys
import mysql.connector
from mysql.connector import Error
import json
import tracing
import traceback
import os

from opentelemetry.instrumentation.mysql import MySQLInstrumentor


mysql_host = os.getenv("MYSQL_HOST")
mysql_dbname = os.getenv("MYSQL_DBNAME")
mysql_user = os.getenv("MYSQL_USER")
mysql_password = os.getenv("MYSQL_PASSWORD")


def main(request) -> typing.List[dict]:
    """Call mysql instances"""
    my_trace = tracing.tracer
    db_data = {"databases": [], "tables": [], "data": []}

    is_str = isinstance(request, str)
    if is_str == True:
        print(is_str)
        print(request)
        jstr = json.loads(request)

    if is_str == False:
        jstr = request.get_json()

    method = jstr["method"]

    # pylint: disable=too-many-nested-blocks;
    with my_trace.start_as_current_span(f"{method}-mysql") as span:
        span.set_attribute("mysql_host", mysql_host)
        span.set_attribute("mysql_dbname", mysql_dbname)

        try:
            print("called")

            is_str = isinstance(request, str)
            if is_str == True:
                print(is_str)
                print(request)
                jstr = json.loads(request)

            if is_str == False:
                jstr = request.get_json()

            method = jstr["method"]

            # example - "content-testpproj-stage-1.test_stg_dataset.test-stg-table"

        except Exception as e:
            print("ERROR")
            print(e)
            with my_trace.start_as_current_span("mysql ERROR") as span:
                span.set_attribute("ERROR", e)
            print(repr(e))
            return repr(e), 500

        try:
            connection = MySQLInstrumentor().instrument_connection(
                mysql.connector.connect(
                    host=mysql_host,
                    database=mysql_dbname,
                    user=mysql_user,
                    password=mysql_password,
                )
            )
            # MySQLInstrumentor().instrument_connection(connection, my_trace)
            if connection.is_connected():
                db_info = connection.get_server_info()
                with my_trace.start_as_current_span(f"connection-mysql") as span:
                    span.add_event(f"Connected to MySQL Server version {db_info}")
                    # span.set_attribute("Connected to MySQL Server version ", db_info)

                    print("Connected to MySQL Server version ", db_info)
                    cursor = connection.cursor(dictionary=True)

                    cursor.execute("select database() as db;")

                    for data_bases in cursor:
                        print(data_bases)
                        db_data["databases"].append(
                            {
                                "instance": mysql_dbname,
                                "host": mysql_host,
                                "database": data_bases["db"],
                            }
                        )

                if method == "write":
                    with my_trace.start_as_current_span(f"createtable-mysql") as span:

                        cursor.execute(
                            """CREATE TABLE IF NOT EXISTS python_created(
                                task_id INT AUTO_INCREMENT PRIMARY KEY,
                                title VARCHAR(255) NOT NULL,
                                description TEXT,
                                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                                );
                        """
                        )

                        with my_trace.start_as_current_span(
                            f"insert-table-mysql"
                        ) as span:
                            sql = "insert into python_created(title,description) values(%s, %s)"
                            val = ("Python is doing this", "call to database")
                            rtn = cursor.execute(sql, val)
                            connection.commit()
                            span.add_event("Success")
                            span.add_event("THIS SHOULD SHOW UP WRITE")
                            # span.set_attribute("Result", "Success")
                            return "SUCCESS", 200

                if method == "read":
                    with my_trace.start_as_current_span(f"readtables-mysql") as span:
                        cursor.execute(
                            "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'cloud_freak'"
                        )

                        for table in cursor:
                            print(table)
                            db_data["tables"].append(
                                {"instance": mysql_dbname, "table": table["TABLE_NAME"]}
                            )

                            cursor.execute(
                                "select count(*) as record_count from python_created"
                            )

                            for data in cursor:
                                print(data)

                            span.add_event("Read rows in python created table")
                            cursor.execute(
                                # pylint: disable=line-too-long;
                                "select DATE_FORMAT(max(python_created.created_at),'%d/%m/%Y %l:%i %p') as last_created, DATE_FORMAT(min(python_created.created_at),'%d/%m/%Y %l:%i %p') as first_created, cnt.record_count as record_count from python_created cross join (select count(*) as record_count from python_created) as cnt group by cnt.record_count"
                            )

                            myresult = cursor.fetchall()

                            for data in myresult:
                                print(data)
                                db_data["data"].append(
                                    {
                                        "instance": mysql_dbname,
                                        "row": {
                                            "first_created": data["first_created"],
                                            "last_created": data["last_created"],
                                            "records": data["record_count"],
                                        },
                                    }
                                )
                            span.add_event(str(db_data))
                            span.add_event("THIS SHOULD SHOW UP")
                            return db_data, 200

        except Error as call_error:
            print("Error while connecting to MySQL", call_error)
            print(repr(e))
            return repr(e), 500

        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                print("MySQL connection is closed")
            else:
                print("not mysql")

            return "Finally OK", 200


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
