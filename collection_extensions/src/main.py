"""functions for fetching gcp api data"""
import json
import os
from google.cloud import compute_v1
from google.cloud import pubsub_v1
from google.cloud import scheduler_v1
from google.oauth2 import service_account
import googleapiclient.discovery

# from google.cloud import service_usage_v1


# https://cloud.google.com/python/docs/reference/compute/latest/google.cloud.compute_v1.services.zones.ZonesClient#google_cloud_compute_v1_services_zones_ZonesClient_list
def list_service_accounts(request):
    """List service accounts for project"""
    """
    YOUR_TOPIC_ID - ex - projects/YOUR_PROJECT_ID/topics/YOUR_TOPIC_NAME
    call locally -  export PROJECT_ID=YOUR_PROJECT_ID; export TOPIC_ID=YOUR_TOPIC_ID; python3 -c 'import main; main.list_service_accounts("chah")'
    """

    project_id = os.getenv("PROJECT_ID")
    topic_path = os.getenv("TOPIC_ID")

    # Log project_id and topic_path
    print("project_id: ", project_id)
    print("topic_path: ", topic_path)

    # try calling service api
    try:
        service = googleapiclient.discovery.build("iam", "v1")

        # list service accounts for specified project
        service_accounts = (
            service.projects()
            .serviceAccounts()
            .list(name="projects/" + project_id)
            .execute()
        )
        # response object
        service_accounts_response = []

        # append results to object
        for account in service_accounts["accounts"]:
            service_accounts_response.append(
                {
                    "project_id": project_id,
                    "service_account_name": account["name"],
                    "service_account_email": account["email"],
                    "service_account_id": account["uniqueId"],
                    "etag": account["etag"],
                    "oauth2ClientId": account["oauth2ClientId"],
                }
            )

        # get pubsub client
        publisher = pubsub_v1.PublisherClient()

        # log data
        print("data: ", service_accounts_response)

        # jsonify
        message_json = json.dumps(service_accounts_response)

        message_bytes = message_json.encode("utf-8")

        # try pushing data to pubsub
        try:
            publish_future = publisher.publish(
                topic_path,
                data=message_bytes,
                OBSERVATION_KIND="gcpServiceAccount",  # this is used to filter results in observe - you can add as many additional attributes as you like
            )
            result = publish_future.result()  # verify that the publish succeeded
            # log pubsub result
            print("pubsub result: ", result)

        # pylint: disable=broad-except;
        except Exception as e_e:
            print("##########################")
            print(str(e_e))
            print("##########################")
            return (str(e_e), 500)

        return ("Message received and published to Pubsub", 200)
    # pylint: disable=broad-except;
    except Exception as call_error:
        print("##########################")
        print(str(call_error))
        print("##########################")
        return (str(call_error), 500)


def list_instance_group(request):
    """List instance group instances for a project"""
    """
    YOUR_TOPIC_ID - ex - projects/YOUR_PROJECT_ID/topics/YOUR_TOPIC_NAME
    call locally -  export PROJECT_ID=YOUR_PROJECT_ID; export TOPIC_ID=YOUR_TOPIC_ID; python3 -c 'import main; main.list_instance_group("chah")'
    """

    project_id = os.getenv("PROJECT_ID")
    topic_path = os.getenv("TOPIC_ID")

    # Log project_id and topic_path
    print("project_id: ", project_id)
    print("topic_path: ", topic_path)

    # try calling ZonesClient api
    try:
        # response object
        instance_group_instances_response = []

        publisher = pubsub_v1.PublisherClient()

        # client to fetch zones
        zone_client = compute_v1.services.zones.ZonesClient
        # client to fetch instance groups
        instance_group_client = compute_v1.services.instance_groups.InstanceGroupsClient

        # fetch zones
        zones = zone_client().list(
            project=project_id,
        )

        # loop zone results
        for zone in zones:
            # fetch instance groups in zone
            instance_groups = instance_group_client().list(
                project=project_id, zone=zone.name
            )

            # loop instance group result
            for instance_group in instance_groups:
                # get instances in instance group
                instances = instance_group_client().list_instances(
                    project=project_id,
                    instance_group=instance_group.name,
                    zone=zone.name,
                )

                # create response object
                for instance in instances:
                    instance_group_instances_response.append(
                        {
                            "project_id": project_id,
                            "zone": zone.name,
                            "instance_group": instance_group.name,
                            "instance_group_id": instance_group.id,
                            "instance": instance.instance,
                        }
                    )
        # log data
        print("data: ", instance_group_instances_response)

        message_json = json.dumps(instance_group_instances_response)

        message_bytes = message_json.encode("utf-8")

        # try pushing data to pubsub
        try:
            publish_future = publisher.publish(
                topic_path,
                data=message_bytes,
                OBSERVATION_KIND="gcpInstanceGroup",  # this is used to filter results in observe - you can add as many additional attributes as you like
            )
            result = publish_future.result()  # verify that the publish succeeded
            # log pubsub result
            print("pubsub result: ", result)

        # pylint: disable=broad-except;
        except Exception as e_e:
            print("##########################")
            print(str(e_e))
            print("##########################")
            return (str(e_e), 500)

        return ("Message received and published to Pubsub", 200)
    # pylint: disable=broad-except;
    except Exception as call_error:
        print("##########################")
        print(str(call_error))
        print("##########################")
        return (str(call_error), 500)


