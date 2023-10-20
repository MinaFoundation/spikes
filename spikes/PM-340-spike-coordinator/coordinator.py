import os
import logging
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import time
from kubernetes import client, config
import threading

# Configure logging
logging.basicConfig(filename='server.log', level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Set environment variables
# Get the values of your-image and tag from environment variables
worker_image = os.environ.get("WORKER_IMAGE", "busybox")
worker_tag = os.environ.get("WORKER_TAG", "latest")

# Load the in-cluster configuration
config.load_incluster_config()

# Create a Kubernetes API client
api = client.BatchV1Api()

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

        query_params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        workers = query_params.get('workers', [''])[0]

        logging.info(f"Received request with workers={workers}")

        self.wfile.write(f'Workers: {workers}\n'.encode('utf-8'))

        if workers:
            # Create a list to hold the worker threads
            worker_threads = []
            for i in range(int(workers)):
                worker_thread = threading.Thread(target=self.create_and_monitor_pod, args=(i,))
                worker_threads.append(worker_thread)
                worker_thread.start()

            # Wait for all worker threads to finish
            for worker_thread in worker_threads:
                worker_thread.join()

    def create_and_monitor_pod(self, index):
        job_name = f"job-{time.strftime('%y-%m-%d-%H-%M')}-{index}"

        job = client.V1Job(
            metadata=client.V1ObjectMeta(name=job_name),
            spec=client.V1JobSpec(
                template=client.V1PodTemplateSpec(
                    spec=client.V1PodSpec(
                        containers=[
                            client.V1Container(
                                name="my-container",
                                image=f"{worker_image}:{worker_tag}",
                                command=["sleep", "10"],
                            )
                        ],
                        restart_policy="Never",
                    )
                )
            )
        )

        namespace = open("/var/run/secrets/kubernetes.io/serviceaccount/namespace").read()
        api.create_namespaced_job(namespace, job)

        logging.info(f"Launching pod {index}")

        start_time = time.time()
        while True:
            pod = api.read_namespaced_job(job_name, namespace)
            if pod.status.succeeded is not None and pod.status.succeeded > 0:
                end_time = time.time()
                self.wfile.write(f"Pod {index} completed in {end_time - start_time} seconds\n".encode('utf-8'))
                logging.info(f"Pod {index} completed in {end_time - start_time} seconds")
                break
            time.sleep(1)

def main():
    host = '0.0.0.0'  # Listen on all available network interfaces
    port = 8080  # The port you want to listen on

    server = HTTPServer((host, port), SimpleHTTPRequestHandler)
    print(f"Server started on {host}:{port}")

    # Log server startup
    logging.info(f"Server started on {host}:{port}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
        print("\nServer stopped.")
        logging.info("Server stopped.")

if __name__ == '__main__':
    main()
