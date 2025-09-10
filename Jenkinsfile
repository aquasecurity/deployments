@Library('aqua-pipeline-lib@master') _

def pythonImage = 'python:3-slim-buster'
def changedCfFiles = []
def changedFiles = []
def changedManifestsFiles = []
def sortedOtherChangedFiles = []
def debug = true
def runCloudFormation = false

pipeline {
    agent {
        kubernetes kubernetesAgents.bottlerocket(size: '4xLarge', cloud: 'kubernetes', dind: 'True', capacityType: 'on-demand')
    }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('aqua-cloudsecurity-dev-svc-team-1-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aqua-cloudsecurity-dev-svc-team-1-secret')
        AWS_REGION = "us-west-2"
        AWS_ACCOUNT_ID = "172746256356" // aqua-cloudsecurity-dev
        DEPLOY_REGISTRY = "aquasec.azurecr.io"
    }
    stages {
        stage('downloads') {
            steps {
                script {
                    sh "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
                }
            }
        }
        stage("Checkout") {
            steps {
                script {
                    gitUtils.clone repo: "deployment", branch: "master", credentialsId: "bitbucket-read-access"
                    dir("deployments") {
                        checkout scm
                    }
                    log.info "CHANGE_TARGET: ${CHANGE_TARGET}\n CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    withCredentials([usernamePassword(credentialsId: "dockerhub-aquabuildci-creds", passwordVariable: 'PASSWORD', usernameVariable: 'USER')]) {
                        utils.dockerlogin username: env.USER, password: env.PASSWORD, registry: ""
                    }
                }
            }
        }
        // stage("Analyze Changes") {
        //     steps {
        //         script {
        //             dir("deployments") {
        //                 sh "git fetch origin ${env.CHANGE_TARGET}:refs/remotes/origin/${env.CHANGE_TARGET}"
        //                 changedFiles = sh(script: "git --no-pager diff origin/${env.CHANGE_TARGET} --name-only", returnStdout: true).trim().split("\\r?\\n")
        //                 changedFiles = changedFiles.findAll { !it.endsWith('.adoc') }

        //                 log.info "The following files have changed:\n  ${changedFiles.join('\n  ')}"
        //                 def sortedChangedFiles = deployments.analyzeChangedFiles(changedFiles)
        //                 changedCfFiles = sortedChangedFiles["cloudFormationChangedFiles"]
        //                 changedManifestsFiles = sortedChangedFiles["manifestsChangedFiles"]
        //                 sortedOtherChangedFiles = sortedChangedFiles["otherChangedFiles"]
        //                 runCloudFormation = deployments.runCloudFormation(env.CHANGE_TARGET)
        //             }
        //         }
        //     }
        // }
        // stage('Cloudformation Trivy Scan') {
        //     when {
        //         allOf {
        //             not { expression { return changedCfFiles.isEmpty() } }
        //             expression { return runCloudFormation }
        //         }
        //     }
        //     steps {
        //         script {
        //             dir("deployments") {
        //                 parallel changedCfFiles.collectEntries { filename ->
        //                     def shortName = filename.split("/")[-1]
        //                     shortName = "${shortName}".replaceAll(/aqua|\.yaml/, '')

        //                     ["${shortName}": {
        //                         stage("Trivy scan ${shortName}") {
        //                             log.info "Starting Trivy scan for file: ${filename}"
        //                             sh "trivy config --severity HIGH,CRITICAL --ignorefile .trivyignore --exit-code 1 ${filename}"
        //                         }
        //                     }]
        //                 }
        //             }
        //         }
        //     }
        // }
        // stage('Verify and Deploy Cloudformation') {
        //     when {
        //         allOf {
        //             not { expression { return changedCfFiles.isEmpty() } }
        //             expression { return runCloudFormation }
        //         }
        //     }
        //     steps {
        //         script {
        //             docker.image("${pythonImage}").inside("-u root") {
        //                 sh "pip install --upgrade -r requirements.txt"
        //                 sh "pip -q install awscli"
        //                 sh "aws --region ${env.AWS_REGION} codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner ${env.AWS_ACCOUNT_ID}"
        //                 sh "pip install --no-build-isolation aqua-deployment"

        //                 parallel changedCfFiles.collectEntries { filename ->
        //                     def shortName = filename.split("/")[-1]
        //                     shortName = "${shortName}".replaceAll(/aqua|\.yaml/, '')

        //                     ["${shortName}": {
        //                         stage("Verify and Deploy ${shortName}") {
        //                             def extraFlag = ""
        //                             def testFile = ""
        //                             def clusterName = ""
        //                             def baseName = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}".toLowerCase()

        //                             if (filename.contains("aqua-ecs-fargate")) {
        //                                 clusterName = "far-${baseName}"
        //                                 testFile = "tests/fargate/test_cloudformation.py"
        //                             } else if (filename.contains("aqua-ecs-ec2")) {
        //                                 clusterName = "ec2-${baseName}"
        //                                 testFile = "tests/ec2/test_cloudformation.py"
        //                             } else {
        //                                 log.error "file: ${file} is not one of fargate\\ec2"
        //                             }

        //                             if (filename.contains("external")) {
        //                                 extraFlag = "--create_db"
        //                                 clusterName = "${clusterName}-e"
        //                             }
        //                             sh "python ${testFile} --filename deployments/${filename} --image_tag ${env.CHANGE_TARGET} --cluster_name ${clusterName}"
        //                             sh "python ${testFile} --filename deployments/${filename} --image_tag ${env.CHANGE_TARGET} --cluster_name ${clusterName} --deploy ${extraFlag}"
        //                         }
        //                     }]
        //                 }
        //             }
        //         }
        //     }
        // }
        // stage("Manifest") {
        //     when {
        //         allOf {
        //             not { expression { return changedManifestsFiles.isEmpty() } }
        //             expression { return runCloudFormation }
        //         }
        //     }
        //     steps {
        //         script {
        //             log.info "Starting to test Manifest yamls"
        //             def deploymentImage = docker.build("deployment-manifest-image", "-f Dockerfile-manifest .")
        //             deploymentImage.inside("-u root") {
        //                 def parallelStagesMap = changedManifestsFiles.collectEntries {
        //                     ["${it.split("/")[-1]}": deployments.generateStage(it, "manifest")]
        //                 }
        //                 parallel parallelStagesMap
        //             }
        //         }
        //     }
        // }
        stage("kind Cluster Install and Prepare") {
            // when {
            //     allOf {
            //         not { expression { return changedManifestsFiles.isEmpty() } }
            //         expression { return runCloudFormation }
            //     }
            // }
            steps {
                script {
                    deployments.installKind()
                    deployments.createKindCluster clusterName: env.BUILD_NUMBER
                    kubectl.createNamespace create: "yes"
                    kubectl.createDockerRegistrySecret create: "yes", registry: env.DEPLOY_REGISTRY
                    sh "ls"
                }
            }
        }
        stage("Deploy Manifests") {
//             when {
//                 allOf {
//                     not { expression { return changedManifestsFiles.isEmpty() } }
//                     expression { return runCloudFormation }
//                 }
//             }
            steps {
                script {
//                     def deploymentImage = docker.build("deployment-k3s-image", "-f Dockerfile-k3s .")
//                     deploymentImage.inside("-u root --network host") {
                        sh "pip install --upgrade -r requirements.txt"
                        sh "pip -q install awscli"

                        log.info "Pulling manifests with Aquactl and modifying other manifests"
                        sh """
                        aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner ${AWS_ACCOUNT_ID} --region us-west-2
                        pip install aqua-deployment
                        /bin/bash k3s/prepare.sh ${DEPLOY_REGISTRY}
                        """
//                     }
                }
            }
        }
    }
    post {
        always {
            script {
                if (!changedManifestsFiles.isEmpty() && runCloudFormation) {
                    deployments.deleteKindCluster clusterName: env.BUILD_NUMBER
                }
                input "hi"
            }
        }
    }
}