

#multistage Docker
#build stage builds app
#use IBM Java to compile because openliberty uses ibm java
FROM ibmjava:8-sdk as build-stage

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential wget unzip ca-certificates swig \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

#install Maven
RUN wget -q http://www.nic.funet.fi/pub/mirrors/apache.org/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.zip
RUN unzip -q apache-maven-3.5.3-bin.zip \
    && mv /apache-maven-3.5.3 /maven 
ENV PATH /maven/bin:$PATH

#docker build cache, downloada libs etc
COPY ./docker-build-cache /docker-build-cache
RUN cd docker-build-cache && mvn install

#copy files, if any source is changed these are changed
#and app is built again
COPY ./daytrader-ee7/ /daytrader-ee7/
COPY ./daytrader-ee7-ejb /daytrader-ee7-ejb/
COPY ./daytrader-ee7-web /daytrader-ee7-web/
COPY ./daytrader-ee7-wlpcfg /daytrader-ee7-wlpcfg/
COPY ./pom.xml ./

RUN mvn install


#Use WebSphere Liberty for actual image
FROM websphere-liberty:javaee7

RUN apt-get update \
    && apt-get install -y curl

#Copy derby client jar
COPY ./lib/derbyclient.jar /opt/ibm/wlp/usr/shared/resources/Daytrader7SampleDerbyLibs/

COPY --from=build-stage /daytrader-ee7-wlpcfg/servers/daytrader7Sample/ /opt/ibm/wlp/usr/servers/daytrader7Sample/
COPY --from=build-stage /daytrader-ee7-wlpcfg/shared/resources/Daytrader7SampleDerbyLibs/ /opt/ibm/wlp/usr/shared/resources/Daytrader7SampleDerbyLibs/

#Exposed HTTP port
EXPOSE 9082

COPY ./scripts/start_app.sh ./
COPY ./scripts/configure_daytrader.sh ./

# Run the server script and start the server
#CMD ["/opt/ibm/wlp/bin/server","run","daytrader7Sample"]
CMD ["/bin/bash","start_app.sh"]
#CMD ["/bin/bash"]
