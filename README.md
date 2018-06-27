# DayTrader7 - sample Java EE7 application

Usage:

- Clone or download this repository.
- Build Docker image:
  - ```docker build -t daytrader .``` 
- Run Docker image using embedded database:
  - ```docker run -it --rm -p 9080:9082 daytrader```
  - Running with embedded db, database tables are created and populated on start.
- Run Docker image using remote database:
  - ```docker run -it --rm -p 9080:9082 -e REMOTE_DB_IP_ADDRESS=10.0.75.1 daytrader```
  - Derby server is in specified IP address.
  - Remember to create tables and populate database, if not using sample database.
- Access the app: http://127.0.0.1:9080/daytrader
- Login credentials:
  - Username: *uid:0*
  - Password: *xxx*
  
## Sample Derby database

Sample database with Daytrader data is provided as Docker image.

- Change to directory *sample_database*.
- Build Derby Docker image:
  - ```docker build -t derby-daytrader .``` 
- Run Docker image using :
  - ```docker run -it --rm -p 1527:1527 derby-daytrader```
- Run Daytrader image using remote database:
  - ```docker run -it --rm -p 9080:9082 -e REMOTE_DB_IP_ADDRESS=10.0.75.1 daytrader```
  - Derby server is in specified IP address.

## Use case

[Demonstrate DevOps pipeline](https://github.com/samisalkosuo/icp-cam-devops-demo) using this app and, for example, Jenkins, IBM Cloud Private and AWS.

- Change this application:
  - open [daytrader-ee7-web/src/main/webapp/contentHome.html](daytrader-ee7-web/src/main/webapp/contentHome.html)
  - Change the HTML code.
  - Update version in [VERSION](VERSION).
- Commit and let DevOps pipeline do the deployment.
- Go to application and see the change you made.

## Jmeter

[Jmeter test plan](jmeter_files/daytrader_jmeter4.jmx) is available. This plan is used to put load on the DayTrader application. It is not meant to be performance testing plan of DayTrader application or infrastructure where it runs.

Plan uses JMeter 4.0. It simulates user who logs in, views portfolio, views quotes, buys stock, views quotes again and then logs out.

# Java EE7: DayTrader7 Sample

This sample contains the DayTrader 7 benchmark, which is an application built around the paradigm of an online stock trading system. The application allows users to login, view their portfolio, lookup stock quotes, and buy or sell stock shares. With the aid of a Web-based load driver such as Apache JMeter, the real-world workload provided by DayTrader can be used to measure and compare the performance of Java Platform, Enterprise Edition (Java EE) application servers offered by a variety of vendors. In addition to the full workload, the application also contains a set of primitives used for functional and performance testing of various Java EE components and common design patterns.

DayTrader is an end-to-end benchmark and performance sample application. It provides a real world Java EE workload. DayTrader's new design spans Java EE 7, including the new WebSockets specification. Other Java EE features include JSPs, Servlets, EJBs, JPA, JDBC, JSF, CDI, Bean Validation, JSON, JMS, MDBs, and transactions (synchronous and asynchronous/2-phase commit).

This sample can be installed onto WAS Liberty runtime versions 8.5.5.6 and later.

## Getting Started

Browse the code to see what it does, or build and run it yourself:
* [Building and running on the command line](/docs/Using-cmd-line.md)
* [Building and running using Eclipse and WebSphere Development Tools (WDT)](/docs/Using-WDT.md)
* [Downloading WAS Liberty](/docs/Downloading-WAS-Liberty.md)

Once the server has been started, go to [http://localhost:9082/daytrader](http://localhost:9082/daytrader) to interact with the sample.

## Notice

© Copyright IBM Corporation 2015.

## License

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
````
