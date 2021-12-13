@Library('aqua-pipeline-lib@master') _

class Global {
    static Object CHANGED_FILES = []
    static Object CHANGED_CF_FILES = []
    static Object SORTED_CHANGED_FILES = []
    static def OPERATOR = [:].asSynchronized()
    static String BASE_VERSION
    static String OPERATOR_BRANCH
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
        AWS_ACCESS_KEY_ID = credentials('deployment-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('deployment-aws-secret-access-key')
        AWS_REGION = "us-west-2"
    }
    stages {
        stage("Checkout") {
            steps {
                script {
                    checkout([
                            $class                           : 'GitSCM',
                            branches                         : scm.branches,
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions                       : [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'deployments']],
                            userRemoteConfigs                : scm.userRemoteConfigs
                    ])

//                    CHANGES = currentBuild.changeSets
//                    echo "CHANGES: ${CHANGES}"
//                    changedFiles = []
//                    for (changeLogSet in currentBuild.changeSets) {
//                        for (entry in changeLogSet.getItems()) { // for each commit in the detected changes
//                            for (file in entry.getAffectedFiles()) {
//                                path = file.getPath()
//                                echo "file: ${path}"
//                                changedFiles.add(file.getPath()) // add changed file to list
//                            }
//                        }
//                    }
//                    sh "ls"
//                    GIT_PREVIOUS_COMMIT= sh (script: "git rev-parse --short 'HEAD^'", returnStdout: true)
//                    GIT_COMMIT= sh (script: "git rev-parse --short HEAD", returnStdout: true)
//                    echo "GIT_PREVIOUS_COMMIT: ${GIT_PREVIOUS_COMMIT}"
//                    echo "GIT_COMMIT: ${GIT_COMMIT}"
//

//                    echo "GIT_COMMIT: ${GIT_COMMIT}"
//                    files = sh script: "git --no-pager diff ${CHANGE_TARGET} --name-only", returnStdout: true


                }
            }
        }
        stage("generateStages") {
            steps {
                script {
                    dir("deployments") {
                        Global.CHANGED_FILES = sh(script: "git --no-pager diff origin/${CHANGE_TARGET} --name-only", returnStdout: true).trim().split("\\r?\\n")
                        sortChangedFiles()
                        echo "CHANGE_TARGET: ${CHANGE_TARGET}"
                        echo "CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    }
                }
            }
        }
        stage("run parallel stages") {
            parallel {
                stage('Cloudformation') {
                    when {
                        allOf {
                            not { expression { return Global.CHANGED_CF_FILES.isEmpty() } }
                            expression { return CHANGE_TARGET.toDouble() >= 6.5 }
                        }
                    }
                    steps {
                        script {
                            echo "Starting to test Cloudfromation yamls"
                            deployment.clone branch: "master"
                            def deploymentImage = docker.build("deployment-image")
                            deploymentImage.inside("-u root") {
                                log.info "Installing aqaua-deployment  python package"
                                sh """
                                aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 934027998561
                                pip install aqua-deployment
                                """
                                log.info "Finished to install aqaua-deployment python package"

                                def parallelStagesMap = Global.CHANGED_CF_FILES.collectEntries {
                                    ["${it}": generateStage(it)]
                                }
                                parallel parallelStagesMap

                            }

                        }
                    }
                }
            }
            stage('others') {
                when {
                    allOf {
                        not { expression { return Global.SORTED_CHANGED_FILES.isEmpty() } }
                        expression { return CHANGE_TARGET.toDouble() >= 6.5 }
                    }
                }
                steps {
                    script {
                        echo "Starting to test SORTED_CHANGED_FILES"
                        def deploymentImage = docker.build("deployment-image")
                        for (file in Global.SORTED_CHANGED_FILES) {
                            echo "file: ${file}"
                        }
                    }
                }
            }
        }
    }
//    stages {
//        stage('Checkout') {
//            steps {
//                script {
//                    deployment.clone branch: "master"
//                    checkout([
//                            $class: 'GitSCM',
//                            branches: scm.branches,
//                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
//                            extensions: [[$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'cloudformation/']]],
//                                         [$class: 'RelativeTargetDirectory', relativeTargetDir: 'cloudformation']],
//                            userRemoteConfigs: scm.userRemoteConfigs
//                    ])
//                    dir("cloudformation"){
//                        sh "mv cloudformation/* . && rm -rf cloudformation"
//                    }
//                }
//            }
//        }
//        stage("Create Runs") {
//            steps {
//                script {
//                    def deploymentImage = docker.build("deployment-image")
//                    deploymentImage.inside("-u root") {
//                        log.info "Installing aqaua-deployment  python package"
//                        sh """
//                        aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 934027998561
//                        pip install aqua-deployment
//                        """
//                        log.info "Finished to install aqaua-deployment python package"
//                        cloudformation.run  publish: false
//                    }
//                }
//            }
//        }
//    }
//    post {
//        always {
//            script {
//                cleanWs()
////                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
//            }
//        }
//    }
}

def sortChangedFiles() {
    for (file in Global.CHANGED_FILES) {
        if (file.contains("ecs")) {
            Global.CHANGED_CF_FILES.add(file)
        }
        else {
            Global.SORTED_CHANGED_FILES.add(file)
        }
    }
}

def generateStage(it) {
    return {
        stage("stage: ${it.split("/")[-1]}") {
            echo "This is ${it.split("/")[-1]}."
            cloudformation.singleValidate("", it)
        }
    }
}