def list_cloud_scheduler_jobs(request):
    """List service accounts for project"""
    """
    YOUR_TOPIC_ID - ex - projects/YOUR_PROJECT_ID/topics/YOUR_TOPIC_NAME
    call locally -  export PROJECT_ID=YOUR_PROJECT_ID; export TOPIC_ID=YOUR_TOPIC_NAME; python3 -c 'import main; main.list_cloud_scheduler_jobs("chah")'
    """

    project_id = os.getenv("PROJECT_ID")
    topic_path = os.getenv("TOPIC_ID")

    # Log project_id and topic_path
    print("project_id: ", project_id)
    print("topic_path: ", topic_path)

    # try fetching regions
    try:
        # client for cloud scheduler jobs
        cloud_scheduler_client = scheduler_v1.CloudSchedulerClient()
        # client for regions
        region_client = compute_v1.services.regions.RegionsClient
        # fetch regions
        regions = region_client().list(
            project=project_id,
        )

        # response object
        cloud_scheduler_jobs_response = []

        # loop regions
        for region in regions:
            # log region
            print("region: ", region.name)

            # try fetching cloud scheduler jobs
            try:
                # if region.name not in exclude_list:
                request = scheduler_v1.ListJobsRequest(
                    parent=f"projects/{project_id}/locations/{region.name}"
                )

                # get jobs
                page_result = cloud_scheduler_client.list_jobs(request=request)

                # loop jobs
                for response in page_result:

                    cloud_scheduler_jobs_response.append(
                        {
                            "project_id": project_id,
                            "region": region.name,
                            "name": response.name,
                            "description": response.description,
                            "schedule_time": str(response.schedule_time),
                            "http_target": str(response.http_target),
                            "schedule": str(response.schedule),
                            "time_zone": response.time_zone,
                            "user_update_time": str(response.user_update_time),
                            "state": response.state,
                            "status": str(response.status),
                            "last_attempt_time": str(response.last_attempt_time),
                            "attempt_deadline": str(response.attempt_deadline),
                        }
                    )
            # pylint: disable=broad-except;
            # if no access to jobs in region ignore
            except Exception as e_e:
                print("##########################")
                print(str(e_e))
                print("##########################")

        publisher = pubsub_v1.PublisherClient()

        # log data
        print("data: ", cloud_scheduler_jobs_response)

        message_json = json.dumps(cloud_scheduler_jobs_response)

        message_bytes = message_json.encode("utf-8")

        # try pushing data to pubsub
        try:
            publish_future = publisher.publish(
                topic_path,
                data=message_bytes,
                OBSERVATION_KIND="gcpCloudSchedulerJobs",
            )
            result = publish_future.result()  # verify that the publish succeeded
            # log pubsub result
            print("pubsub result: ", result)

        # pylint: disable=broad-except;
        except Exception as e_e:
            print("##########################")
            print(str(e_e))
            print("##########################")
            return (str(e_e), 500)

        return ("Message received and published to Pubsub", 200)
    # pylint: disable=broad-except;
    except Exception as call_error:
        print("##########################")
        print(str(call_error))
        print("##########################")
        return (str(call_error), 500)
