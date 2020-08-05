FROM intersystemsdc/irisdemo-base-irisint-community:version-1.6

# Name of the project folder ex.: my-atelier-project
#ARG IRIS_PROJECT_FOLDER_NAME=iris-opcua-oee
ARG IRIS_PROJECT_FOLDER_NAME=src 

# Adding source code that will be loaded by the installer
ADD --chown=irisowner:irisuser ./${IRIS_PROJECT_FOLDER_NAME}/ $IRIS_APP_SOURCEDIR

ADD --chown=irisowner:irisuser ./uacbin /usr/irissys/bin/

# Running the installer. This will load the source from our project.
RUN /usr/irissys/demo/irisdemoinstaller.sh 
    #rm -f /tmp/export_to_hisdb.csv