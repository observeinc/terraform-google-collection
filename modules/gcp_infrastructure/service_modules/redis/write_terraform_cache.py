#!/usr/bin/env python3

# ./write_terraform.py 41144592 ../service/compute/computeDashboard.tf

# ./write_terraform.py 41145294 ../service/cloudsql/cloudSQLDashboard.tf

# ./write_terraform.py 41144640 ../projectsDashboard.tf

# ./write_terraform.py -d 41144640 -e hagrid-staging -n projectsDashboard.tf -c "/Users/Hagrid/github.com/content-eng-tools/auto-magical-dashboard/config.ini"
# ^ useful for aliasing like so: tfdash="/Users/Hagrid/github.com/content-eng-tools/auto-magical-dashboard/write_terraform.py -e hagrid-staging -c \"/Users/Hagrid/github.com/content-eng-tools/auto-magical-dashboard/config.ini\" -d"
# ^ with this alias, all you type is `tfdash 123456 -n myfancydash.tf` from any terminal

# see https://github.com/observeinc/content-eng-tools/blob/main/engage_datasets/config/configfile.ini for example config file

"""This file is for converting json produced by getTerraform GraphQL method"""

import json
import sys
import os
import configparser
import re
import subprocess
import argparse
import logging

import redis
import tracing
import traceback
import typing
import time

try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests
try:
    from gql import gql, Client
    from gql.transport.requests import RequestsHTTPTransport
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "gql"])
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests-toolbelt"])
    from gql import gql, Client
    from gql.transport.requests import RequestsHTTPTransport

redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", 6379))
redis_password = ""

try:
    # The decode_repsonses flag here directs the client to convert the responses from Redis into Python strings
    # using the default encoding utf-8.  This is client specific.
    r = redis.StrictRedis(
        host=redis_host,
        port=redis_port,
        password=redis_password,
        decode_responses=True,
    )


except Exception as e:
    print("Error in connecting to redis")
    print(e)
    # return e

###############################################################################
###############################################################################


def getObserveConfig(config, environment, my_trace):
    """Fetches config file"""
    with my_trace.start_as_current_span("getObserveConfig") as child:
        child.set_attribute("config_path", args.config_path)
        # Set your Observe environment details in config\configfile.ini
        configuration = configparser.ConfigParser()
        configuration.read(args.config_path)
        observe_configuration = configuration[environment]

        return observe_configuration[config]


###############################################################################
###############################################################################


def get_bearer_token(my_trace):
    """Gets bearer token for login"""
    with my_trace.start_as_current_span("get_bearer_token") as child:
        child.set_attribute("domain", domain)
        child.set_attribute("customer_id", customer_id)

        url = f"https://{customer_id}.{domain}.com/v1/login"
        user_email = getObserveConfig("user_email", ENVIRONMENT, my_trace)
        user_password = getObserveConfig("user_password", ENVIRONMENT, my_trace)

        message = '{"user_email":"$user_email$","user_password":"$user_password$"}'

        tokens_to_replace = {
            "$user_email$": user_email,
            "$user_password$": user_password,
        }

        for key, value in tokens_to_replace.items():
            message = message.replace(key, value)

        header = {
            "Content-Type": "application/json",
        }

        response = json.loads(
            requests.post(url, data=message, headers=header, timeout=10).text
        )
        bear_toke = response["access_key"]
        return bear_toke


###############################################################################
###############################################################################


def get_ids(file_name, my_trace):
    """gets unique set of ids that need to be replaced in terraform def"""
    with my_trace.start_as_current_span("get_ids") as child:
        child.set_attribute("file_name", file_name)
        my_list = []
        lines = []
        # read file
        with open(file_name, "r", encoding="utf-8") as fp:
            # read and store all lines into list
            lines = fp.readlines()

        for _, line in enumerate(lines):
            if "datasetId" in line or "keyForDatasetId" in line:
                my_list = my_list + re.findall('"([^"]*)"', line)

        # convert to dict to eliminate duplicate values and then back to list
        my_list = list(dict.fromkeys(my_list))

        return my_list


###############################################################################
###############################################################################


