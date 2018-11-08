#multistage Docker file
#build stage builds app
#uses daytrader build image that has Maven dependencies already downloaded
FROM kazhar/daytrader:build as build-stage

WORKDIR /

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

USER root:root

RUN apt-get update \
    && apt-get install -y curl

#Copy derby client jar
COPY ./lib/derbyclient.jar /opt/ibm/wlp/usr/shared/resources/Daytrader7SampleDerbyLibs/

#copy binaries from build stage
COPY --from=build-stage /daytrader-ee7-wlpcfg/servers/daytrader7Sample/ /opt/ibm/wlp/usr/servers/daytrader7Sample/
COPY --from=build-stage /daytrader-ee7-wlpcfg/shared/resources/Daytrader7SampleDerbyLibs/ /opt/ibm/wlp/usr/shared/resources/Daytrader7SampleDerbyLibs/

#Exposed HTTP port
EXPOSE 9082

#copy scripts
COPY ./scripts/start_app.sh ./
COPY ./scripts/configure_daytrader.sh ./

# Run the server script and start the server
#CMD ["/opt/ibm/wlp/bin/server","run","daytrader7Sample"]
CMD ["/bin/bash","start_app.sh"]
#CMD ["/bin/bash"]
