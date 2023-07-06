"""flask app for creating api"""
from subprocess import check_output
import urllib.request
import urllib.parse
import requests
import json
import secrets, string
from flask import Flask, render_template
from google.cloud import bigquery
import mysql.connector
from mysql.connector import Error
import psycopg2
from psycopg2.extras import RealDictCursor

print("Stuff")

def generateRandomPassword():
    letters = string.ascii_letters
    digits = string.digits
    alphabet = letters + digits
    pwd_length = 12
    pwd = ''
    for i in range(pwd_length):
        pwd += ''.join(secrets.choice(alphabet))
    
    return pwd

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

######################################################
######################################################
######################################################


@app.route("/k8s")
def k8_call():
    """Make call to all of ip addresses in file"""
    ip_list = open("../bucket/ip/k8s_addresses.json", encoding="utf-8")
    checkout_payload = {
        "email": "someone@example.com",
        "street_address": "1600 Amphitheatre Parkway",
        "zip_code": "94043",
        "city": "Mountain View",
        "state": "CA",
        "country": "United States",
        "credit_card_number": "4432-8015-6152-0454",
        "credit_card_expiration_month": "1",
        "credit_card_expiration_year": "2023",
        "credit_card_cvv": "672",
    }

    cart_loads = [
        {"product_id": "9SIQT8TOJO", "quantity": 1},
        {"product_id": "66VCHSJNUP", "quantity": 1},
        {"product_id": "1YMWWN1N4O", "quantity": 1},
        {"product_id": "L9ECAV7KIM", "quantity": 1},
        {"product_id": "2ZYFJ3GM2N", "quantity": 1},
        {"product_id": "0PUK6V6EV0", "quantity": 1},
        {"product_id": "LS4PSXUNUM", "quantity": 1},
        {"product_id": "9SIQT8TOJO", "quantity": 1},
        {"product_id": "6E92ZMYYFZ", "quantity": 1},
    ]
    try:
        ips = json.load(ip_list)

        data = ""
        for key in ips:
            session = requests.Session()
            data = session.get(f"http://{key['ip']}", timeout=30)

            for item in cart_loads:
                data = session.post(f"http://{key['ip']}/cart", data=item, timeout=30)

            data = session.post(
                f"http://{key['ip']}/cart/checkout", data=checkout_payload, timeout=30
            )

        return data.text

    # pylint: disable=broad-except;
    except Exception as call_error:
        # return {"error": call_error}t
        print(call_error)
        return "splat"


######################################################
######################################################
######################################################


@app.route("/")
def hello():
    """Simple HeathCheck"""

    return "Hello, World!"


######################################################
######################################################
######################################################


@app.route("/500")
def fivehundred():
    """Produce 500 error"""
    return "Tragedy", 500


######################################################
######################################################
######################################################


@app.route("/home")
def index():
    """Default Index"""
    return render_template("home.html")


######################################################
######################################################
######################################################


@app.route("/observe")
def get_shell_script_output_using_check_output():
    """Call linux host script setup"""
    stdout = check_output(["./some.sh"]).decode("utf-8")
    return stdout


######################################################
######################################################
######################################################


@app.route("/observeall")
def call_observe():
    """Make call to all of ip addresses in file"""
    ip_list = open("../bucket/ip/ip_addresses.json", encoding="utf-8")

    # returns JSON object as
    # a dictionary
    data = json.load(ip_list)

    data.keys()
    call_data = {"url1": [], "url2": [], "url3": []}
    for key in data.keys():
        print("key-", key)
        url2 = f"http://{data[key]}:8080/observe"

        print(data[key])

        new_data2 = callurl(url2)

        call_data["url2"].append({"url": url2, "response": new_data2})

        print(new_data2)
        # dict = json.loads(data)

    return call_data


######################################################
######################################################
######################################################


