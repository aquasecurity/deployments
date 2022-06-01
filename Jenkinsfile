@Library('aqua-pipeline-lib@master') _
import com.aquasec.deployments.orchestrators.*

class Global {
    static Object CHANGED_FILES = []
    static Object CHANGED_CF_FILES = []
    static Object CHANGED_MANIFESTS_FILES = []
    static Object SORTED_CHANGED_FILES = []
    static String BUILD_USER_EMAIL
}

def orchestrator = new OrcFactory(this).GetOrc()
def debug = true
pipeline {
    agent {
        label 'deployment_slave'
    }

    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
        lock('k3s')
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('svc_team_1_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('svc_team_1_aws_secret_access_key')
        AWS_REGION = "us-west-2"
        AQUADEV_AZURE_ACR_PASSWORD = credentials('aquadevAzureACRpassword')
        AUTH0_CREDS = credentials('auth0Credential')
        VAULT_TERRAFORM_SID = credentials('VAULT_TERRAFORM_SID')
        VAULT_TERRAFORM_SID_USERNAME = "$VAULT_TERRAFORM_SID_USR"
        VAULT_TERRAFORM_SID_PASSWORD = "$VAULT_TERRAFORM_SID_PSW"
        VAULT_TERRAFORM_RID = credentials('VAULT_TERRAFORM_RID')
        VAULT_TERRAFORM_RID_USERNAME = "$VAULT_TERRAFORM_RID_USR"
        VAULT_TERRAFORM_RID_PASSWORD = "$VAULT_TERRAFORM_RID_PSW"
    }
    stages {
        stage("Checkout") {
            steps {
                script {
                    log.info "CHANGE_TARGET: ${CHANGE_TARGET}"
                    log.info "CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    deployment.clone branch: "master"
                    checkout([
                            $class                           : 'GitSCM',
                            branches                         : scm.branches,
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions                       : [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'deployments']],
                            userRemoteConfigs                : scm.userRemoteConfigs
                    ])

                }
            }
        }
        stage("Analyze Changes") {
            steps {
                script {
                    dir("deployments") {
                        Global.CHANGED_FILES = sh(script: "git --no-pager diff origin/${CHANGE_TARGET} --name-only", returnStdout: true).trim().split("\\r?\\n")
                        def gitCommits = sh(script: "git log --pretty=format:'%h' -n 1", returnStdout: true).trim().split("\\r?\\n")
                        for (commit in gitCommits) {
                            log.info "commit: ${commit}"
                        }
                        for (file in Global.CHANGED_FILES) {
                            log.info "file: ${file}"
                        }
                    }
                    def sortChangedFiles = deployments.sortChangedFiles(Global.CHANGED_FILES)
                    Global.CHANGED_CF_FILES = sortChangedFiles["CHANGED_CF_FILES"]
                    Global.CHANGED_MANIFESTS_FILES = sortChangedFiles["CHANGED_MANIFESTS_FILES"]
                    Global.SORTED_CHANGED_FILES = sortChangedFiles["SORTED_CHANGED_FILES"]
                }
            }
        }
        stage('Other Files') {
            when {
                allOf {
                    not { expression { return Global.SORTED_CHANGED_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    log.info "Starting to test SORTED_CHANGED_FILES"
                    for (file in Global.SORTED_CHANGED_FILES) {
                        log.info "file: ${file} was changed"
                    }
                }
            }
        }
        stage('Cloudformation') {
            when {
                allOf {
                    not { expression { return Global.CHANGED_CF_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    log.info "Starting to test Cloudformation yamls"

                    def deploymentImage = docker.build("deployment-cloudformation-image", "-f Dockerfile-cloudformation .")
                    deploymentImage.inside("-u root") {
                        log.info "Installing aqaua-deployment  python package"
                        sh """
                        aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 172746256356
                        pip install aqua-deployment
                        """
                        log.info "Finished to install aqaua-deployment python package"

                        def parallelStagesMap = Global.CHANGED_CF_FILES.collectEntries {
                            ["${it.split("/")[-1]}": deployments.generateStage(it, "cloudformation")]
                        }
                        parallel parallelStagesMap

                    }

                }
            }
        }
        stage("Manifest") {
            when {
                allOf {
                    not { expression { return Global.CHANGED_MANIFESTS_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    log.info "Starting to test Manifest yamls"
                    def deploymentImage = docker.build("deployment-manifest-image", "-f Dockerfile-manifest .")
                    deploymentImage.inside("-u root") {
                        def parallelStagesMap = Global.CHANGED_MANIFESTS_FILES.collectEntries {
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
                    not { expression { return Global.CHANGED_MANIFESTS_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    orchestrator.install()
                    helm.settingKubeConfig()
                    kubectl.createNamespace create: "yes"
                    kubectl.createDockerRegistrySecret create: "yes"

                }
            }
        }
        stage("Deploy Manifests"){
            when {
                allOf {
                    not { expression { return Global.CHANGED_MANIFESTS_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps{
                script{
                    def deploymentImage = docker.build("deployment-k3s-image", "-f Dockerfile-k3s .")
                    deploymentImage.inside("-u root --network host") {
                        log.info "Pulling manifests with Aquactl and modifying other manifests"
                        sh """
                        aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 172746256356
                        pip install aqua-deployment
                        /bin/bash k3s/prepare.sh
                        """
                            }
                        }
                    }
                }
        stage("Updating Consul") {
            when {
                allOf {
                    not { expression { return Global.CHANGED_MANIFESTS_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    helm.updateConsul("create")
                    log.info "Updated Consul successfully"
                }
            }
        }
        stage("Running Mstp Tests") {
            when {
                allOf {
                    not { expression { return Global.CHANGED_MANIFESTS_FILES.isEmpty() } }
                    expression { return deployments.runCloudFormation(CHANGE_TARGET) }
                }
            }
            steps {
                script {
                    log.info "Running Mstp tests"
                    helm.runMstpTestsManifests debug: debug
                }
            }
        }
    }
    
    post {
        always {
            script {
                try{
                helm.updateConsul("delete")
                orchestrator.uninstall()
                echo "k3s uninstalled"
                helm.removeDockerLocalImages()
                cleanWs()
                }
                catch(err){
                cleanWs()
                helm.removeDockerLocalImages()
                }
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
}