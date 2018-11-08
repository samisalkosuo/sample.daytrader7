#Daytrader Docker image to build Daytrader app
#This is done because sometimes dowloading Maven libs fails
#and because downloading Maven dependencies take time

#Docker image 'kazhar/daytrader:build' is built automatically when build-branch changes.

#uses Maven with IBM JDK https://hub.docker.com/r/kazhar/maven/
FROM kazhar/maven:0.2 as build-stage

WORKDIR /

#copy files, if any source is changed these are changed
#and app is built again
COPY ./daytrader-ee7/ /daytrader-ee7/
COPY ./daytrader-ee7-ejb /daytrader-ee7-ejb/
COPY ./daytrader-ee7-web /daytrader-ee7-web/
COPY ./daytrader-ee7-wlpcfg /daytrader-ee7-wlpcfg/
COPY ./pom.xml ./

#mvn install and download dependencies
RUN mvn install

CMD ["/bin/bash"]


