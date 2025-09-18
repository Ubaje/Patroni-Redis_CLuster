#!/bin/bash

# Patroni 3-Node Cluster Management Script with Consul

case "$1" in
    "start")
        echo "Starting Patroni 3-node cluster with Consul..."
        docker-compose up -d
        echo "Waiting for Consul cluster to initialize..."
        sleep 15
        echo "Waiting for Patroni cluster to initialize..."
        sleep 30
        echo "Cluster status:"
        docker exec patroni1 /opt/patroni/bin/patronictl -c /etc/patroni/patroni.yml list
        echo ""
        echo "Consul UI: http://localhost:8500"
        ;;
    
    "stop")
        echo "Stopping Patroni cluster..."
        docker-compose down
        ;;
    
    "status")
        echo "Cluster status:"
        docker exec patroni1 /opt/patroni/bin/patronictl -c /etc/patroni/patroni.yml list
        echo ""
        echo "Consul members:"
        docker exec consul-server-1 consul members
        ;;
    
    "consul")
        echo "Consul cluster status:"
        docker exec consul-server-1 consul members
        echo ""
        echo "Consul services:"
        docker exec consul-server-1 consul catalog services
        echo ""
        echo "PostgreSQL services in Consul:"
        docker exec consul-server-1 consul catalog nodes -service=postgresql-patroni
        ;;
    
    "failover")
        echo "Initiating manual failover..."
        docker exec patroni1 /opt/patroni/bin/patronictl -c /etc/patroni/patroni.yml failover postgres-cluster
        ;;
    
    "restart")
        echo "Restarting specific node..."
        if [ -z "$2" ]; then
            echo "Usage: $0 restart <node_name>"
            echo "Available nodes: patroni1, patroni2, patroni3"
            exit 1
        fi
        docker exec $2 /opt/patroni/bin/patronictl -c /etc/patroni/patroni.yml restart postgres-cluster $2
        ;;
    
    "logs")
        if [ -z "$2" ]; then
            echo "Usage: $0 logs <service_name>"
            echo "Available services: patroni1, patroni2, patroni3, consul-server-1, consul-server-2, consul-server-3, haproxy"
            exit 1
        fi
        docker-compose logs -f $2
        ;;
    
    "connect")
        echo "Connection information:"
        echo "Primary (writes): localhost:5000"
        echo "Replicas (reads): localhost:5001"
        echo "Direct connections:"
        echo "  patroni1: localhost:5432"
        echo "  patroni2: localhost:5433"
        echo "  patroni3: localhost:5434"
        echo ""
        echo "Management interfaces:"
        echo "Consul UI: http://localhost:8500"
        echo "HAProxy stats: http://localhost:7000"
        echo ""
        echo "To connect to primary:"
        echo "psql -h localhost -p 5000 -U postgres"
        ;;
    
    "test")
        echo "Testing cluster connectivity..."
        echo "Testing primary connection..."
        docker exec patroni1 psql -h haproxy -p 5000 -U postgres -c "SELECT current_database(), inet_server_addr(), inet_server_port();"
        echo ""
        echo "Testing replica connection..."
        docker exec patroni1 psql -h haproxy -p 5001 -U postgres -c "SELECT current_database(), inet_server_addr(), inet_server_port();"
        ;;
    
    "consul-kv")
        echo "Patroni configuration in Consul KV store:"
        docker exec consul-server-1 consul kv get -recurse patroni/
        ;;
    
    "cleanup")
        echo "Cleaning up cluster (WARNING: This will delete all data)..."
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v
            docker volume prune -f
            echo "Cluster cleaned up."
        else
            echo "Cleanup cancelled."
        fi
        ;;
    
    *)
        echo "Patroni 3-Node Cluster Management with Consul"
        echo "Usage: $0 {start|stop|status|consul|failover|restart|logs|connect|test|consul-kv|cleanup}"
        echo ""
        echo "Commands:"
        echo "  start      - Start the entire cluster"
        echo "  stop       - Stop the entire cluster"
        echo "  status     - Show cluster status"
        echo "  consul     - Show Consul cluster information"
        echo "  failover   - Initiate manual failover"
        echo "  restart    - Restart a specific node"
        echo "  logs       - Show logs for a service"
        echo "  connect    - Show connection information"
        echo "  test       - Test cluster connectivity"
        echo "  consul-kv  - Show Patroni config in Consul KV"
        echo "  cleanup    - Remove all data and volumes"
        ;;
esac