@app.route("/file")
def file():
    """Make call to all of ip addresses in file"""
    ip_list = open("../bucket/ip/ip_addresses.json", encoding="utf-8")

    # returns JSON object as
    # a dictionary
    data = json.load(ip_list)

    data.keys()
    call_data = {"url1": [], "url2": [], "url3": [], "url4": []}
    for key in data.keys():
        print("key-", key)
        url1 = f"http://{data[key]}:8080"
        url2 = f"http://{data[key]}:8080/mysql"
        url3 = f"http://{data[key]}:8080/postgres"
        url4 = f"http://{data[key]}:8080/bigquery"
        url5 = f"http://{data[key]}:8080/k8s"

        print(data[key])

        new_data = callurl(url1)
        new_data2 = callurl(url2)
        new_data3 = callurl(url3)
        new_data4 = callurl(url4)
        new_data5 = callurl(url5)

        call_data["url1"].append({"url": url1, "response": new_data})
        call_data["url2"].append({"url": url2, "response": new_data2})
        call_data["url3"].append({"url": url3, "response": new_data3})
        call_data["url4"].append({"url": url4, "response": new_data4})
        call_data["url5"].append({"url": url5, "response": new_data5})

        print(new_data)
        # dict = json.loads(data)

    return call_data


######################################################
######################################################
######################################################


@app.route("/bigquery")
def query():
    """Call biqquery"""
    print("called")
    print(f"BigQuery version: {bigquery.__version__}")

    ip_list = open("../bucket/ip/bigquery_addresses.json", encoding="utf-8")
    table_connections = json.load(ip_list)

    result_dict = []

    # pylint: disable=too-many-nested-blocks;
    for key in table_connections:

        client = bigquery.Client()

        big_query_table = key["bigquery_table"]
        # "content-testpproj-stage-1.test_stg_dataset.test-stg-table"

        print("client")
        query_job = client.query(
            f"""
            insert into `{big_query_table}`
            (permalink,state, timestamp)
            values (
            "test", "test", CURRENT_DATETIME()
            )
            """
        )
        print("before")

        query_job = client.query(
            f"""
            select permalink,state,timestamp 
            from `{big_query_table}`
            order by timestamp desc
            limit 10
            """
        )
        results = query_job.result()
        print("after")

        for row in results:
            # print("{} : {} views".format(row.url, row.view_count))
            print(row)
            result_dict.append(
                {
                    "big_query_table": big_query_table,
                    "permalink": row.permalink,
                    "state": row.state,
                    "timestamp": row.timestamp,
                }
            )
            print(result_dict)

    return result_dict


######################################################
######################################################
######################################################


@app.route("/mysql")
def mysql_call():
    """Call mysql instances"""
    db_data = {"databases": [], "tables": [], "data": []}

    ip_list = open("../bucket/ip/db_addresses.json", encoding="utf-8")
    db_connections = json.load(ip_list)
    # pylint: disable=too-many-nested-blocks;
    for key in db_connections:
        if "MYSQL" in key["db"]:
            print("key-", key["db"])

            try:
                connection = mysql.connector.connect(
                    host=key["host"],
                    database=key["database_name"],
                    user=key["username"],
                    #password=key["password"],
                    password=generateRandomPassword()
                )

                if connection.is_connected():
                    db_info = connection.get_server_info()

                    print("Connected to MySQL Server version ", db_info)
                    cursor = connection.cursor(dictionary=True)

                    cursor.execute("select database() as db;")

                    for data_bases in cursor:
                        print(data_bases)
                        db_data["databases"].append(
                            {
                                "instance": key["db"],
                                "host": key["host"],
                                "database": data_bases["db"],
                            }
                        )

                    cursor.execute(
                        """CREATE TABLE IF NOT EXISTS python_created(
                            task_id INT AUTO_INCREMENT PRIMARY KEY,
                            title VARCHAR(255) NOT NULL,
                            description TEXT,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                            );
                    """
                    )

                    cursor.execute(
                        "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'cloud_freak'"
                    )

                    for table in cursor:
                        print(table)
                        db_data["tables"].append(
                            {"instance": key["db"], "table": table["TABLE_NAME"]}
                        )

                    sql = "insert into python_created(title,description) values(%s, %s)"
                    val = ("Python is doing this", "call to database")
                    cursor.execute(sql, val)
                    connection.commit()

                    cursor.execute(
                        "select count(*) as record_count from python_created"
                    )

                    for data in cursor:
                        print(data)

                    cursor.execute(
                        # pylint: disable=line-too-long;
                        "select DATE_FORMAT(max(python_created.created_at),'%d/%m/%Y %l:%i %p') as last_created, DATE_FORMAT(min(python_created.created_at),'%d/%m/%Y %l:%i %p') as first_created, cnt.record_count as record_count from python_created cross join (select count(*) as record_count from python_created) as cnt group by cnt.record_count"
                    )

                    myresult = cursor.fetchall()

                    for data in myresult:
                        print(data)
                        db_data["data"].append(
                            {
                                "instance": key["db"],
                                "row": {
                                    "first_created": data["first_created"],
                                    "last_created": data["last_created"],
                                    "records": data["record_count"],
                                },
                            }
                        )

            except Error as call_error:
                print("Error while connecting to MySQL", call_error)
                return "call flamed"

            finally:
                if connection.is_connected():
                    cursor.close()
                    connection.close()
                    print("MySQL connection is closed")
        else:
            print("not mysql")
            # return db_Info

    return db_data


