@Library('aqua-pipeline-lib@master') _

class Global {
    static Object CHANGED_FILES = []
    static Object CHANGED_CF_FILES = []
    static Object CHANGED_MANIFESTS_FILES = []
    static Object SORTED_CHANGED_FILES = []
    static String BUILD_USER_EMAIL
}

pipeline {
    agent { label 'azure_slaves' }
    options {
        ansiColor('xterm')
        timestamps()
        skipStagesAfterUnstable()
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }
    environment {
        AWS_ACCESS_KEY_ID = credentials('svc_team_1_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('svc_team_1_aws_secret_access_key')
        AWS_REGION = "us-west-2"
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
        stage("generateStages") {
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
        stage("run parallel stages") {
            parallel {
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
                stage('others') {
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
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
//                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
            }
        }
    }
}
