@Library('aqua-pipeline-lib@master') _
import com.aquasec.deployments.orchestrators.*

def pythonImage = 'python:3-slim-buster'
def changedCfFiles = []
def changedFiles = []
def changedManifestsFiles = []
def sortedOtherChangedFiles = []
def orchestrator = new OrcFactory(this).GetOrc()
def debug = true
def runCloudFormation = false

pipeline {
    agent {
        label 'deployment_slave'
    }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
        lock('k3s')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('svc_team_1_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('svc_team_1_aws_secret_access_key')
        AWS_REGION = "us-west-2"
        AWS_ACCOUNT_ID = credentials('awsDeploymentAccountID')
        AQUADEV_AZURE_ACR_PASSWORD = credentials('aquadevAzureACRpassword')
        AUTH0_CREDS = credentials('auth0Credential')
        VAULT_TERRAFORM_SID = credentials('VAULT_TERRAFORM_SID')
        VAULT_TERRAFORM_SID_USERNAME = "$VAULT_TERRAFORM_SID_USR"
        VAULT_TERRAFORM_SID_PASSWORD = "$VAULT_TERRAFORM_SID_PSW"
        VAULT_TERRAFORM_RID = credentials('VAULT_TERRAFORM_RID')
        VAULT_TERRAFORM_RID_USERNAME = "$VAULT_TERRAFORM_RID_USR"
        VAULT_TERRAFORM_RID_PASSWORD = "$VAULT_TERRAFORM_RID_PSW"
        DOCKER_HUB_USERNAME = 'aquaautomationci'
        DOCKER_HUB_PASSWORD = credentials('aquaautomationciDockerHubToken')
        DEPLOY_REGISTRY = "aquasec.azurecr.io"
    }
    stages {
        stage("Checkout") {
            steps {
                script {
                    gitUtils.clone repo: "deployment", branch: "master"
                    dir("deployments") {
                        checkout scm
                    }
                    log.info "CHANGE_TARGET: ${CHANGE_TARGET}\n CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    utils.dockerlogin username: env.DOCKER_HUB_USERNAME, password: DOCKER_HUB_PASSWORD, registry: ""
                }
            }
        }
        stage("Analyze Changes") {
            steps {
                script {
                    dir("deployments") {
                        sh "git fetch origin ${env.CHANGE_TARGET}:refs/remotes/origin/${env.CHANGE_TARGET}"
                        changedFiles = sh(script: "git --no-pager diff origin/${env.CHANGE_TARGET} --name-only", returnStdout: true).trim().split("\\r?\\n")
                        changedFiles = changedFiles.findAll { !it.endsWith('.adoc') }

                        log.info "The following files have changed:\n  ${changedFiles.join('\n  ')}"
                        def sortedChangedFiles = deployments.analyzeChangedFiles(changedFiles)
                        changedCfFiles = sortedChangedFiles["cloudFormationChangedFiles"]
                        changedManifestsFiles = sortedChangedFiles["manifestsChangedFiles"]
                        sortedOtherChangedFiles = sortedChangedFiles["otherChangedFiles"]
                        runCloudFormation = deployments.runCloudFormation(env.CHANGE_TARGET)
                    }
                }
            }
        }
        stage('Cloudformation Trivy Scan') {
            when {
                allOf {
                    not { expression { return changedCfFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    dir("deployments") {
                        parallel changedCfFiles.collectEntries { filename ->
                            def shortName = filename.split("/")[-1]
                            shortName = "${shortName}".replaceAll(/aqua|\.yaml/, '')

                            ["${shortName}": {
                                stage("Trivy scan ${shortName}") {
                                    docker.withRegistry('https://aquadev.azurecr.io', 'aquadev-push') {
                                        docker.image("aquadev.azurecr.io/helm-cicd").inside("-u root") {
                                            log.info "Starting Trivy scan for file: ${filename}"
                                            sh "trivy config --severity HIGH,CRITICAL --ignorefile .trivyignore --exit-code 1 ${filename}"
                                        }
                                    }
                                }
                            }]
                        }
                    }
                }
            }
        }
        stage('Verify and Deploy Cloudformation') {
            when {
                allOf {
                    not { expression { return changedCfFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    docker.image("${pythonImage}").inside("-u root") {
                        sh "pip install --upgrade -r requirements.txt"
                        sh "pip -q install awscli"
                        sh "aws --region ${env.AWS_REGION} codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner ${env.AWS_ACCOUNT_ID}"
                        sh "pip install --no-build-isolation aqua-deployment"

                        parallel changedCfFiles.collectEntries { filename ->
                            def shortName = filename.split("/")[-1]
                            shortName = "${shortName}".replaceAll(/aqua|\.yaml/, '')

                            ["${shortName}": {
                                stage("Verify and Deploy ${shortName}") {
                                    def extraFlag = ""
                                    def testFile = ""
                                    def clusterName = ""
                                    def baseName = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}".toLowerCase()

                                    if (filename.contains("aqua-ecs-fargate")) {
                                        clusterName = "far-${baseName}"
                                        testFile = "tests/fargate/test_cloudformation.py"
                                    } else if (filename.contains("aqua-ecs-ec2")) {
                                        clusterName = "ec2-${baseName}"
                                        testFile = "tests/ec2/test_cloudformation.py"
                                    } else {
                                        log.error "file: ${file} is not one of fargate\\ec2"
                                    }

                                    if (filename.contains("external")) {
                                        extraFlag = "--create_db"
                                        clusterName = "${clusterName}-e"
                                    }
                                    sh "python ${testFile} --filename deployments/${filename} --image_tag ${env.CHANGE_TARGET} --cluster_name ${clusterName}"
                                    sh "python ${testFile} --filename deployments/${filename} --image_tag ${env.CHANGE_TARGET} --cluster_name ${clusterName} --deploy ${extraFlag}"
                                }
                            }]
                        }
                    }
                }
            }
        }
        stage("Manifest") {
            when {
                allOf {
                    not { expression { return changedManifestsFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    log.info "Starting to test Manifest yamls"
                    def deploymentImage = docker.build("deployment-manifest-image", "-f Dockerfile-manifest .")
                    deploymentImage.inside("-u root") {
                        def parallelStagesMap = changedManifestsFiles.collectEntries {
                            ["${it.split("/")[-1]}": deployments.generateStage(it, "manifest")]
                        }
                        parallel parallelStagesMap
                    }
                }
            }
        }
        stage("K3S Cluster Install and Prepare") {
            when {
                allOf {
                    not { expression { return changedManifestsFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    orchestrator.install()
                    helm.settingKubeConfig()
                    kubectl.createNamespace create: "yes"
                    kubectl.createDockerRegistrySecret create: "yes", registry: env.DEPLOY_REGISTRY
                }
            }
        }
        stage("Deploy Manifests") {
            when {
                allOf {
                    not { expression { return changedManifestsFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    def deploymentImage = docker.build("deployment-k3s-image", "-f Dockerfile-k3s .")
                    deploymentImage.inside("-u root --network host") {
                        log.info "Pulling manifests with Aquactl and modifying other manifests"
                        sh """
                        aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner ${AWS_ACCOUNT_ID}
                        pip install aqua-deployment
                        /bin/bash k3s/prepare.sh ${DEPLOY_REGISTRY}
                        """
                    }
                }
            }
        }
        stage("Updating Consul") {
            when {
                allOf {
                    not { expression { return changedManifestsFiles.isEmpty() } }
                    expression { return runCloudFormation }
                }
            }
            steps {
                script {
                    helm.updateConsul("create")
                    log.info "Updated Consul successfully"
                }
            }
        }
    }
    post {
        always {
            script {
                try {
                    helm.updateConsul("delete")
                    orchestrator.uninstall()
                    echo "k3s uninstalled"
                    helm.removeDockerLocalImages()
                    cleanWs()
                }
                catch (err) {
                    cleanWs()
                    helm.removeDockerLocalImages()
                }
            }
        }
    }
}
