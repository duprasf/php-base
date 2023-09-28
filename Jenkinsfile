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

                    // def properties = readProperties  file: 'appmeta.properties'

                    //Get basic meta-data
                    rootGroup = 'web-mobile'
                    buildId = env.BUILD_ID
                    version81="8.1v" + (buildId ? buildId : "MANUAL-BUILD")
                    version82="8.2v" + (buildId ? buildId : "MANUAL-BUILD")
                    module=rootGroup

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
                        docker pull php:8.1-apache
                        docker build -t php-base:${version81} -t php-base:8.1 .
                        docker tag php-base:${version81} ${containerRegistry}/php/php-base:${version81}
                        docker tag php-base:8.1 ${containerRegistry}/php/php-base:8.1

                        docker pull php:8.2-apache
                        docker build -t php-base:${version82} -t php-base:8.2 -t php-base:latest -f dockerfile82 .
                        docker tag php-base:${version82} ${containerRegistry}/php/php-base:${version82}
                        docker tag php-base:8.2 ${containerRegistry}/php/php-base:8.2
                        docker tag php-base:latest ${containerRegistry}/php/php-base:latest
                    """
                }
                script {
                    def buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:${version81}", 'docker-local'
                    buildInfo.append buildInfoTemp
                    def buildInfoTempLatest
                    buildInfoTempLatest = artifactoryDocker.push "${containerRegistry}/php/php-base:latest", 'docker-local'
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
                resultString = "Success ☼"
            }
        }
        unstable {
            script {
                resultString = "Unstable ⛅"
            }
        }
        failure {
            script {
                resultString = "Failure 🌩"
            }
        }
        cleanup {
            emailext body: "<strong>${resultString}</strong><p>See build result details at: <a href='${env.JOB_URL}'>${env.JOB_URL}</a></p>", mimeType: 'text/html; charset=UTF-8', recipientProviders: [[$class: 'CulpritsRecipientProvider'], [$class: 'DevelopersRecipientProvider'], [$class: 'UpstreamComitterRecipientProvider'], [$class: 'RequesterRecipientProvider']], replyTo: 'devops@hc-sc.gc.ca', subject: "${resultString} ${currentBuild.fullDisplayName}"
            script {
                jiraIssueSelector(issueSelector: [$class: 'DefaultIssueSelector'])
                        .each {
                    id -> jiraComment body: "*Build Result ${resultString}* Module: ${module} appmeta: ${version81} [Details|${env.BUILD_URL}]", issueKey: id
                }
            }
        }
    }
}