def get_dashboard_terraform(dashboard_id, output_file_name, my_trace):
    """get dashboard terraform from graphql"""
    with my_trace.start_as_current_span("get_dashboard_terraform") as child:
        params = {"dashboard_id": f"{dashboard_id}"}
        paramskey = f"dashboardtf-{str(params)}"
        dashboard_cache_hit = r.get(str(paramskey))

        child.set_attribute("paramskey", paramskey)

        if dashboard_cache_hit is not None:
            print(f"Dashboard Terraform Cache Hit")
            child.set_attribute("cache_hit", "true")
            file_string = dashboard_cache_hit
        else:
            child.set_attribute("cache_hit", "false")
            toke = BEARERTOKEN
            customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
            # Create a GraphQL client using the defined transport
            client = Client(
                transport=RequestsHTTPTransport(
                    url=META_URL,
                    retries=3,
                    headers={"Authorization": f"""Bearer {customer_id} {toke}"""},
                ),
                fetch_schema_from_transport=True,
            )

            # Provide a GraphQL query
            query = gql(
                """
                    query terraform($dashboard_id: ObjectId!) {
                        getTerraform( id:$dashboard_id, type: Dashboard){
                        resource
                        }
                    }
                    """
            )

            # Execute the query on the transport
            try:
                result = client.execute(query, variable_values=params)
                file_string = result["getTerraform"]["resource"]
                print("caching dashboard string")
                r.set(paramskey, str(result["getTerraform"]["resource"]), ex=key_expiry)
            except Exception as e:
                print(str(e))

        original_stdout = sys.stdout

        # write results to file
        with open(output_file_name, "w", encoding="utf-8") as outfile:
            sys.stdout = outfile  # Change the standard output to the file we created.
            # pylint: disable=unsubscriptable-object;
            print(file_string)
            sys.stdout = original_stdout  #


###############################################################################
###############################################################################


def get_dashboard_name(dashboard_id, my_trace):
    """get dashboard terraform from graphql"""
    with my_trace.start_as_current_span("get_dashboard_name") as child:
        params = {
            "dashboard_id": f"{dashboard_id}",
        }

        paramskey = f"dashboardname-{str(params)}"

        child.set_attribute("paramskey", paramskey)

        cache_hit = r.get(str(paramskey))

        if cache_hit is not None:
            print(f"Dashboard Name Cache Hit - {cache_hit}")
            child.set_attribute("cache_hit", "true")
            return cache_hit
        else:
            child.set_attribute("cache_hit", "false")
            toke = BEARERTOKEN
            customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
            # Create a GraphQL client using the defined transport
            client = Client(
                transport=RequestsHTTPTransport(
                    url=META_URL,
                    retries=3,
                    headers={"Authorization": f"""Bearer {customer_id} {toke}"""},
                ),
                fetch_schema_from_transport=True,
            )

            # Provide a GraphQL query
            query = gql(
                """
                query dashboard($dashboard_id: ObjectId!){
                dashboard(id:$dashboard_id){
                    name
                }
                }
                """
            )

            params = {
                "dashboard_id": f"{dashboard_id}",
            }
            # Execute the query on the transport
            result = client.execute(query, variable_values=params)
            # pylint: disable=unsubscriptable-object;
            print("caching dashboard name")
            r.set(str(paramskey), result["dashboard"]["name"], ex=key_expiry)
            return result["dashboard"]["name"]


###############################################################################
###############################################################################


def get_dataset_terraform(dataset_id, my_trace):
    """get dashboard terraform from graphql"""
    with my_trace.start_as_current_span("get_dataset_terraform") as child:
        params = {
            "dataset_id": f"{dataset_id}",
        }
        paramskey = f"datasettf-{str(params)}"

        child.set_attribute("paramskey", paramskey)

        dataset_cache_hit = r.get(str(paramskey))

        if dataset_cache_hit is not None:
            print(f"Dataset Terrafom Cache Hit")
            child.set_attribute("cache_hit", "true")
            return json.loads(dataset_cache_hit)
        else:
            child.set_attribute("cache_hit", "false")
            toke = BEARERTOKEN
            customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
            # Create a GraphQL client using the defined transport
            client = Client(
                transport=RequestsHTTPTransport(
                    url=META_URL,
                    retries=3,
                    headers={"Authorization": f"""Bearer {customer_id} {toke}"""},
                ),
                fetch_schema_from_transport=True,
            )

            # Provide a GraphQL query
            query = gql(
                """
                query dataset ($dataset_id: ObjectId!){
                    getTerraform(id:$dataset_id, type: Dataset) {
                    dataSource
                    importName
                    }
                }
                """
            )

            # Execute the query on the transport
            # print(params)
            # print(len(params["dataset_id"]))
            if len(params["dataset_id"]) == 8:
                try:

                    result = client.execute(query, variable_values=params)
                    print("caching dataset string")
                    r.set(paramskey, json.dumps(result), ex=key_expiry)

                    return result
                except:
                    return None
            else:
                return None


###############################################################################
###############################################################################


