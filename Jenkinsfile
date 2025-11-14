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
                bat """
                    mvn clean package -DskipTests
                """
            }
        }

        // ---------------------------------------------
        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image..."
                bat """
                    docker build -t %IMAGE_NAME% .
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
                    bat """
                        docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                        docker tag %IMAGE_NAME% %DOCKER_USER%/%APP_NAME%:%BUILD_NUMBER%
                        docker push %DOCKER_USER%/%APP_NAME%:%BUILD_NUMBER%
                    """
                }
            }
        }

        // ---------------------------------------------
        stage('Generate Kubernetes YAML Files') {
            steps {
                echo "Generating Kubernetes deployment YAML..."

                // Using envsubst on Windows
                bat """
                    powershell -Command "(Get-Content namespace-template.yaml) -replace '\\$NAMESPACE', '%NAMESPACE%' | Out-File namespace.yaml"
                    powershell -Command "(Get-Content deployment-template.yaml) -replace '\\$IMAGE_NAME', '%docker_user%/%APP_NAME%:%BUILD_NUMBER%' | Out-File deployment.yaml"
                    powershell -Command "(Get-Content service-template.yaml) -replace '\\$NAMESPACE', '%NAMESPACE%' | Out-File service.yaml"
                """
            }
        }

        // ---------------------------------------------
        stage('Deploy to Kubernetes') {
            steps {
                echo "Applying Kubernetes manifests..."

                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                        kubectl --kubeconfig="%KUBECONFIG%" apply -f namespace.yaml
                        kubectl --kubeconfig="%KUBECONFIG%" apply -f deployment.yaml
                        kubectl --kubeconfig="%KUBECONFIG%" apply -f service.yaml
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
