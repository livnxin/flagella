I intend to eventually integrate Clickhouse and analytic service to allow user to query for analytical data regarding the app and platform.
The reason why Clickhouse is chosen is because it fits my requirement being an OLAP database with BASE approach to replica consistency comapred to the typical ACID based approach. 
The reason why I chose BASE is because I believe that the stringent requirement of ACID does not justify the opportunity cost of better performance of BASE replication for analytical data. I believe that a sufficiently robust analysis can tolerate a few missing data point without affecting its capability to deliver acceptable prediction. 
Certain data are better served on OLTP database like PostgreSQL. For this paltform, authentication data is one eample of the type of data that is better on PostgreSQL rather than Clickhouse. But for the scope and constraint of this project, the addition of postgreSQL or other OLTP database has not been deemed necessary. 

I intend to eventually add Tetragon for ebpf based security policy enforcement. ANother similar tools is Falco but I chose tetragon because Tetragon is a kubernetes native tools that leverages ebpf based policy enforcement. The use of ebpf in Tetragon allows enforcement of policy before they reach the kernel.

I intend to use canary deployment for my update strategy rather than blue-green strategy.
