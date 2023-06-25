import json
import tracing
import traceback
import os
import typing
import sys
import psycopg2
from psycopg2.extras import RealDictCursor


postgres_host = os.getenv("POSTGRES_HOST")
postgres_dbname = os.getenv("POSTGRES_DBNAME")
postgres_user = os.getenv("POSTGRES_USER")
postgres_password = os.getenv("POSTGRES_PASSWORD")


def main(request) -> typing.List[dict]:
    """Call postgres instances"""
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

    with my_trace.start_as_current_span(f"{method}-postgres") as span:
        span.set_attribute("postgres_host", postgres_host)
        span.set_attribute("postgres_dbname", postgres_dbname)

        try:
            # Connect to an existing database
            connection = psycopg2.connect(
                # pylint: disable=line-too-long;
                f"dbname={postgres_dbname} user={postgres_user} host={postgres_host} password={postgres_password}"
            )

            if connection.closed == 0:
                # Open a cursor to perform database operations

                cursor = connection.cursor(cursor_factory=RealDictCursor)

                cursor.execute("SHOW SERVER_VERSION;")

                postgres_server = ""
                for server in cursor:
                    print("A")
                    postgres_server = server["server_version"]
                    print(postgres_server)
                    print("B")

                with my_trace.start_as_current_span(f"connection-postgres") as span:
                    span.set_attribute(
                        "Connected to Postgres Server version ", postgres_server
                    )
                    print("C")
                    # print("Connected to MySQL Server version ", db_Info)

                    # Execute a command: this creates a new table

                    cursor.execute(
                        # pylint: disable=line-too-long;
                        "SELECT datname FROM pg_database WHERE datistemplate = false and datname not in('cloudsqladmin', 'postgres');"
                    )

                    for data_bases in cursor:
                        print(data_bases)
                        db_data["databases"].append(
                            {
                                "instance": postgres_dbname,
                                "host": postgres_host,
                                "database": data_bases["datname"],
                            }
                        )
                    span.set_attribute("databases", str(db_data["databases"]))
                    if method == "write":
                        with my_trace.start_as_current_span(
                            f"createtable-postgres"
                        ) as span:

                            cursor.execute(
                                """CREATE TABLE IF NOT EXISTS python_created(
                                    task_id SERIAL PRIMARY KEY,
                                    title VARCHAR(255) NOT NULL,
                                    description TEXT,
                                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                                    );
                            """
                            )

                            with my_trace.start_as_current_span(
                                f"insert-table-postgres"
                            ) as span:
                                sql = "insert into python_created(title,description) values(%s, %s)"
                                val = ("Python is doing this", "call to database")
                                cursor.execute(sql, val)
                                connection.commit()
                                span.set_attribute("Result", "Success")
                                return "SUCCESS", 200

                    if method == "read":
                        cursor.execute(
                            # pylint: disable=line-too-long;
                            "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'public'"
                        )

                        for table in cursor:
                            print("table", table)
                            db_data["tables"].append(
                                {
                                    "instance": postgres_dbname,
                                    "table": table["table_name"],
                                }
                            )

                        cursor.execute(
                            "select count(*) as record_count from python_created"
                        )

                        for data in cursor:
                            print(data)

                        cursor.execute(
                            # pylint: disable=line-too-long;
                            "select to_char(max(python_created.created_at),'DD/Mon/YYYY HH12:MI:SS') as last_created, to_char(min(python_created.created_at),'DD/Mon/YYYY HH12:MI:SS') as first_created, cnt.record_count as record_count from python_created cross join (select count(*) as record_count from python_created) as cnt group by cnt.record_count"
                        )

                        myresult = cursor.fetchall()

                        for data in myresult:
                            print(data)
                            db_data["data"].append(
                                {
                                    "instance": postgres_dbname,
                                    "row": {
                                        "first_created": data["first_created"],
                                        "last_created": data["last_created"],
                                        "records": data["record_count"],
                                    },
                                }
                            )

        except Exception as call_error:
            print("Error while connecting to POSTGRES", call_error)
            with my_trace.start_as_current_span("mysql ERROR") as span:
                span.set_attribute("ERROR", call_error)
            print(repr(call_error))
            return repr(call_error), 500

        finally:
            if connection.closed == 0:
                cursor.close()
                connection.close()
                print("POSTGRES connection is closed")
            else:
                print("not postgres")
                # return db_Info

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
