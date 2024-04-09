## Additional Information about WildFly Configuration
There is no module.xml in this repository. It has been moved to the [pic-sure-wildfly-docker repository](https://github.com/hms-dbmi/pic-sure-wildfly-docker).
The `module.xml` is created dynamically by the `generate-module-xml.sh` script in the pic-sure-wildfly-docker repository. This script is run when the
`pic-sure-with-aggregate-resource.Dockerfile` is built. The module.xml is created based on the jars copied into the 
`opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/` directory in the docker image.