/**
 *   Jenkins build script for PHP image used as a base for other projects
 *
 */

pipeline {
    agent {
        label 'standardv1'
    }

    options { disableConcurrentBuilds() }

    environment {
        containerRegistryCredentials = credentials('ARTIFACTORY_PUBLISH')
        containerRegistry = 'jack.hc-sc.gc.ca'
        containerRegistryPull = 'jack.hc-sc.gc.ca'
    }

    stages {

        stage('appmeta Info') {
            steps {
                checkout scm
                script {

                    def properties = readProperties  file: 'appmeta.properties'

                    //Get basic meta-data
                    rootGroup = properties.root_group
                    rootVersion = properties.root_version
                    buildId = env.BUILD_ID
                    version = rootVersion + "." + (buildId ? buildId : "MANUAL-BUILD")
                    module = rootGroup

                    // Setup Artifactory connection
                    artifactoryServer = Artifactory.server 'default'
                    artifactoryGradle = Artifactory.newGradleBuild()
                    artifactoryDocker = Artifactory.docker server: artifactoryServer
                    buildInfo = Artifactory.newBuildInfo()
                }
            }
        }

        stage('Image') {
            when {
                branch 'master'
            }
            steps {
                withCredentials([
                    usernamePassword(credentialsId:'ARTIFACTORY_PUBLISH', usernameVariable: 'USR', passwordVariable: 'PWD')
                ]) {
                    sh """
                        docker login -u ${USR} -p ${PWD} ${
                            containerRegistry
                        }
                        docker build -t php-hc-base:${version} -t php-hc-base:latest .
                        docker tag php-hc-base:${version} ${containerRegistry}/php/php-hc-base:${version}
                        docker tag php-hc-base:latest ${containerRegistry}/php/php-hc-base:latest
                    """
                }
                script {
                    def buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-hc-base:${version}", 'docker-local'
                    buildInfo.append buildInfoTemp
                    def buildInfoTempLatest
                    buildInfoTempLatest = artifactoryDocker.push "${containerRegistry}/php/php-hc-base:latest", 'docker-local'
                    buildInfo.append buildInfoTempLatest
                }
            }
        }
    }

    post {
        always {
            script {
                resultString = "None"
            }
        }
        success {
            script {
                resultString = "Success"
            }
        }
        unstable {
            script {
                resultString = "Unstable"
            }
        }
        failure {
            script {
                resultString = "Failure"
            }
        }
        cleanup {
            emailext body: "<strong>${resultString}</strong><p>See build result details at: <a href='${env.JOB_URL}'>${env.JOB_URL}</a></p>", mimeType: 'text/html; charset=UTF-8', recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'UpstreamComitterRecipientProvider'], [$class: 'RequesterRecipientProvider']], replyTo: 'no-reply@build.scs-lab.com', subject: "${currentBuild.fullDisplayName} ${resultString}"
            script {
                jiraIssueSelector(issueSelector: [$class: 'DefaultIssueSelector'])
                        .each {
                    id -> jiraComment body: "*Build Result ${resultString}* Module: ${module} appmeta: ${version} [Details|${env.BUILD_URL}]", issueKey: id
                }
            }
        }
    }
}