def get_dashboard_ids(my_trace):
    with my_trace.start_as_current_span("get_dashboard_ids") as child:
        params = {"terms": {"workspaceId": [f"{WORKSPACE_ID}"], "name": "GCP/"}}
        paramskey = f"dashboardids-{str(params)}"

        child.set_attribute("paramskey", paramskey)

        dashboard_id_cache_hit = r.get(str(paramskey))

        if dashboard_id_cache_hit is not None:
            print(f"Dashboard IDs Cache Hit")
            child.set_attribute("cache_hit", "true")
            return json.loads(dashboard_id_cache_hit)
        else:
            child.set_attribute("cache_hit", "false")
            toke = BEARERTOKEN
            customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
            # Create a GraphQL client using the defined transport
            client = Client(
                transport=RequestsHTTPTransport(
                    url=META_URL,
                    retries=3,
                    headers={"Authorization": f"""Bearer {customer_id} {toke}"""},
                ),
                fetch_schema_from_transport=True,
            )

            # Provide a GraphQL query
            query = gql(
                """
                    query DashboardSearch($terms: DWSearchInput!, $maxCount: Int64) {
                    dashboardSearch(terms: $terms, maxCount: $maxCount) {
                        dashboards {
                        dashboard {
                            ...DashboardSummary
                        }
                        }
                    }
                    }

                    fragment DashboardSummary on Dashboard {
                    ...WorkspaceEntity
                    }

                    fragment WorkspaceEntity on WorkspaceObject {
                    id
                    name
                    }
                    """
            )

            # Execute the query on the transport
            result = client.execute(query, variable_values=params)
            print("caching dashboard ids")
            r.set(
                paramskey,
                json.dumps(result["dashboardSearch"]["dashboards"]),
                ex=key_expiry,
            )

            return result["dashboardSearch"]["dashboards"]


#########################################################################
#########################################################################
def write_dashboard(my_trace):
    """Used to write terraform file"""
    # pylint: disable=invalid-name;

    with my_trace.start_as_current_span("write_dashboard_function") as child:

        child.set_attribute("REDIS_HOST", redis_host)
        child.set_attribute("REDIS_PORT", redis_port)

        TMP_FILE_NAME = f"""{OUTPUTFILENAME_BASE}_tmp"""

        db_ids = get_dashboard_ids(my_trace)

        for dashboard in db_ids:
            print(dashboard["dashboard"]["id"])
            DASHBOARD_ID = dashboard["dashboard"]["id"]
            OUTPUTFILENAME = OUTPUTFILENAME_BASE.replace(".tf", f"{DASHBOARD_ID}.tf")
            # writes to temp file
            get_dashboard_terraform(DASHBOARD_ID, TMP_FILE_NAME, my_trace)

            DASHBOARD_NAME = get_dashboard_name(DASHBOARD_ID, my_trace)

            # gets list of unique dataset ids to replace
            ids_to_replace = get_ids(TMP_FILE_NAME, my_trace)

            # dict for stuff we are replacing
            stuff_to_replace_dict = {"datasets": []}

            # each dataset id
            for dataset_id in ids_to_replace:
                # get dataset terraform
                result = get_dataset_terraform(dataset_id, my_trace)

                if result is not None:
                    dataset_obj = {}

                    dataset_obj["dataset_id"] = dataset_id
                    # pylint: disable=unsubscriptable-object;
                    dataset_obj["variable_name"] = result["getTerraform"]["importName"]
                    print(result["getTerraform"]["importName"])
                    # pylint: disable=unsubscriptable-object;
                    dataset_obj["terraform"] = result["getTerraform"]["dataSource"]

                    stuff_to_replace_dict["datasets"].append(dataset_obj)

            original_stdout = sys.stdout

            # local to write to file
            locals_def = []
            locals_def.append("locals {")
            locals_def.append("workspace = var.workspace.oid")
            locals_def.append(
                f"""dashboard_name = format(var.name_format, "{DASHBOARD_NAME}")"""
            )

            workspace_oid = None

            for line in stuff_to_replace_dict["datasets"]:
                # local variable name
                variable_name = line["variable_name"]
                # add to list to write to file
                locals_def.append(
                    f"""{variable_name} = resource.observe_dataset.{variable_name}.id"""
                )
                # get worspace and name for replacement with variables
                workspace_oid = re.findall(
                    'workspace[^"]*("[^"]*")', line["terraform"]
                )[0]
                name = re.findall('name[^"]*("[^"]*")', line["terraform"])[0]

                # replace
                line["terraform"] = line["terraform"].replace(
                    workspace_oid,
                    f"local.workspace \n depends_on = [ resource.observe_dataset.{variable_name}]",
                )
                line["terraform"] = line["terraform"].replace(
                    name, f"""format(var.name_format, {name})"""
                )
            locals_def.append("}")

            # write everything to final terraform file
            with open(OUTPUTFILENAME, "w", encoding="utf-8") as outfile:
                sys.stdout = (
                    outfile  # Change the standard output to the file we created.
                )

                # write local variable definitions
                for local_line in locals_def:
                    print(local_line)

                sys.stdout = original_stdout  #

            dashboard_lines = []

            # read dashboard temp file into lines
            with open(TMP_FILE_NAME, "r", encoding="utf-8") as fp:
                # read an store all lines into list
                dashboard_lines = fp.readlines()

            # replace dataset ids with variable and write to file
            with open(OUTPUTFILENAME, "a", encoding="utf-8") as fp:

                for _, line in enumerate(dashboard_lines):

                    for dataset_line in stuff_to_replace_dict["datasets"]:
                        # pylint: disable=line-too-long;
                        line = line.replace(
                            '"{0}"'.format(dataset_line["dataset_id"]),
                            "local.{0}".format(dataset_line["variable_name"]),
                        )

                    if workspace_oid is not None:
                        line = line.replace(workspace_oid, "local.workspace")

                    line = line.replace(DASHBOARD_NAME, "${local.dashboard_name}")

                    fp.write(line)
                    if 'resource "observe_dashboard"' in line:
                        fp.write("description = local.dashboard_description\n")

            os.remove(TMP_FILE_NAME)

            terraform_command = f"terraform fmt {OUTPUTFILENAME}"
            os.system(terraform_command)


