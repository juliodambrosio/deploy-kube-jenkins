pipeline {
    //Agent onde vai rodar esse script
    agent any
    
    stages { 
        // Nome do Stage
        stage('Build Docker Image') {
            steps{
              script{
                    // docker build 
                    dockerapp = docker.build("juliodambrosio/conv-temp:${env.BUILD_ID}", '-f ./Dockerfile ./')
                }
            }
        }

        stage('Push Docker Image') {
            steps{
                script{
                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub'){
                    dockerapp.push('latest')
                    dockerapp.push("${env.BUILD_ID}")
                    }   
                }
            }
        }

        stage('Deploy do Kubernetes') {
            environment{
                tag_version = "${env.BUILD_ID}"
            }
            steps{
                withKubeConfig([credentialsId: 'kubeconfig']){
                    sh 'sed -i "s/{{tag}}/$tag_version/g" k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/deployment.yaml'
                }
                
            }
        }
    }
}