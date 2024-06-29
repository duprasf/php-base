/**
 *   Jenkins build script for PHP image used as a base for other projects
 *
 */

pipeline {
    agent {
        label 'DockerV1'
    }

    options {
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    environment {
        containerRegistryCredentials = credentials('ARTIFACTORY_PUBLISH')
        containerRegistry = 'jack.hc-sc.gc.ca'
        containerRegistryPull = 'jack.hc-sc.gc.ca'
    }

    stages {

        stage('appmeta Info') {
            steps {
                // Clean before build
                cleanWs()
                // We need to explicitly checkout from SCM here
                checkout scm

                script {
                    //Get basic meta-data
                    buildId = env.BUILD_ID
                    currentVersion="b" + (buildId ? buildId : "MANUAL-BUILD")
                    version81="8.1b" + (buildId ? buildId : "MANUAL-BUILD")
                    version82="8.2b" + (buildId ? buildId : "MANUAL-BUILD")
                    version83="8.3b" + (buildId ? buildId : "MANUAL-BUILD")

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
                        docker pull php:7.1-apache
                        docker build -t php-base:7.1${currentVersion} -t php-base:7.1 -f dockerfile71 .
                        docker tag php-base:7.1${currentVersion} ${containerRegistry}/php/php-base:7.1${currentVersion}
                        docker tag php-base:7.1 ${containerRegistry}/php/php-base:7.1

                        docker pull php:8.1-apache
                        docker build -t php-base:8.1${currentVersion} -t php-base:8.1 -f dockerfile81 .
                        docker tag php-base:8.1${currentVersion} ${containerRegistry}/php/php-base:8.1${currentVersion}
                        docker tag php-base:8.1 ${containerRegistry}/php/php-base:8.1

                        docker pull php:8.2-apache
                        docker build -t php-base:8.2${currentVersion} -t php-base:8.2 -f dockerfile82 .
                        docker tag php-base:8.2${currentVersion} ${containerRegistry}/php/php-base:8.2${currentVersion}
                        docker tag php-base:8.2 ${containerRegistry}/php/php-base:8.2

                        docker build -t php-base:8.2${currentVersion}-mongodb -t php-base:8.2-mongodb -f dockerfile82 --target mongodb .
                        docker tag php-base:8.2${currentVersion}-mongodb ${containerRegistry}/php/php-base:8.2${currentVersion}-mongodb
                        docker tag php-base:8.2-mongodb ${containerRegistry}/php/php-base:8.2-mongodb

                        docker pull php:8.3-apache
                        docker build -t php-base:8.3${currentVersion} -t php-base:8.3 -t php-base:latest -f dockerfile83 --target base .
                        docker tag php-base:8.3${currentVersion} ${containerRegistry}/php/php-base:8.3${currentVersion}
                        docker tag php-base:8.3 ${containerRegistry}/php/php-base:8.3
                        docker tag php-base:latest ${containerRegistry}/php/php-base:latest

                        docker build -t php-base:8.3${currentVersion}-mongodb -t php-base:8.3-mongodb -t php-base:latest-mongodb -f dockerfile83 --target mongodb .
                        docker tag php-base:8.3${currentVersion}-mongodb ${containerRegistry}/php/php-base:8.3${currentVersion}-mongodb
                        docker tag php-base:8.3-mongodb ${containerRegistry}/php/php-base:8.3-mongodb
                        docker tag php-base:latest-mongodb ${containerRegistry}/php/php-base:latest-mongodb
                    """
                }
                script {
                    def buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:7.1${currentVersion}", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:7.1", 'docker-local'
                    buildInfo.append buildInfoTemp

                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.1", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.1${currentVersion}", 'docker-local'
                    buildInfo.append buildInfoTemp

                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.2", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.2${currentVersion}", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.2-mongodb", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.2${currentVersion}-mongodb", 'docker-local'
                    buildInfo.append buildInfoTemp

                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.3", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.3${currentVersion}", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.3-mongodb", 'docker-local'
                    buildInfo.append buildInfoTemp
                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:8.3${currentVersion}-mongodb", 'docker-local'
                    buildInfo.append buildInfoTemp

                    buildInfoTemp = artifactoryDocker.push "${containerRegistry}/php/php-base:latest-mongodb", 'docker-local'
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
            cleanWs(cleanWhenNotBuilt: true,
                deleteDirs: true,
                disableDeferredWipeout: true,
                notFailBuild: true,
                patterns: [
                    [pattern: '.gitignore', type: 'INCLUDE']
                ]
            )

            sh """
                docker rmi php-base:7.1${currentVersion}
                docker rmi php-base:7.1

                docker rmi php-base:8.1${currentVersion}
                docker rmi php-base:8.1
                docker rmi php-base:8.2${currentVersion}
                docker rmi php-base:8.2

                docker rmi php-base:8.2${currentVersion}-mongodb
                docker rmi php-base:8.2-mongodb

                docker rmi php-base:8.3${currentVersion}
                docker rmi php-base:8.3
                docker rmi php-base:latest

                docker rmi php-base:8.3${currentVersion}-mongodb
                docker rmi php-base:8.3-mongodb
                docker rmi php-base:latest-mongodb

                docker image ls
            """

            script {
                resultString = "None"
            }
        }
        success {
            script {
                resultString = "Success 🌞"
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
                    id -> jiraComment body: "*Build Result ${resultString}* appmeta: PHP Base (up to 8.3${currentVersion}) [Details|${env.BUILD_URL}]", issueKey: id
                }
            }
        }
    }
}