#########################################################################
#########################################################################
parser = argparse.ArgumentParser(description="Observe UI to Terraform Object script")
parser.add_argument(
    "-d",
    dest="dash_id",
    action="store",
    required=False,
    help="integer ID for dashboard",
)

parser.add_argument(
    "-w",
    dest="workspace_id",
    action="store",
    required=True,
    help="integer ID for workspace",
)

parser.add_argument(
    "-o",
    dest="otel_trace_name",
    action="store",
    required=True,
    help="trace name for OTEL",
)

parser.add_argument(
    "-e",
    dest="env",
    action="store",
    help="name of environment set in config.ini file in brackets",
)
parser.add_argument(
    "-n",
    dest="output_name",
    action="store",
    help="(Optional) file name to output to. Default is output.tf",
)
parser.add_argument(
    "-t",
    dest="bearer_token",
    action="store",
    help="(Optional) Bearer token for authorization. Useful for SSO accounts",
)
parser.add_argument(
    "-v",
    dest="is_debug",
    default=False,
    action="store_true",
    help="(Optional) Enable debug logging",
)
parser.add_argument(
    "-c",
    dest="config_path",
    default="config.ini",
    action="store",
    help="(Optional) Set path to config.ini. E.g, /Users/Hagrid/github.com/content-eng-tools/auto-magical-dashboard/config.ini",
)
args = parser.parse_args()

if args.is_debug:
    logging.basicConfig(level=logging.DEBUG)

TRACE_NAME = args.otel_trace_name
my_trace = tracing.tracer
# looper = []
# looper.append({"key_expiry": 600, "wait": 30})
key_expiry = 180
for i in range(1, 10):
    time.sleep((10 % i) * 10)
    print((10 % i) * 10)

    with my_trace.start_as_current_span(f"write_dashboard_{TRACE_NAME}"):
        ENVIRONMENT = args.env
        customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
        domain = getObserveConfig("domain", ENVIRONMENT, my_trace)
        OUTPUTFILENAME_BASE = args.output_name if args.output_name else "output.tf"
        BEARERTOKEN = (
            args.bearer_token if args.bearer_token else get_bearer_token(my_trace)
        )

        DASHBOARD_ID = args.dash_id
        WORKSPACE_ID = args.workspace_id

        customer_id = getObserveConfig("customer_id", ENVIRONMENT, my_trace)
        domain = getObserveConfig("domain", ENVIRONMENT, my_trace)
        META_URL = f"https://{customer_id}.{domain}.com/v1/meta"

        print("dashboard id:", DASHBOARD_ID)
        print("file name:", OUTPUTFILENAME_BASE)

        print("workspace id:", WORKSPACE_ID)
        print("otel trace name:", TRACE_NAME)

        OUTPUT_EXISTS = os.path.exists(OUTPUTFILENAME_BASE)

        write_dashboard(my_trace)
    # for thing in span:
    #     print(thing)
# pylint: disable=pointless-string-statement;
"""
query terraform {
      getTerraform( id:"41143378", type: Dashboard){
        resource
      }
    }

    python3 writeTerraform.py db.json

    grep -rh "datasetId" --include \*.tf | sed -e $'s/,/\\\n/g' | sed -e 's/[[:space:]]//g' | sort | uniq | sed -e 's/"datasetId"://g'

    query datasets {
      datasetSearch(labelMatches:["GCP/Compute"]){
        dataset {
          id
          name
          kind
          label
          workspaceId
        }
      }
    }

     sed -i '' "s:41143354:"\${local.COMPUTE_INSTANCE}":g" *.tf
"""
