pipeline {
    agent any // Run on any available agent with Docker installed

    environment {
        // Define image name - replace 'your-repo-name' if desired
        IMAGE_NAME = 'test-sous-map-app'
        // Define a unique tag using the build number
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        // Define the running container name
        CONTAINER_NAME = 'my-angular-app'
        // Define the host port mapping
        HOST_PORT = 3220
        // Optional: Define your Docker registry URL (e.g., Docker Hub username)
        // DOCKER_REGISTRY = 'your-dockerhub-username'
        // Optional: Jenkins credential ID for Docker registry
        // DOCKER_CREDENTIAL_ID = 'dockerhub-credentials' // Make sure this credential exists in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                // Checks out code from the repository configured in the Jenkins job
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}..."
                // Build the image using the Dockerfile in the current directory
                // The tag includes the Jenkins build number for versioning
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                // Alternative using docker plugin (if installed):
                // script {
                //     dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                // }
            }
        }

        /*
        // Optional Stage: Push to Docker Registry
        stage('Push to Registry') {
            // Example condition: Only push if building the 'main' branch
            when { branch 'main' }
            steps {
                script {
                    // Ensure DOCKER_REGISTRY and DOCKER_CREDENTIAL_ID are set in environment
                    if (!env.DOCKER_REGISTRY || !env.DOCKER_CREDENTIAL_ID) {
                        error 'DOCKER_REGISTRY and DOCKER_CREDENTIAL_ID environment variables must be set for push stage.'
                    }
                    def registryImage = "${env.DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "Pushing Docker image: ${registryImage}..."

                    // Use Jenkins credentials binding for secure login
                    docker.withRegistry("https://${env.DOCKER_REGISTRY}", env.DOCKER_CREDENTIAL_ID) {
                        // Tag the image with the registry prefix
                        sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${registryImage}"
                        // Push the image
                        sh "docker push ${registryImage}"
                        // Optional: Remove local registry-tagged image after push if desired
                        // sh "docker rmi ${registryImage}"
                    }
                    // Alternative using sh and withCredentials:
                    // withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIAL_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    //     sh "echo ${DOCKER_PASS} | docker login ${env.DOCKER_REGISTRY} -u ${DOCKER_USER} --password-stdin"
                    //     sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${registryImage}"
                    //     sh "docker push ${registryImage}"
                    //     sh "docker logout ${env.DOCKER_REGISTRY}"
                    // }
                }
            }
        }
        */

        stage('Deploy Container') {
            steps {
                echo "Deploying container ${CONTAINER_NAME}..."
                // Stop and remove any existing container with the same name
                // '|| true' prevents the step from failing if the container doesn't exist
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"

                // Run the new container from the built image
                // Use -d for detached mode
                // Map host port to container port 80 (where Nginx listens)
                echo "Running container from image ${IMAGE_NAME}:${IMAGE_TAG} on port ${HOST_PORT}"
                sh "docker run -d -p ${HOST_PORT}:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"

                // Optional: Add a small delay or health check here if needed
                // sleep 10
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            // Optional: Clean up old Docker images tagged with the same name but older build numbers
            // Be cautious with cleanup commands, test them thoroughly.
            // Example: Remove images older than the last 5 builds for this image name
            // sh """
            // docker images ${IMAGE_NAME} --format '{{.Tag}}' | grep -v '<none>' | sort -rV | tail -n +6 | xargs -I {} docker rmi ${IMAGE_NAME}:{} || true
            // """

            // Optional: Clean up dangling images (untagged images)
            // sh "docker image prune -f"
        }
        success {
            echo "Deployment successful! Access at http://<jenkins-agent-ip>:${HOST_PORT}"
        }
        failure {
            echo 'Pipeline failed.'
            // Add notification steps here (e.g., email, Slack)
        }
    }
}
