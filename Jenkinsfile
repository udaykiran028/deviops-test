pipeline {
    agent any

    environment {
        APP_NAME = "healthcheckservice"
        BUILD_NUMBER = "v1"
        IMAGE_NAME = "healthcheckservice:${BUILD_NUMBER}"
        NAMESPACE = "healthcheckservice-ns"
    }

    stages {

        // ---------------------------------------------
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/udaykiran028/deviops-test.git'
                    ]]
                ])
            }
        }

        // ---------------------------------------------
        stage('Build JAR using Maven') {
            steps {
                echo "Building JAR file..."
                sh """
                    mvn -B clean package -DskipTests
                """
            }
        }

        // ---------------------------------------------
        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image..."
                sh """
                    docker build -t ${IMAGE_NAME} .
                """
            }
        }

        // ---------------------------------------------
        stage('Push Docker Image to DockerHub') {
            steps {
                echo "Pushing Docker Image to DockerHub..."

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME} $DOCKER_USER/${APP_NAME}:${BUILD_NUMBER}
                        docker push $DOCKER_USER/${APP_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }

        // ---------------------------------------------
        stage('Generate Kubernetes YAML Files') {
            steps {
                echo "Generating Kubernetes YAML Files..."
                sh """
                    envsubst < namespace-template.yaml > namespace.yaml
                    envsubst < deployment-template.yaml > deployment.yaml
                    envsubst < service-template.yaml > service.yaml
                """
            }
        }

        // ---------------------------------------------
        stage('Deploy to Kubernetes') {
            steps {
                echo "Applying Kubernetes manifests..."

                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl --kubeconfig=$KUBECONFIG apply -f namespace.yaml
                        kubectl --kubeconfig=$KUBECONFIG apply -f deployment.yaml
                        kubectl --kubeconfig=$KUBECONFIG apply -f service.yaml
                    """
                }
            }
        }
    }

    // --------------------------------------------------
    post {
        always {
            echo "Pipeline completed."
        }
    }
}