######################################################
######################################################
######################################################


@app.route("/postgres")
def postgres_call():
    """Call postgres instances"""
    db_data = {"databases": [], "tables": [], "data": []}

    ip_list = open("../bucket/ip/db_addresses.json", encoding="utf-8")
    db_connections = json.load(ip_list)

    for key in db_connections:
        if "POSTGRES" in key["db"]:
            print("key-", key["db"])

            try:

                # Connect to an existing database
                connection = psycopg2.connect(
                    # pylint: disable=line-too-long;
                    #f"dbname={key['database_name']} user={key['username']} host={key['host']} password={key['password']}"
                    f"dbname={key['database_name']} user={key['username']} host={key['host']} password={generateRandomPassword()}"
                )

                if connection.closed == 0:
                    # Open a cursor to perform database operations

                    cursor = connection.cursor(cursor_factory=RealDictCursor)

                    cursor.execute("SHOW SERVER_VERSION;")

                    # print("Connected to MySQL Server version ", db_Info)

                    for server in cursor:
                        print(server)
                    # Execute a command: this creates a new table

                    cursor.execute(
                        # pylint: disable=line-too-long;
                        "SELECT datname FROM pg_database WHERE datistemplate = false and datname not in('cloudsqladmin', 'postgres');"
                    )

                    for data_bases in cursor:
                        print(data_bases)
                        db_data["databases"].append(
                            {
                                "instance": key["db"],
                                "host": key["host"],
                                "database": data_bases["datname"],
                            }
                        )

                    cursor.execute(
                        """CREATE TABLE IF NOT EXISTS python_created(
                            task_id SERIAL PRIMARY KEY,
                            title VARCHAR(255) NOT NULL,
                            description TEXT,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                            );
                    """
                    )

                    cursor.execute(
                        # pylint: disable=line-too-long;
                        "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'public'"
                    )

                    for table in cursor:
                        print("table", table)
                        db_data["tables"].append(
                            {"instance": key["db"], "table": table["table_name"]}
                        )

                    sql = "insert into python_created(title,description) values(%s, %s)"
                    val = ("Python is doing this", "call to database")
                    cursor.execute(sql, val)
                    connection.commit()

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
                                "instance": key["db"],
                                "row": {
                                    "first_created": data["first_created"],
                                    "last_created": data["last_created"],
                                    "records": data["record_count"],
                                },
                            }
                        )

            except Error as call_error:
                print("Error while connecting to POSTGRES", call_error)
                return "call flamed"

            finally:
                if connection.closed == 0:
                    cursor.close()
                    connection.close()
                    print("POSTGRES connection is closed")
        else:
            print("not postgres")
            # return db_Info

    return db_data


if __name__ == "__main__":
    app.run(debug=True)
