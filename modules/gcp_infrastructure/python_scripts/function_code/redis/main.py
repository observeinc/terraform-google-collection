import redis
import json
import time
import os
import tracing
import traceback
import typing
import sys


# https://github.com/redis/redis-py

# Redis connection - read env variable or defaults to local host
# See sample_environment/python_scripts/README.md for how to enable port forwarding for local dev
redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", 6379))
redis_password = ""

t = time.time()
ml = int(t * 1000)

# based on Luke's work here - https://github.com/observeinc/google-cloud-functions/blob/main/main.py
def main(request) -> typing.List[dict]:
    try:
        is_str = isinstance(request, str)
        if is_str == True:
            print(is_str)
            method = request

        if is_str == False:
            jstr = request.get_json()
            method = jstr["method"]

        print(f"method = {method}")
        print(f"REDIS_HOST: {redis_host}")
        print(f"REDIS_PORT: {redis_port}")
    except Exception as e:
        print("Error processing request")
        print(e)
        return e

    with tracing.tracer.start_as_current_span(f"{method}_redis") as span:
        span.set_attribute("REDIS_HOST", redis_host)
        res = []
        range_int = 100
        # Create the Redis Connection object
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
            return e

        try:
            if method == "write":
                input_data = []
                # create a set of fake keys and values based on current time
                for number in range(range_int):
                    input_data.append(
                        {"id": f"{number}", "Name": f"Name-{ml}-{number}"}
                    )

                # loop fake keys and write to redis
                for elem in input_data:
                    # json_data = json.loads(elem)
                    # Set the message in Redis
                    key = int(elem["id"])
                    # for response object
                    res.append(
                        {
                            "key": key,
                            "value": str(elem),
                        }
                    )
                    # write to redis
                    expire = 30 if int(elem["id"]) < 50 else 90
                    r.set(key, str(elem), ex=expire)
                    # print(f"{key} = {str(elem)}")

                span.set_attribute("num_keys", len(input_data))
                # span.set_attribute("method", str(request.body))

                return "Ok", 200

            if method == "read":
                redis_keys = []
                # for key in r.scan_iter("*"):
                #     redis_keys.append(key)
                #     print(key)
                for number in range(range_int):
                    redis_keys.append(key)

                values = r.mget(redis_keys)
                for val in values:
                    print(val)
                # print(datetime.datetime.now() - start_time)

                span.set_attribute("num_keys_read", len(values))

                return "Ok", 200
        except Exception as e:
            print("Error processing request")
            print(e)
            return e
    return "Should not have reached here", 500


if __name__ == "__main__":
    args = len(sys.argv)

    if args == 1:
        method = "write"
    elif args == 2:
        method = sys.argv[1]
    else:
        print("Need 0 or 1 args")
        exit()

    print(sys.argv)
    print(f"args={args}")
    main(method)
