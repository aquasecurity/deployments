import org.apache.commons.lang.RandomStringUtils

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
                        sortChangedFiles()
                    }
                    deployment.clone branch: "master"
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
                                    ["${it.split("/")[-1]}": generateStage(it, "cloudformation")]
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
                            expression { return CHANGE_TARGET.toDouble() >= 6.5 }
                        }
                    }
                    steps {
                        script {
                            log.info "Starting to test Manifest yamls"
                            def deploymentImage = docker.build("deployment-manifest-image", "-f Dockerfile-manifest .")
                            deploymentImage.inside("-u root") {
                                def parallelStagesMap = Global.CHANGED_MANIFESTS_FILES.collectEntries {
                                    ["${it.split("/")[-1]}": generateStage(it, "manifest")]
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
                            expression { return CHANGE_TARGET.toDouble() >= 6.5 }
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

def sortChangedFiles() {
    for (file in Global.CHANGED_FILES) {
        if (file.contains("ecs") && file.contains(".yaml")) {
            Global.CHANGED_CF_FILES.add(file)
        }
        else if (file.contains("manifests") && file.contains(".yaml")){
            Global.CHANGED_MANIFESTS_FILES.add(file)
        }
        else {
            Global.SORTED_CHANGED_FILES.add(file)
        }
    }
}

def generateStage(it, type) {
    if (type == "cloudformation") {
        return {
            withEnv(["RANDOM_STRING=${generateRandomString()}"]) {
                stage("${it.split("/")[-1]}") {
                    stage("verifing ${it.split("/")[-1]}") {
                        cloudformation.singleVerify("deployments", it, env.CHANGE_TARGET, "${env.BUILD_NUMBER}-${env.RANDOM_STRING}")
                    }
                    stage("deploying ${it.split("/")[-1]}") {
                        cloudformation.singleDeploy("deployments", it, env.CHANGE_TARGET, "${env.BUILD_NUMBER}-${env.RANDOM_STRING}")
                    }
                }
            }
        }
    }
    else if (type == "manifest") {
        return {
            stage("${it.split("/")[-1]}") {
                stage("verifing ${it.split("/")[-1]}") {
                    log.info "Starting to verify ${it.split("/")[-1]} file"
                    sh "kubeval ./deployments/${it} --strict"
                    log.info "Finished to verify ${it.split("/")[-1]} file"
                }
            }
        }
    }
    else {
        throw new Exception("type: ${type} is not supported")
    }

}

def getChanges() {
    MAX_MSG_LEN = 100
    def changes = ""
    log.info "Gathering SCM changes"
    def changeLogSets = currentBuild.rawBuild.changeSets
    changeLogSets.each { def changeLogSet ->
        def entries = changeLogSet.items
        entries.each { def entry ->
            truncated_msg = entry.msg.take(MAX_MSG_LEN)
            changes += " - $truncated_msg [$entry.author]\n"
            def files = entry.getAffectedFiles()
            log.info "files: ${files}"
            files.each { def file ->
                Global.CHANGED_FILES.add(file.getPath())
            }
        }
    }
    if (!changes) {
        changes = " - No new changes"
    }
    return changes
}

def generateRandomString(){
    String charset = (('a'..'z') + ('0'..'9')).join("")
    Integer length = 3
    return RandomStringUtils.random(length, charset.toCharArray())
}
