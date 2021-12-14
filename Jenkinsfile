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
                            echo "commit: ${commit}"
                        }

//                        def changes = getChanges()
//                        echo "changes: ${changes}"
                        for (file in Global.CHANGED_FILES){
                            echo "file: ${file}"
                        }
                        sortChangedFiles()
                        echo "CHANGE_TARGET: ${CHANGE_TARGET}"
                        echo "CHANGE_BRANCH: ${CHANGE_BRANCH}"
                    }
                }
            }
        }
//        stage("run parallel stages") {
//            parallel {
//                stage('Cloudformation') {
//                    when {
//                        allOf {
//                            not { expression { return Global.CHANGED_CF_FILES.isEmpty() } }
//                            expression { return CHANGE_TARGET.toDouble() >= 6.5 }
//                        }
//                    }
//                    steps {
//                        script {
//                            echo "Starting to test Cloudfromation yamls"
//                            deployment.clone branch: "master"
//                            def deploymentImage = docker.build("deployment-image")
//                            deploymentImage.inside("-u root") {
//                                log.info "Installing aqaua-deployment  python package"
//                                sh """
//                                aws codeartifact login --tool pip --repository deployment --domain aqua-deployment --domain-owner 934027998561
//                                pip install aqua-deployment
//                                """
//                                log.info "Finished to install aqaua-deployment python package"
//
//                                def parallelStagesMap = Global.CHANGED_CF_FILES.collectEntries {
//                                    ["${it.split("/")[-1]}": generateStage(it)]
//                                }
//                                parallel parallelStagesMap
//
//                            }
//
//                        }
//                    }
//                }
//                stage('others') {
//                    when {
//                        allOf {
//                            not { expression { return Global.SORTED_CHANGED_FILES.isEmpty() } }
//                            expression { return CHANGE_TARGET.toDouble() >= 6.5 }
//                        }
//                    }
//                    steps {
//                        script {
//                            echo "Starting to test SORTED_CHANGED_FILES"
////                            def deploymentImage = docker.build("deployment-image")
//                            for (file in Global.SORTED_CHANGED_FILES) {
//                                echo "file: ${file}"
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    post {
        success {
            script {
                echo "success"

                def url = "https://api.github.com/repos/aquasecurity/deployments/releases"
                def httpResponse = httpRequest url
                def imageData = jsonParse(httpResponse.content).data[0]
                echo "imageData: ${imageData.size()}"

//                withCredentials([usernamePassword(credentialsId: 'gitHubCreds', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
//                    def encodedPassword = URLEncoder.encode("$GIT_PASSWORD",'UTF-8')
//                    sh """cd deployments
//                       git config user.email aqua-ci@aquasec.com
//                       git config user.name aqua-ci
//                       cat ./CHANGELOG.md || echo "xxx" > ./CANGELOG.md
//                       git add ./CANGELOG.md
//                       git commit -m 'Triggered Build: ${env.BUILD_NUMBER}'
//                       git push https://${GIT_USERNAME}:${encodedPassword}@github.com/${GIT_USERNAME}/aquasecurity/deployments.git HEAD/${CHANGE_BRANCH}
//                       cd..
//                    """
//                }
            }
        }
//        always {
//            script {
//                cleanWs()
////                notifyFullJobDetailes subject: "${env.JOB_NAME} Pipeline | ${currentBuild.result}", emails: userEmail
//            }
//        }
    }
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
            cloudformation.singleValidate("deployments", it)
        }
    }
}

def getChanges() {
    MAX_MSG_LEN = 100
    def changes = ""
    echo "Gathering SCM changes"
    def changeLogSets = currentBuild.rawBuild.changeSets
    changeLogSets.each { def changeLogSet ->
        def entries = changeLogSet.items
        entries.each { def entry ->
            truncated_msg = entry.msg.take(MAX_MSG_LEN)
            changes += " - $truncated_msg [$entry.author]\n"
            def files = entry.getAffectedFiles()
            echo "files: ${files}"
            files.each {def file ->
                Global.CHANGED_FILES.add(file.getPath())
            }
        }
    }
    if (!changes) {
        changes = " - No new changes"
    }
    return changes
}