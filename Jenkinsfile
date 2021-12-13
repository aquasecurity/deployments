@Library('aqua-pipeline-lib@master')_

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
        AWS_ACCESS_KEY_ID     = credentials('deployment-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('deployment-aws-secret-access-key')
        AWS_REGION = "us-west-2"
    }
    stages {
        stage ("Checkout") {
            steps {
                script {
                    checkout([
                            $class: 'GitSCM',
                            branches: scm.branches,
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'deployments']],
                            userRemoteConfigs: scm.userRemoteConfigs
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
                    dir("deployments"){
                        files = sh script: "git --no-pager diff origin/${CHANGE_TARGET} --name-only", returnStdout: true
//                    files = sh script: "find . -type f", returnStdout: true

                        echo "files: ${files}"
                        echo "CHANGE_TARGET: ${CHANGE_TARGET}"
                        echo "CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    }
//                    echo "GIT_COMMIT: ${GIT_COMMIT}"
//                    files = sh script: "git --no-pager diff ${CHANGE_TARGET} --name-only", returnStdout: true




                }
            }
        }
        stage("Check diff") {
            when {
                anyOf {
                    changeset "*/ecs/**"
                    changeset "*/cloudformation/**"
                }
            }
            steps {
                script {
                    echo "Running cloudformation"
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
