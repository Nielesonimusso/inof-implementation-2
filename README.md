# Documentation CaaS

The CaaS platform prototype consists of multiple modules. It contains both the 
modules for the main sharing platform, as well as modules that represent
implementation examples of data source gateways and model gateways.

All modules can be executed as Docker containers. This folder contains multiple
Docker Compose configuration files which can be used to run the different modules 
that are part of CaaS.

The CaaS platform is split into two main Git repositories. These reside both
in this folder. The `inof-frontend` repository contains the frontend module, 
while the `model-sharing-platform` repository contains all other modules.

This file provides all the information needed to run the CaaS platform prototype, 
including the example data source gateways and model gateways. It also provides 
information required in order for new gateways to be integrated with the sharing 
platform.

## Dependencies
In order to (easily) run the CaaS platform, Docker is required to be installed 
on your system. It is recommended to install [Docker Desktop](https://www.docker.com/products/docker-desktop), which allows you to easily manage the running Docker containers, 
and also includes Docker Compose, which is used in the CaaS platform to easily 
run multiple containers. All module-specific dependencies are listed in the 
requirements-files of each of the modules; these are automatically used in the 
creation of Docker containers.

## Usage

### Installation
First, install [Docker Desktop](https://www.docker.com/products/docker-desktop).

The next step is to download the complete contents of this folder, and putting it 
in a location where you can find it back. In order to initialize the different 
databases that are used in the project, unzip the file 
`model-sharing-backend/db_files/data_volumes.zip`.

If you are cloning the repository from Github, make sure to fetch the git submodules 
using the following commands:
```bash
git submodules init
git submodules update
```

The CaaS platform makes use of a graph database. The Docker image for this is included 
in this folder. In order to use this Docker image, you have to run the following 
command from this folder:

```bash
docker load --input ./model-sharing-platform/db_files/graphdb_9.1.1-free.tar
```

After this step, you are ready to run the CaaS platform.

### Running
The CaaS platform includes plenty of modules. Docker Compose provides flexibility 
on what modules you want to run at any given time. In general, the modules are 
split into multiple groups. Each group has its own Docker compose file:

- `docker-compose.yml` contains the main sharing platform modules.
- `docker-compose-taste-nutrition.yml` contains the gateways related to the 
  tomato-soup-taste and nutrition use cases.
- `docker-compose-past-shelflife.yml` contains the gateways related to the
  pasteurization-shelflife use case.
- `docker-compose-cali-droplet.yml` contains the gateways related to the 
  calibration-dropletsize use case.

The main sharing platform modules can be started and stopped using the following
commands:
```bash
# start the main sharing platform modules
docker-compose up -d --build
# stop the main sharing platform modules
docker-compose down
```

> The main sharing platform modules need to be intialized when you run them for the 
first time! This can be done with the following command:
> ```bash
> docker exec -it $(docker ps -aqf "name=model-sharing-backend") flask seed-db
> ```
> This command can also be used to reset the database at any point.


All other gateway groups can be run by including the respective file name with these
commands; for example, the gateways related to the tomato-soup-taste and nutrition 
use cases can be started and stopped with the following commands:
```bash
# start the gateways related to the tomato-soup-taste and nutrition use cases
docker-compose -f .\docker-compose-taste-nutrition.yml up -d --build 
# stop the gateways
docker-compose -f .\docker-compose-taste-nutrition.yml down
```

It is also possible to only run specific modules in mentioned in these Docker Compose 
files by including the module names with the command. For example, to only start the
Recipe gateway fo the tomato-soup-taste use case you can use the following command:
```bash
# start only the Recipe gateway 
docker-compose -f .\docker-compose-taste-nutrition.yml up -d --build recipe-access-gateway
```
 
> Note that these commands have to build the required Docker images the first time 
they are used, which can take a long time!

The default configuration inside the Docker Compose files assumes all modules are 
run on the same machine. While it is possible to distribute the modules over different
machines, some changes need to be made in the Docker Compose files. The `APPLICATION_BASE` 
and `INOF_BASE` environment variables can be used to specify the address of a gateway, 
and the address the gateway should use to access the main sharing platform. 

## Integration
There are multiple approaches to integrating new use cases with the CaaS platform.
- The easy way would be to create new instances of the example model and data source 
  gateways. Both these gateways are made using a modular approach, which should make 
  it easy to adapt them for you rown use cases. 
- If you want more flexibility for your gateways, it is also possible to create 
  your own gateways from scratch. This allows you to use your preferred programming 
  language, and it gives you more control on how your gateway handles model runs.
  Integration should be possible as long as you adhere to use the same REST interface 
  provided by the example gateways.


### Example Data Source Gateway
The example Data Source gateways use a CSV file as their data source. To create 
your own instance of this Data Source gateway, you need to add your own CSV file 
in the `src/data` folder of the `data_access_gateway` module. You can then create 
your own service in a Docker Compose file, following the examples provided in the 
existing Docker Compose files. The Docker Compose file provides information about 
the file the Data Source gateway should use as a data source, as well as the metadata that describes the data in this file. 

### Data Source Gateway API
A Data Source gateway should provide the following REST API routes:
- `GET data.json` for providing the data of the data source in JSON format; 
  specifically, this should return a JSON array of objects, each object representing 
  a complete row in a data table.
- `GET ontology.ttl` for providing the metadata of the data source in [TURTLE](https://www.w3.org/TR/turtle/) 
  format.

### Example Model Gateway
The example Model gateways use a single python file that provides the implementation 
of the model, as well as the input and output definitions of this model. The input 
and output definitions are provided using Marshmallow serialization classes. In 
order to implement a new model, you only need to create your own python file that 
provides this information in the same way. Some more small changes are required 
in order to integrate your model:
- Add an instance of your model class to the `get_model()` function inside of 
  `src/__init__()`.
- Create a service in a Docker Compose file similarly to how the services of the 
  example model gateways are described.


### Model Gateway API
A Model Gateway should provide the following REST API routes:

- `GET ontology.ttl` for providing the input and output description in [TURTLE](https://www.w3.org/TR/turtle/) 
  format.
- `POST run_model` for clients to run the model. It should accept the JSON input 
  as described in the model's input definition, and it should provide a JSON output 
  according to the schema provided by the `ModelRunStatusDtoSchema` class. This 
  schema provides a single JSON object containing a `run_id` (used for later 
  retrieving the status and result of a run), a `created_on` timestamp, as well 
  as the running status either as one of:
  - submitted
  - success
  - running
  - failed
  - unreachable
- `GET get_result/<run_id>` for retrieving the results of a model run. The `run_id` 
  parameter should accept any run id that was previously provided as a response 
  to a run request. A `404` response should be provided if no result is (yet) 
  available. If a result is available, it should be provided according to the model's 
  output definition.
- `GET get_model_run_state/<run_id>` for retrieving the current status of a model 
  run. This should provide a similar output as the `POST run_model` endpoint, also 
  according to the `ModelRunStatusDtoSchema` class.
