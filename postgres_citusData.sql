#After installtion:

# this user has access to sockets in /var/run/postgresql
sudo su - postgres

# include path to postgres binaries
export PATH=$PATH:/usr/lib/postgresql/12/bin

cd ~

#create directory
mkdir -p citus/master citus/slave1 citus/slave2

# create three normal postgres instances
initdb -D citus/master
initdb -D citus/slave1
initdb -D citus/slave2

#change the config file
echo "shared_preload_libraries = 'citus'" >> citus/master/postgresql.conf
echo "shared_preload_libraries = 'citus'" >> citus/slave1/postgresql.conf
echo "shared_preload_libraries = 'citus'" >> citus/slave2/postgresql.conf


#Let’s start the server:
/usr/lib/postgresql/12/bin/pg_ctl -D /var/lib/postgresql/citus/master start
 
/usr/lib/postgresql/12/bin/pg_ctl -D /var/lib/postgresql/citus/sslave1 start

/usr/lib/postgresql/12/bin/pg_ctl -D /var/lib/postgresql/citus/slave2 start

#create  Extensions
psql -p 4444 -c "CREATE EXTENSION citus;"
psql -p 5555-c "CREATE EXTENSION citus;"
psql -p 6666 -c "CREATE EXTENSION citus;"

#adding node to master
SELECT * from master_add_node('localhost', 5555);
SELECT * from master_add_node('localhost', 6666);

#check whether its added
select * from master_get_active_worker_nodes();

#master port is running on :4444

CREATE TABLE companies (
    
    id bigint NOT NULL,
    
    name text NOT NULL,
    
    image_url text,
    
    created_at timestamp without time zone NOT NULL,
    
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE campaigns (
    
    id bigint NOT NULL,
    
    company_id bigint NOT NULL,
    
    name text NOT NULL,
    
    cost_model text NOT NULL,
    
    state text NOT NULL,
    
    monthly_budget bigint,
    
    blacklisted_site_urls text[],
    
    created_at timestamp without time zone NOT NULL,
    
    updated_at timestamp without time zone NOT NULL
);


# To distribute the tables in the worker nodes

SELECT create_distributed_table('companies', 'id');

SELECT create_distributed_table('campaigns', 'company_id');


#load the data into the tables using \copy command

\copy companies from '/home/keerthana/Downloads/companies.csv' with csv
\copy campaigns from '/home/keerthana/Downloads/campaigns.csv' with csv



#sample queries

1.INSERT INTO companies VALUES (5000, 'New Company', 'https://randomurl/image.png', now(), now());


2.DELETE FROM campaigns WHERE id = 23 AND company_id = 3;


