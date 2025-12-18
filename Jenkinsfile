/**
 *   Jenkins build script for PHP image used as a base for other projects
 *
 */

@Library('devops-ea-shared-lib') _

buildAgent = create_agent(team: "wbt")

pipeline {
    agent {
        label "${buildAgent.agentName}"
    }

    options {
        // This is required if you want to clean before build
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    environment {
        containerRegistryCredentials = credentials('ARTIFACTORY_PUBLISH')
        containerRegistry = 'artifactory.devops.hc-sc.gc.ca'
        containerRegistryPull = 'artifactory.devops.hc-sc.gc.ca'
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
                    version83="8.3b" + (buildId ? buildId : "MANUAL-BUILD")
                    version84="8.4b" + (buildId ? buildId : "MANUAL-BUILD")

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
                        docker pull php:8.3-apache
                        docker build -t php-base:8.3${currentVersion} -t php-base:8.3 -t php-base:latest -f dockerfile83 --target base .
                        docker tag php-base:8.3${currentVersion} ${containerRegistry}/php/php-base:8.3${currentVersion}
                        docker tag php-base:8.3 ${containerRegistry}/php/php-base:8.3
                        docker tag php-base:latest ${containerRegistry}/php/php-base:latest

                        docker build -t php-base:8.3${currentVersion}-mongodb -t php-base:8.3-mongodb -t php-base:latest-mongodb -f dockerfile83 --target mongodb .
                        docker tag php-base:8.3${currentVersion}-mongodb ${containerRegistry}/php/php-base:8.3${currentVersion}-mongodb
                        docker tag php-base:8.3-mongodb ${containerRegistry}/php/php-base:8.3-mongodb
                        docker tag php-base:latest-mongodb ${containerRegistry}/php/php-base:latest-mongodb

                        docker pull php:8.4-apache
                        docker build -t php-base:8.4${currentVersion} -t php-base:8.4 -f dockerfile84 --target base .
                        docker tag php-base:8.4${currentVersion} ${containerRegistry}/php/php-base:8.4${currentVersion}
                        docker tag php-base:8.4 ${containerRegistry}/php/php-base:8.4

                        docker build -t php-base:8.4${currentVersion}-mongodb -t php-base:8.4-mongodb -f dockerfile84 --target mongodb .
                        docker tag php-base:8.4${currentVersion}-mongodb ${containerRegistry}/php/php-base:8.4${currentVersion}-mongodb
                        docker tag php-base:8.4-mongodb ${containerRegistry}/php/php-base:8.4-mongodb

                        docker push ${containerRegistry}/php/php-base:8.3
                        docker push ${containerRegistry}/php/php-base:8.3-mongodb
                        docker push ${containerRegistry}/php/php-base:8.4-mongodb
                        docker push ${containerRegistry}/php/php-base:8.4-mongodb
                        docker push ${containerRegistry}/php/php-base:latest
                        docker push ${containerRegistry}/php/php-base:latest-mongodb
                    """
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
                    id -> jiraComment body: "*Build Result ${resultString}* appmeta: PHP Base (up to 8.4${currentVersion}) [Details|${env.BUILD_URL}]", issueKey: id
                }
            }

            destroy_agent(buildAgent)
        }
    }
}
