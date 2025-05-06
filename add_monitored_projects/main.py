# All examples below based on:
# https://cloud.google.com/python/docs/reference/google-cloud-monitoring-metrics-scopes/latest/google.cloud.monitoring_metrics_scope_v1.services.metrics_scopes.MetricsScopesClient

# To Do:
# 1. Error Handling
# 2. Add logging
# 3. Loading required Python packages automatically

# Note: All Project lists are Project Numbers

from google.cloud import monitoring_metrics_scope_v1
from google.cloud import resourcemanager_v3
from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
import json, re

# PARENT = "folders/831845457119"
COLLECTION_PROJECT = "ephem-proj-collect"
PARENT = f"locations/global/metricsScopes/{COLLECTION_PROJECT}"

def diff_in_projects(projects_in_scope, projects_in_folder):
    # projects_in_scope = get_projects_in_metrics_scope()
    # projects_in_folder = list_projects_in_folder(831845457119)
    diff_list = []
    for element in projects_in_folder:
        if element not in projects_in_scope:
            diff_list.append(element)
    
    return diff_list

def create_monitored_projects():
    # Create a client
    
    monitored_projects = get_projects_in_metrics_scope()
    folderNumber = get_folder_number(COLLECTION_PROJECT)
    print(folderNumber)
    projects_to_add = diff_in_projects(get_projects_in_metrics_scope(), list_projects_in_folder(folderNumber))

    client = monitoring_metrics_scope_v1.MetricsScopesClient()
    for project in projects_to_add:
        my_monitored_project = monitoring_metrics_scope_v1.MonitoredProject(
            #name="locations/global/metricsScopes/ephem-proj-collect/projects/ephem-proj-five"
            name=f"locations/global/metricsScopes/ephem-proj-collect/projects/{project}"
        )

        # Initialize request argument(s)
        request = monitoring_metrics_scope_v1.CreateMonitoredProjectRequest(
            parent=PARENT,
            monitored_project = my_monitored_project
        )

        # Make the request
        operation = client.create_monitored_project(request=request)

        print("Waiting for operation to complete...")

        response = operation.result()

        # Handle the response
        print(response)


def get_projects_in_metrics_scope():
    # Create a client
    client = monitoring_metrics_scope_v1.MetricsScopesClient()
    
    # Initialize request argument(s)
    request = monitoring_metrics_scope_v1.GetMetricsScopeRequest(
        name=PARENT,
    )

    # Make the request
    response = client.get_metrics_scope(request=request)

    # monitored_projects = re.findall(r'locations\/[^\"]*projects\/[^\"]*', str(response))
    monitored_projects = re.findall(r'locations\/[^\"]*projects\/([^\"]*)', str(response))

    # Return list of project numbers of projects currently being monitored
    return monitored_projects

def list_projects_in_folder(folderId):
    # Create a client
    client = resourcemanager_v3.ProjectsClient()

    # Initialize request argument(s)
    request = resourcemanager_v3.ListProjectsRequest(
        #parent="folders/831845457119"
        #parent=f"folders/{folderNumber}"
        parent=folderId
    )

    # Make the request
    page_result = client.list_projects(request=request)
    monitored_projects = re.findall(r'^\s\sname:\s\"projects\/([^\"]*)\"', str(page_result),re.M)
    
    #Return a list of project numbers inside the folder
    return monitored_projects

def get_folder_number(projectId):
    # Create a client
    client = resourcemanager_v3.ProjectsClient()

    # Initialize request argument(s)
    request = resourcemanager_v3.SearchProjectsRequest(
        query=f"projectId={projectId}"
        #query=f"projectNumber={projectNumber}"
    )

    # Make the request
    page_result = client.search_projects(request=request)
    
    match = re.search(r'folders\/[^\"]*', str(page_result), re.M) 
    if match:
        #print(match.group(0))
        #Return the folder number
        return(match.group(0))
    else:
      return("")

def remove_monitored_projects():
    # Create a client
    client = monitoring_metrics_scope_v1.MetricsScopesClient()
    monitored_projects = get_projects_in_metrics_scope()
    monitored_projects.remove(get_project_number(COLLECTION_PROJECT))

    for project in monitored_projects:
        # Initialize request argument(s)
        request = monitoring_metrics_scope_v1.DeleteMonitoredProjectRequest(
            name=f"{PARENT}/projects/{project}"
        )

        # Make the request
        operation = client.delete_monitored_project(request=request)

        print("Waiting for operation to complete...")

        response = operation.result()

        # Handle the response
        print(response)

def get_project_number(projectId):

    credentials = GoogleCredentials.get_application_default()

    service = discovery.build('compute', 'v1', credentials=credentials)

    # Project ID for this request.
    project = projectId  # TODO: Update placeholder value.

    request = service.projects().get(project=project)
    response = request.execute()

    # TODO: Change code below to process the `response` dict:
    return response['defaultServiceAccount'].split("-")[0]