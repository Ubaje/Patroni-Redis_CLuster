# Patroni + Redis Cluster Setup

This project provides a complete setup for running a highly available PostgreSQL cluster using Patroni alongside a Redis Cluster, all orchestrated with Docker Compose.

## Architecture

The setup consists of two main components:

### 1. Patroni PostgreSQL Cluster

-   Multiple PostgreSQL nodes managed by Patroni for high availability
-   HAProxy for load balancing and automatic failover
-   etcd for distributed configuration storage

### 2. Redis Cluster

-   Distributed Redis cluster setup
-   HAProxy for Redis load balancing
-   Includes data generation utilities

## Prerequisites

-   Docker
-   Docker Compose
-   Bash shell

## Project Structure

```
.
├── compose.yml              # Main Docker Compose configuration
├── haproxy.cfg/            # HAProxy configuration directory
├── patroni.yml/            # Patroni configuration directory
├── postgres/
│   ├── dockerfile          # PostgreSQL node Dockerfile
│   ├── haproxy.cfg        # HAProxy configuration for PostgreSQL
│   ├── patroni_setup.sh   # Patroni initialization script
│   └── patroni.yml        # Patroni node configuration
└── redis/
    ├── dockerfile.redis_data_entry  # Redis data entry container
    ├── generate_redis_data.js       # Data generation script
    ├── haproxy.cfg                  # HAProxy configuration for Redis
    ├── package.json                 # Node.js dependencies
    ├── redis_setup.sh              # Redis cluster setup script
    └── redis.sh                    # Redis initialization script

```

## Quick Start

1. Clone this repository
2. Start the services:
    ```bash
    docker-compose up -d
    ```

## Component Details

### Patroni PostgreSQL Cluster

-   Provides automatic failover
-   Ensures high availability of PostgreSQL database
-   Uses etcd for cluster coordination
-   HAProxy handles load balancing

### Redis Cluster

-   Distributed Redis setup
-   Includes data generation utilities
-   Load balanced through HAProxy
-   Automatic sharding and replication

## Accessing Services

### PostgreSQL

-   Primary node: localhost:5000
-   Replica nodes: localhost:5001, localhost:5002
-   HAProxy stats: localhost:7000

### Redis

-   Redis Cluster nodes: localhost:6379-6384
-   HAProxy stats: localhost:7001

## Monitoring

-   HAProxy statistics are available for both PostgreSQL and Redis clusters
-   Access PostgreSQL HAProxy stats at http://localhost:7000/stats
-   Access Redis HAProxy stats at http://localhost:7001/stats

## Data Generation

The project includes a data generation utility for Redis:

```bash
docker-compose run redis-data-entry
```

## Configuration

### Patroni

-   Configuration file: `postgres/patroni.yml`
-   HAProxy configuration: `postgres/haproxy.cfg`

### Redis

-   Cluster setup: `redis/redis_setup.sh`
-   HAProxy configuration: `redis/haproxy.cfg`

## Maintenance

### Scaling

-   To add more PostgreSQL nodes, modify the `compose.yml` file
-   Redis cluster can be scaled by adjusting the cluster configuration

### Backup and Recovery

-   PostgreSQL backups are handled through Patroni
-   Redis persistence is configured for data durability

## Troubleshooting

1. If PostgreSQL cluster doesn't form:

    - Check etcd logs
    - Verify Patroni configuration
    - Ensure network connectivity between nodes

2. If Redis cluster fails to initialize:
    - Check Redis logs
    - Verify cluster ports are accessible
    - Ensure proper node communication

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.