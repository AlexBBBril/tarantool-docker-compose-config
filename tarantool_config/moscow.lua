vshard = require('vshard')

local topology = require('topology')

vshard.storage.cfg(
    {
        bucket_count = topology.bucket_count,
        sharding     = topology.sharding,

        memtx_dir  = "/var/lib/tarantool/memtx",
        wal_dir    = "/var/lib/tarantool/wal",
        replication_connect_quorum = 1,
    },
    'aaaaaaaa-0000-4000-a000-000000000011'
)

vshard.router.cfg(topology) -- options: bucket_count + sharding

require 'console'.start() os.exit()