# Redis Data Generator

This package generates synthetic data for the Redis cluster component of the Perconi system.

## Features

- Generate 100,000 synthetic user records
- Support for Redis cluster (6 nodes: 3 masters, 3 slaves)
- Gender distribution: 65% male, 35% female
- Faker.js integration for realistic data generation

## Installation

```bash
npm install
```

## Usage

### Generate Redis Data
```bash
npm start
```

### Test Redis Connection
```bash
npm test
```

## Data Structure

Each user record contains:
- `fn`: First name
- `mn`: Middle name  
- `sn`: Surname
- `g`: Gender (M/F)
- `n`: Sequential number (1-100,000)
- `dob`: Date of birth (1970-2010)

## Redis Cluster Configuration

The script connects to a 6-node Redis cluster:
- `redis1:7001` (master)
- `redis2:7002` (master)
- `redis3:7003` (master)
- `redis4:7004` (slave)
- `redis5:7005` (slave)
- `redis6:7006` (slave)

## Dependencies

- `ioredis`: Redis cluster client
- `@faker-js/faker`: Synthetic data generation
- `uuid`: UUID generation utilities
