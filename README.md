# hetzner-k3s - Nextcloud

## Ressourcen

- Hetzner K3s [https://github.com/vitobotta/hetzner-k3s](https://github.com/vitobotta/hetzner-k3s)
- Nextcloud Helm Chart [https://github.com/nextcloud/helm/blob/main/charts/nextcloud/README.md](https://github.com/nextcloud/helm/blob/main/charts/nextcloud/README.md#introduction)
- [Mysql + Replica](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)

## Testing

Zuerst wird alles mit https://microk8s.io/ getestet.

### Microk8s installieren

```bash
sudo snap install microk8s --classic

sudo usermod -a -G microk8s user
sudo chown -R user ~/.kube

microk8s status --wait-ready

microk8s enable dashboard

microk8s enable dns

microk8s enable registry
```

### MySQL Cluster aufsetzen

```bash
microk8s kubectl apply -f app/mysql/*
```

#### Configure Master (mysql-0)
```bash
kubectl exec -it mysql-0 -- mysql -u root -p

```

```sql
CREATE USER 'replication_user'@'%' IDENTIFIED WITH mysql_native_password BY 'your_strong_root_password_here';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
FLUSH PRIVILEGES;
```

```sql
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000003 |      891 |              |                  | 9c5f2bb1-3af6-11f0-9598-767b498c115c:1-8 |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)
```

#### Configure Slave (mysql-1)

```bash
kubectl exec -it mysql-1 -- mysql -u root -p
```

```sql
STOP SLAVE; -- or STOP REPLICA; for MySQL 8.0.22+
RESET SLAVE ALL; -- or RESET REPLICA ALL;
```

```sql
CHANGE MASTER TO
  MASTER_HOST='mysql-0.mysql-headless.default.svc.cluster.local', -- Use the headless service name
  MASTER_USER='replication_user',
  MASTER_PASSWORD='your_strong_root_password_here',
  MASTER_AUTO_POSITION = 1; -- Enable GTID-based replication
```

```sql
START SLAVE;
```

```sql
mysql> SHOW SLAVE STATUS\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: mysql-0.mysql-headless.default.svc.cluster.local
                  Master_User: replication_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 891
               Relay_Log_File: mysql-relay-bin.000003
                Relay_Log_Pos: 1107
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 891
              Relay_Log_Space: 2985933
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: 9c5f2bb1-3af6-11f0-9598-767b498c115c
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 9c5f2bb1-3af6-11f0-9598-767b498c115c:1-8
            Executed_Gtid_Set: 9c5f2bb1-3af6-11f0-9598-767b498c115c:1-8,
a84db5c9-3af6-11f0-9287-123e18e14788:1-5
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
       Master_public_key_path: 
        Get_master_public_key: 0
            Network_Namespace: 
1 row in set, 1 warning (0.00 sec)

ERROR: 
No query specified
```

#### Check Replication

##### Create Database on Master
```sql
mysql> CREATE DATABASE test2;
Query OK, 1 row affected (0.01 sec)

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test2              |
+--------------------+
5 rows in set (0.00 sec)

mysql> 
```

##### Show Datbases on Slave

```sql
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test2              |
+--------------------+
5 rows in set (0.00 sec)
```