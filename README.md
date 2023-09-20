# Realtime Postgres Updates with Elixir
## What is the project?
The Project is an elixir umbrella project, with two apps inside `app` and `postgresListener`, the main focused module is the `PostgresListener` module, which acts as a Replica Node for Postgres, and reieves updates from the Postgres Database, by means of user defined publications on the tables and defined subscriptions by the user. Which you can catch in your elixir application and send realtime updates from your applciation to the dependent apps.
## Why making an app that listen to updates from Postgres? 
1. Real-time Notifications: If your application needs to inform users about changes in the database in real-time, listening to replication updates can be very effective. For example, in a social media application, you might want to notify a user's followers whenever the user posts a new update. By listening to the replication updates, you can trigger these notifications immediately after the new post is written to the database
2. Data Analysis and Reporting: For applications that perform heavy data analysis or reporting, using a replica can be beneficial as it allows the application to query the replica without affecting the performance of the primary database. Any changes in the data can be tracked by listening to the replication updates.
   
## Let's Understand the Components Embedded Inside
```
.
├── lib
│   ├── postgres_listener
│   │   ├── configs
│   │   │   ├── configs.ex
│   │   │   └── registry.ex
│   │   ├── decoder
│   │   │   ├── decoder.ex
│   │   │   └── oid_database.ex
│   │   ├── events
│   │   │   ├── event.ex
│   │   │   └── events.ex
│   │   ├── replication
│   │   │   ├── replication_publisher.ex
│   │   │   ├── replication_server.ex
│   │   │   └── supervisor.ex
│   │   ├── supervisor.ex
│   │   └── utils
│   │       ├── changes.ex
│   │       ├── transaction_filter.ex
│   │       └── types.ex
│   └── postgres_listener.ex
└── mix.exs

7 directories, 15 files
```

### Top Level Overview
The Project is divided into several modules, out of which there are three essential modules, that can focused upon, `replication_supervisor`, `events_server` and `config_agent`. The trailing names of all these modules are essentially the names of the types these processes. `Replication_Supervisor` is a supervisor, managing replication tasks, `Events_Server` is a `gen_server` module that takes care of transmitting the events to the dependent modules and `config_agent` is an agent module that takes care of the current configuration for the dependent app, along with that it manages the `process_registry` side by side.

### Keep this in mind while reading the library
pglistener doesn't behaves like an extension actually from where you can use code, instead of that it starts processes for you that are taking care of your replication and the dependent apps. This package is built to be used with multiple apps, that's why while registering the processes, it registers for apps.

### Modules Embedded
**Config** ->  An agent that takes care of the configuration for the specific app, for more than one app there would be more than one agents taking care of them as well.

**Events** ->   The particular modules serves as a "SPEAKER" to the apps that rely on the PGListener. In the main configuration, we have mentioned the set of modules that we have to send data to on any change. The events module recieves the txn data and trigger the process function of those modules and send them the data.

**Replication_Supervisor** ->   The module serves as a dedicated supervisor for our replication processes, i.e. Replication Publisher and Replication Supervisor, the current supervisor only start replication supervisor. Why are we taking up a different supervisor? Because the supervisor starategy we are opting is one_for_all here, if one process crashes, every process that's dependent on it must restart.

**Replication_Server** ->  Serves as a Postgres Replication Node, as soon as Postgres recieves an update from a particular replication, it publishes an update to the replication nodes, so that we can maintain a backup for the data, here we don't have to backup but we have to transmit the data across our subscribers.
There are two types of data types we are handling here in server, Wal Messages ( starts with ?w) which are WAL Messages for any update / insert / delete events and the others are control messages ( ?k ) which are responsible for Synchronization of messages, what operation happened after what.
  
**Registry** ->   Registry module keeps the track of all of our started process, such as supervisor, replication processes and events. That's helpful when we have multiple apps running the same module, for multiple apps we have to run identical processes and registry is important to contextualize the processes, hence we are using app name to segrigate the processes.







